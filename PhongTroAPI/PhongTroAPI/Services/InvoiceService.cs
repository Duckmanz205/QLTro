using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;

namespace PhongTroAPI.Services;

public class InvoiceService : IInvoiceService
{
    private readonly HoaDonRepository _hoaDonRepo;
    private readonly PhongRepository _phongRepo;
    private readonly CoSoRepository _coSoRepo;
    private readonly KhachThueRepository _khachThueRepo;
    private readonly HopDongRepository _hopDongRepo;
    private readonly ChiSoRepository _chiSoRepo;
    private readonly NguoiQuanLyRepository _quanLyRepo;
    private readonly NganHangRepository _nganHangRepo;
    private readonly CounterRepository _counterRepo;

    public InvoiceService(
        HoaDonRepository hoaDonRepo,
        PhongRepository phongRepo,
        CoSoRepository coSoRepo,
        KhachThueRepository khachThueRepo,
        HopDongRepository hopDongRepo,
        ChiSoRepository chiSoRepo,
        NguoiQuanLyRepository quanLyRepo,
        NganHangRepository nganHangRepo,
        CounterRepository counterRepo)
    {
        _hoaDonRepo = hoaDonRepo;
        _phongRepo = phongRepo;
        _coSoRepo = coSoRepo;
        _khachThueRepo = khachThueRepo;
        _hopDongRepo = hopDongRepo;
        _chiSoRepo = chiSoRepo;
        _quanLyRepo = quanLyRepo;
        _nganHangRepo = nganHangRepo;
        _counterRepo = counterRepo;
    }

    public async Task<List<InvoiceDto>> GetInvoicesAsync(int? month, int? year, int? maQuanLy = null)
    {
        var allInvoices = await _hoaDonRepo.GetAllAsync();
        
        if (month.HasValue && year.HasValue)
        {
            allInvoices = allInvoices.Where(h => h.Thang == month.Value && h.Nam == year.Value).ToList();
        }

        var result = new List<InvoiceDto>();
        foreach (var h in allInvoices)
        {
            var p = await _phongRepo.GetByIdAsync(h.MaPhong);
            var c = p != null ? await _coSoRepo.GetByIdAsync(p.MaCoSo) : null;
            
            if (maQuanLy.HasValue)
            {
                if (c == null || c.MaQuanLy != maQuanLy.Value) continue;
            }

            var k = h.MaKhach.HasValue ? await _khachThueRepo.GetByIdAsync(h.MaKhach.Value) : null;
            var ql = c?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(c.MaQuanLy.Value) : null;

            result.Add(new InvoiceDto
            {
                MaHoaDon = h.MaHoaDon,
                MaPhong = h.MaPhong,
                MaKhach = h.MaKhach,
                TenPhong = p?.SoPhong ?? string.Empty,
                TenCoSo = c?.TenCoSo ?? string.Empty,
                TenKhachThue = k?.HoTen ?? string.Empty,
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
                SoTaiKhoan = ql?.ThongTinNganHang?.SoTaiKhoan,
                TenTaiKhoan = ql?.ThongTinNganHang?.ChuTaiKhoan,
                MaBin = ql?.ThongTinNganHang?.MaNganHang.ToString(),
                TenVietTat = ""
            });
        }

        return result.OrderByDescending(h => h.Nam)
                     .ThenByDescending(h => h.Thang)
                     .ThenByDescending(h => h.MaHoaDon).ToList();
    }

    public async Task<List<InvoiceDto>> GetInvoicesByCustomerAsync(int maKhach)
    {
        var allInvoices = await _hoaDonRepo.GetAllAsync();
        var customerInvoices = allInvoices.Where(h => h.MaKhach == maKhach).ToList();

        var result = new List<InvoiceDto>();
        foreach (var h in customerInvoices)
        {
            var p = await _phongRepo.GetByIdAsync(h.MaPhong);
            var c = p != null ? await _coSoRepo.GetByIdAsync(p.MaCoSo) : null;
            var k = await _khachThueRepo.GetByIdAsync(maKhach);
            var ql = c?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(c.MaQuanLy.Value) : null;

            result.Add(new InvoiceDto
            {
                MaHoaDon = h.MaHoaDon,
                MaPhong = h.MaPhong,
                MaKhach = h.MaKhach,
                TenPhong = p?.SoPhong ?? string.Empty,
                TenCoSo = c?.TenCoSo ?? string.Empty,
                TenKhachThue = k?.HoTen ?? string.Empty,
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
                SoTaiKhoan = ql?.ThongTinNganHang?.SoTaiKhoan,
                TenTaiKhoan = ql?.ThongTinNganHang?.ChuTaiKhoan,
                MaBin = ql?.ThongTinNganHang?.MaNganHang.ToString(),
                TenVietTat = ""
            });
        }

        return result.OrderByDescending(h => h.Nam)
                     .ThenByDescending(h => h.Thang)
                     .ThenByDescending(h => h.MaHoaDon).ToList();
    }

