using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Services;

public class InvoiceService : IInvoiceService
{
    private readonly QuanLyPhongTroContext _context;

    public InvoiceService(QuanLyPhongTroContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Lấy danh sách hóa đơn. Nếu month/year null thì lấy tất cả.
    /// </summary>
    public async Task<List<InvoiceDto>> GetInvoicesAsync(int? month, int? year, int? maQuanLy = null)
    {
        var query = _context.HoaDons
            .Include(h => h.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
            .Include(h => h.MaKhachNavigation)
            .AsQueryable();

        if (month.HasValue && year.HasValue)
        {
            query = query.Where(h => h.Thang == month.Value && h.Nam == year.Value);
        }

        if (maQuanLy.HasValue)
        {
            query = query.Where(h => h.MaPhongNavigation != null &&
                                     h.MaPhongNavigation.MaCoSoNavigation != null &&
                                     h.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy.Value);
        }

        var invoices = await query
            .OrderByDescending(h => h.Nam)
            .ThenByDescending(h => h.Thang)
            .ThenByDescending(h => h.MaHoaDon)
            .Select(h => new InvoiceDto
            {
                MaHoaDon = h.MaHoaDon,
                MaPhong = h.MaPhong,
                MaKhach = h.MaKhach,
                TenPhong = h.MaPhongNavigation != null ? h.MaPhongNavigation.SoPhong : string.Empty,
                TenCoSo = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.TenCoSo : string.Empty,
                TenKhachThue = h.MaKhachNavigation != null ? h.MaKhachNavigation.HoTen ?? string.Empty : string.Empty,
                Thang = h.Thang,
                Nam = h.Nam,
                SoDienCu = h.ChiSoDienCu,
                SoDienMoi = h.ChiSoDienMoi,
                SoNuocCu = h.ChiSoNuocCu,
                SoNuocMoi = h.ChiSoNuocMoi,
                DonGiaDien = h.DonGiaDien,
                DonGiaNuoc = h.DonGiaNuoc,
                TienPhong = h.TienPhong,
                TienDichVu = h.TienDichVu ?? 0,
                MoTaDichVu = h.MoTaDichVu,
                PhuPhi = h.PhuPhi ?? 0,
                MoTaPhuPhi = h.MoTaPhuPhi,
                TongTien = h.TongTien,
                TrangThai = h.TrangThai ?? "Chưa thanh toán",
                NgayLap = h.NgayLap.HasValue ? h.NgayLap.Value.ToString("yyyy-MM-dd") : null,
                HanThanhToan = h.HanThanhToan.HasValue ? h.HanThanhToan.Value.ToString("yyyy-MM-dd") : null,
                NgayThanhToan = h.NgayThanhToan.HasValue ? h.NgayThanhToan.Value.ToString("yyyy-MM-dd") : null,
                
                SoTaiKhoan = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.SoTaiKhoan : null,
                TenTaiKhoan = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.TenTaiKhoan : null,
                MaBin = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation.MaBin : null,
                TenVietTat = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation.TenVietTat : null,
            })
            .ToListAsync();

        return invoices;
    }

    /// <summary>
    /// Lấy danh sách hóa đơn theo mã khách thuê.
    /// </summary>
    public async Task<List<InvoiceDto>> GetInvoicesByCustomerAsync(int maKhach)
    {
        var invoices = await _context.HoaDons
            .Include(h => h.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
            .Include(h => h.MaKhachNavigation)
            .Where(h => h.MaKhach == maKhach)
            .OrderByDescending(h => h.Nam)
            .ThenByDescending(h => h.Thang)
            .ThenByDescending(h => h.MaHoaDon)
            .Select(h => new InvoiceDto
            {
                MaHoaDon = h.MaHoaDon,
                MaPhong = h.MaPhong,
                MaKhach = h.MaKhach,
                TenPhong = h.MaPhongNavigation != null ? h.MaPhongNavigation.SoPhong : string.Empty,
                TenCoSo = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.TenCoSo : string.Empty,
                TenKhachThue = h.MaKhachNavigation != null ? h.MaKhachNavigation.HoTen ?? string.Empty : string.Empty,
                Thang = h.Thang,
                Nam = h.Nam,
                SoDienCu = h.ChiSoDienCu,
                SoDienMoi = h.ChiSoDienMoi,
                SoNuocCu = h.ChiSoNuocCu,
                SoNuocMoi = h.ChiSoNuocMoi,
                DonGiaDien = h.DonGiaDien,
                DonGiaNuoc = h.DonGiaNuoc,
                TienPhong = h.TienPhong,
                TienDichVu = h.TienDichVu ?? 0,
                MoTaDichVu = h.MoTaDichVu,
                PhuPhi = h.PhuPhi ?? 0,
                MoTaPhuPhi = h.MoTaPhuPhi,
                TongTien = h.TongTien,
                TrangThai = h.TrangThai ?? "Chưa thanh toán",
                NgayLap = h.NgayLap.HasValue ? h.NgayLap.Value.ToString("yyyy-MM-dd") : null,
                HanThanhToan = h.HanThanhToan.HasValue ? h.HanThanhToan.Value.ToString("yyyy-MM-dd") : null,
                NgayThanhToan = h.NgayThanhToan.HasValue ? h.NgayThanhToan.Value.ToString("yyyy-MM-dd") : null,

                SoTaiKhoan = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.SoTaiKhoan : null,
                TenTaiKhoan = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.TenTaiKhoan : null,
                MaBin = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation.MaBin : null,
                TenVietTat = h.MaPhongNavigation != null && h.MaPhongNavigation.MaCoSoNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation != null
                    ? h.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.MaNganHangNavigation.TenVietTat : null,
            })
            .ToListAsync();

        return invoices;
    }

    public async Task<InvoiceDto?> GetInvoiceByIdAsync(int id)
    {
        var invoice = await _context.HoaDons
            .Include(h => h.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
            .Include(h => h.MaKhachNavigation)
            .FirstOrDefaultAsync(h => h.MaHoaDon == id);

        if (invoice == null) return null;

        return new InvoiceDto
        {
            MaHoaDon = invoice.MaHoaDon,
            MaPhong = invoice.MaPhong,
            MaKhach = invoice.MaKhach,
            TenPhong = invoice.MaPhongNavigation != null ? invoice.MaPhongNavigation.SoPhong : string.Empty,
            TenCoSo = invoice.MaPhongNavigation != null && invoice.MaPhongNavigation.MaCoSoNavigation != null
                ? invoice.MaPhongNavigation.MaCoSoNavigation.TenCoSo : string.Empty,
            TenKhachThue = invoice.MaKhachNavigation != null ? invoice.MaKhachNavigation.HoTen ?? string.Empty : string.Empty,
            Thang = invoice.Thang,
            Nam = invoice.Nam,
            SoDienCu = invoice.ChiSoDienCu,
            SoDienMoi = invoice.ChiSoDienMoi,
            SoNuocCu = invoice.ChiSoNuocCu,
            SoNuocMoi = invoice.ChiSoNuocMoi,
            DonGiaDien = invoice.DonGiaDien,
            DonGiaNuoc = invoice.DonGiaNuoc,
            TienPhong = invoice.TienPhong,
            TienDichVu = invoice.TienDichVu ?? 0,
            MoTaDichVu = invoice.MoTaDichVu,
            PhuPhi = invoice.PhuPhi ?? 0,
            MoTaPhuPhi = invoice.MoTaPhuPhi,
            TongTien = invoice.TongTien,
            TrangThai = invoice.TrangThai ?? "Chưa thanh toán",
            NgayLap = invoice.NgayLap.HasValue ? invoice.NgayLap.Value.ToString("yyyy-MM-dd") : null,
            HanThanhToan = invoice.HanThanhToan.HasValue ? invoice.HanThanhToan.Value.ToString("yyyy-MM-dd") : null,
            NgayThanhToan = invoice.NgayThanhToan.HasValue ? invoice.NgayThanhToan.Value.ToString("yyyy-MM-dd") : null,

            SoTaiKhoan = invoice.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.SoTaiKhoan,
            TenTaiKhoan = invoice.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.TenTaiKhoan,
            MaBin = invoice.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.MaNganHangNavigation?.MaBin,
            TenVietTat = invoice.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.MaNganHangNavigation?.TenVietTat,
        };
    }

    public async Task<InvoiceDto> CreateInvoiceAsync(InvoiceCreateDto createDto)
    {
        var phong = await _context.Phongs
            .Include(p => p.MaCoSoNavigation)
            .FirstOrDefaultAsync(p => p.MaPhong == createDto.MaPhong);
        if (phong == null)
        {
            throw new Exception("Không tìm thấy phòng.");
        }

        // Tự động tìm khách thuê nếu không truyền MaKhach
        int? maKhach = createDto.MaKhach;
        if (!maKhach.HasValue)
        {
            var hopDong = await _context.HopDongThues
                .Where(hd => hd.MaPhong == createDto.MaPhong && hd.TrangThai == "Đang hiệu lực")
                .FirstOrDefaultAsync();
            if (hopDong != null)
            {
                maKhach = hopDong.MaKhach;
            }
        }

        // Logic tính toán điện nước
        decimal tienDien = (decimal)(createDto.SoDienMoi - createDto.SoDienCu) * createDto.DonGiaDien;
        decimal tienNuoc = (decimal)(createDto.SoNuocMoi - createDto.SoNuocCu) * createDto.DonGiaNuoc;
        
        // Tổng tiền = Tiền phòng + Tiền điện + Tiền nước + Tiền dịch vụ + Phụ phí
        decimal tongTien = phong.GiaThue + tienDien + tienNuoc + createDto.TienDichVu + createDto.PhuPhi;

        var hoaDon = new HoaDon
        {
            MaPhong = createDto.MaPhong,
            MaKhach = maKhach,
            Thang = createDto.Thang,
            Nam = createDto.Nam,
            ChiSoDienCu = (int)createDto.SoDienCu,
            ChiSoDienMoi = (int)createDto.SoDienMoi,
            DonGiaDien = createDto.DonGiaDien,
            ChiSoNuocCu = (int)createDto.SoNuocCu,
            ChiSoNuocMoi = (int)createDto.SoNuocMoi,
            DonGiaNuoc = createDto.DonGiaNuoc,
            TienPhong = phong.GiaThue, // Lấy giá thuê từ thông tin phòng
            TienDichVu = createDto.TienDichVu,
            MoTaDichVu = createDto.MoTaDichVu,
            PhuPhi = createDto.PhuPhi,
            MoTaPhuPhi = createDto.MoTaPhuPhi,
            TongTien = tongTien,
            TrangThai = "Chưa thanh toán",
            NgayLap = DateOnly.FromDateTime(DateTime.Now),
            HanThanhToan = DateOnly.FromDateTime(DateTime.Now.AddDays(5))
        };

        _context.HoaDons.Add(hoaDon);
        await _context.SaveChangesAsync();

        // Đồng bộ hóa/Cập nhật hoặc Tạo mới bản ghi ChiSoDienNuoc để đánh dấu DaLapHoaDon = true
        var chiSo = await _context.ChiSoDienNuocs
            .FirstOrDefaultAsync(c => c.MaPhong == createDto.MaPhong && c.Thang == createDto.Thang && c.Nam == createDto.Nam);
        if (chiSo != null)
        {
            chiSo.DaLapHoaDon = true;
            chiSo.ChiSoDienCu = (int)createDto.SoDienCu;
            chiSo.ChiSoDienMoi = (int)createDto.SoDienMoi;
            chiSo.ChiSoNuocCu = (int)createDto.SoNuocCu;
            chiSo.ChiSoNuocMoi = (int)createDto.SoNuocMoi;
            chiSo.NgayCapNhat = DateTime.Now;
        }
        else
        {
            var newChiSo = new ChiSoDienNuoc
            {
                MaPhong = createDto.MaPhong,
                Thang = createDto.Thang,
                Nam = createDto.Nam,
                ChiSoDienCu = (int)createDto.SoDienCu,
                ChiSoDienMoi = (int)createDto.SoDienMoi,
                ChiSoNuocCu = (int)createDto.SoNuocCu,
                ChiSoNuocMoi = (int)createDto.SoNuocMoi,
                DaLapHoaDon = true,
                NgayCapNhat = DateTime.Now
            };
            _context.ChiSoDienNuocs.Add(newChiSo);
        }
        await _context.SaveChangesAsync();

        // Lấy tên khách thuê
        string tenKhach = string.Empty;
        if (maKhach.HasValue)
        {
            var khach = await _context.KhachThues.FindAsync(maKhach.Value);
            tenKhach = khach?.HoTen ?? string.Empty;
        }

        return new InvoiceDto
        {
            MaHoaDon = hoaDon.MaHoaDon,
            MaPhong = hoaDon.MaPhong,
            MaKhach = hoaDon.MaKhach,
            TenPhong = phong.SoPhong,
            TenCoSo = phong.MaCoSoNavigation?.TenCoSo ?? string.Empty,
            TenKhachThue = tenKhach,
            Thang = hoaDon.Thang,
            Nam = hoaDon.Nam,
            SoDienCu = hoaDon.ChiSoDienCu,
            SoDienMoi = hoaDon.ChiSoDienMoi,
            SoNuocCu = hoaDon.ChiSoNuocCu,
            SoNuocMoi = hoaDon.ChiSoNuocMoi,
            DonGiaDien = hoaDon.DonGiaDien,
            DonGiaNuoc = hoaDon.DonGiaNuoc,
            TienPhong = hoaDon.TienPhong,
            TienDichVu = hoaDon.TienDichVu ?? 0,
            MoTaDichVu = hoaDon.MoTaDichVu,
            PhuPhi = hoaDon.PhuPhi ?? 0,
            MoTaPhuPhi = hoaDon.MoTaPhuPhi,
            TongTien = hoaDon.TongTien,
            TrangThai = hoaDon.TrangThai ?? "Chưa thanh toán",
            NgayLap = hoaDon.NgayLap.HasValue ? hoaDon.NgayLap.Value.ToString("yyyy-MM-dd") : null,
            HanThanhToan = hoaDon.HanThanhToan.HasValue ? hoaDon.HanThanhToan.Value.ToString("yyyy-MM-dd") : null,
            NgayThanhToan = null,

            SoTaiKhoan = phong.MaCoSoNavigation?.MaQuanLyNavigation?.SoTaiKhoan,
            TenTaiKhoan = phong.MaCoSoNavigation?.MaQuanLyNavigation?.TenTaiKhoan,
            MaBin = phong.MaCoSoNavigation?.MaQuanLyNavigation?.MaNganHangNavigation?.MaBin,
            TenVietTat = phong.MaCoSoNavigation?.MaQuanLyNavigation?.MaNganHangNavigation?.TenVietTat,
        };
    }

    public async Task<bool> UpdateInvoiceStatusAsync(int id, InvoiceUpdateStatusDto updateDto)
    {
        var invoice = await _context.HoaDons.FindAsync(id);
        if (invoice == null) return false;

        invoice.TrangThai = updateDto.TrangThai;

        // Nếu trạng thái là "Đã thanh toán", ghi nhận ngày thanh toán
        if (updateDto.TrangThai == "Đã thanh toán")
        {
            invoice.NgayThanhToan = DateOnly.FromDateTime(DateTime.Now);
        }

        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> UpdateInvoiceAsync(int id, InvoiceUpdateDto updateDto)
    {
        var invoice = await _context.HoaDons.FindAsync(id);
        if (invoice == null) return false;

        invoice.ChiSoDienMoi = (int)updateDto.SoDienMoi;
        invoice.ChiSoNuocMoi = (int)updateDto.SoNuocMoi;
        invoice.PhuPhi = updateDto.PhuPhi;
        invoice.MoTaPhuPhi = updateDto.MoTaPhuPhi;

        // Recalculate total amount
        int soDienTieuThu = invoice.ChiSoDienMoi - invoice.ChiSoDienCu;
        int soNuocTieuThu = invoice.ChiSoNuocMoi - invoice.ChiSoNuocCu;
        decimal tienDien = (decimal)soDienTieuThu * invoice.DonGiaDien;
        decimal tienNuoc = (decimal)soNuocTieuThu * invoice.DonGiaNuoc;
        
        invoice.TongTien = invoice.TienPhong + tienDien + tienNuoc + (invoice.TienDichVu ?? 0) + (invoice.PhuPhi ?? 0);

        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteInvoiceAsync(int id)
    {
        var invoice = await _context.HoaDons.FindAsync(id);
        if (invoice == null) return false;

        _context.HoaDons.Remove(invoice);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> VerifyCustomerOwnershipAsync(int maKhach, int maQuanLy)
    {
        return await _context.HopDongThues
            .Include(hd => hd.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
            .AnyAsync(hd => hd.MaKhach == maKhach && hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy);
    }

    public async Task<bool> VerifyInvoiceOwnershipAsync(int maHoaDon, int maQuanLy)
    {
        return await _context.HoaDons
            .Include(h => h.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
            .AnyAsync(h => h.MaHoaDon == maHoaDon && h.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy);
    }

    public async Task<bool> VerifyRoomOwnershipAsync(int maPhong, int maQuanLy)
    {
        return await _context.Phongs
            .Include(p => p.MaCoSoNavigation)
            .AnyAsync(p => p.MaPhong == maPhong && p.MaCoSoNavigation.MaQuanLy == maQuanLy);
    }
}