    public async Task<InvoiceDto?> GetInvoiceByIdAsync(int id)
    {
        var h = await _hoaDonRepo.GetByIdAsync(id);
        if (h == null) return null;

        var p = await _phongRepo.GetByIdAsync(h.MaPhong);
        var c = p != null ? await _coSoRepo.GetByIdAsync(p.MaCoSo) : null;
        var k = h.MaKhach.HasValue ? await _khachThueRepo.GetByIdAsync(h.MaKhach.Value) : null;
        var ql = c?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(c.MaQuanLy.Value) : null;

        return new InvoiceDto
        {
            MaHoaDon = h.MaHoaDon,
            MaPhong = h.MaPhong,
            MaKhach = h.MaKhach,
            TenPhong = p?.SoPhong ?? string.Empty,
            TenCoSo = c?.TenCoSo ?? string.Empty,
            TenKhachThue = k?.HoTen ?? string.Empty,
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
            SoTaiKhoan = ql?.ThongTinNganHang?.SoTaiKhoan,
            TenTaiKhoan = ql?.ThongTinNganHang?.ChuTaiKhoan,
            MaBin = ql?.ThongTinNganHang?.MaNganHang.ToString(),
            TenVietTat = ""
        };
    }

    public async Task<InvoiceDto> CreateInvoiceAsync(InvoiceCreateDto createDto)
    {
        var phong = await _phongRepo.GetByIdAsync(createDto.MaPhong);
        if (phong == null) throw new Exception("Không tìm thấy phòng.");
        
        var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);

        int? maKhach = createDto.MaKhach;
        if (!maKhach.HasValue)
        {
            var hopDongs = await _hopDongRepo.GetAllAsync();
            var hopDong = hopDongs.FirstOrDefault(hd => hd.MaPhong == createDto.MaPhong && hd.TrangThai == "Đang hiệu lực");
            if (hopDong != null)
            {
                maKhach = hopDong.MaKhach;
            }
        }

        decimal tienDien = (decimal)(createDto.SoDienMoi - createDto.SoDienCu) * createDto.DonGiaDien;
        decimal tienNuoc = (decimal)(createDto.SoNuocMoi - createDto.SoNuocCu) * createDto.DonGiaNuoc;
        decimal tongTien = phong.GiaThue + tienDien + tienNuoc + createDto.TienDichVu + createDto.PhuPhi;

        int newId = await _counterRepo.GetNextSequenceValueAsync("hoadon_id");

        var hoaDon = new HoaDon
        {
            MaHoaDon = newId,
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
            TienPhong = phong.GiaThue,
            TienDichVu = createDto.TienDichVu,
            MoTaDichVu = createDto.MoTaDichVu,
            PhuPhi = createDto.PhuPhi,
            MoTaPhuPhi = createDto.MoTaPhuPhi,
            TongTien = tongTien,
            TrangThai = "Chưa thanh toán",
            NgayLap = DateOnly.FromDateTime(DateTime.Now),
            HanThanhToan = DateOnly.FromDateTime(DateTime.Now.AddDays(5))
        };

        await _hoaDonRepo.CreateAsync(hoaDon);

        var chiSos = await _chiSoRepo.GetAllAsync();
        var chiSo = chiSos.FirstOrDefault(c => c.MaPhong == createDto.MaPhong && c.Thang == createDto.Thang && c.Nam == createDto.Nam);
        
        if (chiSo != null)
        {
            chiSo.DaLapHoaDon = true;
            chiSo.ChiSoDienCu = (int)createDto.SoDienCu;
            chiSo.ChiSoDienMoi = (int)createDto.SoDienMoi;
            chiSo.ChiSoNuocCu = (int)createDto.SoNuocCu;
            chiSo.ChiSoNuocMoi = (int)createDto.SoNuocMoi;
            chiSo.NgayCapNhat = DateTime.Now;
            await _chiSoRepo.UpdateAsync(chiSo.MaChiSo, chiSo);
        }
        else
        {
            var newChiSo = new ChiSoDienNuoc
            {
                MaChiSo = await _counterRepo.GetNextSequenceValueAsync("chisodiennuoc_id"),
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
            await _chiSoRepo.CreateAsync(newChiSo);
        }

        string tenKhach = string.Empty;
        if (maKhach.HasValue)
        {
            var khach = await _khachThueRepo.GetByIdAsync(maKhach.Value);
            tenKhach = khach?.HoTen ?? string.Empty;
        }

        var ql = coSo?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(coSo.MaQuanLy.Value) : null;

        return new InvoiceDto
        {
            MaHoaDon = hoaDon.MaHoaDon,
            MaPhong = hoaDon.MaPhong,
            MaKhach = hoaDon.MaKhach,
            TenPhong = phong.SoPhong,
            TenCoSo = coSo?.TenCoSo ?? string.Empty,
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
            TrangThai = hoaDon.TrangThai,
            NgayLap = hoaDon.NgayLap.HasValue ? hoaDon.NgayLap.Value.ToString("yyyy-MM-dd") : null,
            HanThanhToan = hoaDon.HanThanhToan.HasValue ? hoaDon.HanThanhToan.Value.ToString("yyyy-MM-dd") : null,
            SoTaiKhoan = ql?.ThongTinNganHang?.SoTaiKhoan,
            TenTaiKhoan = ql?.ThongTinNganHang?.ChuTaiKhoan,
            MaBin = ql?.ThongTinNganHang?.MaNganHang.ToString(),
            TenVietTat = ""
        };
    }

    public async Task<bool> UpdateInvoiceStatusAsync(int id, InvoiceUpdateStatusDto updateDto)
    {
        var invoice = await _hoaDonRepo.GetByIdAsync(id);
        if (invoice == null) return false;

        invoice.TrangThai = updateDto.TrangThai;
        if (updateDto.TrangThai == "Đã thanh toán")
        {
            invoice.NgayThanhToan = DateOnly.FromDateTime(DateTime.Now);
        }

        await _hoaDonRepo.UpdateAsync(id, invoice);
        return true;
    }

    public async Task<bool> UpdateInvoiceAsync(int id, InvoiceUpdateDto updateDto)
    {
        var invoice = await _hoaDonRepo.GetByIdAsync(id);
        if (invoice == null) return false;

        invoice.ChiSoDienMoi = (int)updateDto.SoDienMoi;
        invoice.ChiSoNuocMoi = (int)updateDto.SoNuocMoi;
        invoice.PhuPhi = updateDto.PhuPhi;
        invoice.MoTaPhuPhi = updateDto.MoTaPhuPhi;

        int soDienTieuThu = invoice.ChiSoDienMoi - invoice.ChiSoDienCu;
        int soNuocTieuThu = invoice.ChiSoNuocMoi - invoice.ChiSoNuocCu;
        decimal tienDien = (decimal)soDienTieuThu * invoice.DonGiaDien;
        decimal tienNuoc = (decimal)soNuocTieuThu * invoice.DonGiaNuoc;
        
        invoice.TongTien = invoice.TienPhong + tienDien + tienNuoc + (invoice.TienDichVu ?? 0) + (invoice.PhuPhi ?? 0);

        await _hoaDonRepo.UpdateAsync(id, invoice);
        return true;
    }

    public async Task<bool> DeleteInvoiceAsync(int id)
    {
        await _hoaDonRepo.DeleteAsync(id);
        return true;
    }

    public async Task<bool> VerifyCustomerOwnershipAsync(int maKhach, int maQuanLy)
    {
        var hopDongs = await _hopDongRepo.GetAllAsync();
        foreach (var hd in hopDongs.Where(h => h.MaKhach == maKhach))
        {
            var phong = await _phongRepo.GetByIdAsync(hd.MaPhong);
            if (phong != null)
            {
                var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
                if (coSo != null && coSo.MaQuanLy == maQuanLy)
                {
                    return true;
                }
            }
        }
        return false;
    }

    public async Task<bool> VerifyInvoiceOwnershipAsync(int maHoaDon, int maQuanLy)
    {
        var hd = await _hoaDonRepo.GetByIdAsync(maHoaDon);
        if (hd == null) return false;
        var phong = await _phongRepo.GetByIdAsync(hd.MaPhong);
        if (phong != null)
        {
            var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (coSo != null && coSo.MaQuanLy == maQuanLy)
            {
                return true;
            }
        }
        return false;
    }

    public async Task<bool> VerifyRoomOwnershipAsync(int maPhong, int maQuanLy)
    {
        var phong = await _phongRepo.GetByIdAsync(maPhong);
        if (phong != null)
        {
            var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (coSo != null && coSo.MaQuanLy == maQuanLy)
            {
                return true;
            }
        }
        return false;
    }
}
