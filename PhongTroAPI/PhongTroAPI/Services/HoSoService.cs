using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace PhongTroAPI.Services
{
    public class HoSoService : IHoSoService
    {
        private readonly TaiKhoanRepository _taiKhoanRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly NguoiQuanLyRepository _nguoiQuanLyRepo;

        public HoSoService(
            TaiKhoanRepository taiKhoanRepo,
            KhachThueRepository khachThueRepo,
            NguoiQuanLyRepository nguoiQuanLyRepo)
        {
            _taiKhoanRepo = taiKhoanRepo;
            _khachThueRepo = khachThueRepo;
            _nguoiQuanLyRepo = nguoiQuanLyRepo;
        }

        public async Task<HoSoDto> LayHoSoBanThanAsync(string? maKhachClaim, CancellationToken cancellationToken = default)
        {
            int maKhach = ParseMaKhachClaim(maKhachClaim);
            var entity = await _khachThueRepo.GetByIdAsync(maKhach);
            if (entity is null)
                throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê với mã {maKhach}.");

            return MapKhachThueToDto(entity);
        }

        public async Task<HoSoDto> CapNhatHoSoBanThanAsync(string? maKhachClaim, CapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            int maKhach = ParseMaKhachClaim(maKhachClaim);
            var entity = await _khachThueRepo.GetByIdAsync(maKhach);
            if (entity is null)
                throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê với mã {maKhach} để cập nhật.");

            entity.HoTen = request.HoTen ?? entity.HoTen;
            entity.Sdt = request.Sdt ?? entity.Sdt;
            entity.Email = request.Email ?? entity.Email;
            entity.Cccd = request.Cccd ?? entity.Cccd;
            entity.GioiTinh = request.GioiTinh ?? entity.GioiTinh;
            entity.NgaySinh = request.NgaySinh ?? entity.NgaySinh;
            entity.DiaChiThuongTru = request.DiaChiThuongTru ?? entity.DiaChiThuongTru;
            entity.NgayCapCccd = request.NgayCapCccd ?? entity.NgayCapCccd;
            entity.NoiCapCccd = request.NoiCapCccd ?? entity.NoiCapCccd;

            await _khachThueRepo.UpdateAsync(maKhach, entity);

            return MapKhachThueToDto(entity);
        }

        public async Task<HoSoDto> AdminLayHoSoTheoIdAsync(int maTaiKhoan, CancellationToken cancellationToken = default)
        {
            var tk = await _taiKhoanRepo.GetByIdAsync(maTaiKhoan);
            if (tk == null) throw new KeyNotFoundException($"Không tìm thấy tài khoản với mã {maTaiKhoan}.");

            if (tk.VaiTro == "KhachThue" && tk.MaKhach.HasValue)
            {
                var khach = await _khachThueRepo.GetByIdAsync(tk.MaKhach.Value);
                if (khach is null) throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê liên kết với tài khoản {maTaiKhoan}.");
                return MapKhachThueToDto(khach);
            }
            if (tk.VaiTro == "NguoiQuanLy" && tk.MaQuanLy.HasValue)
            {
                var quanLy = await _nguoiQuanLyRepo.GetByIdAsync(tk.MaQuanLy.Value);
                if (quanLy is null) throw new KeyNotFoundException($"Không tìm thấy hồ sơ người quản lý liên kết với tài khoản {maTaiKhoan}.");
                return MapNguoiQuanLyToDto(quanLy);
            }

            throw new InvalidOperationException($"Tài khoản {maTaiKhoan} có vai trò '{tk.VaiTro}' nhưng thiếu khóa ngoại tương ứng.");
        }

        public async Task<HoSoDto> AdminCapNhatHoSoTheoIdAsync(int maTaiKhoan, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            var tk = await _taiKhoanRepo.GetByIdAsync(maTaiKhoan);
            if (tk == null) throw new KeyNotFoundException($"Không tìm thấy tài khoản với mã {maTaiKhoan}.");

            if (tk.VaiTro == "KhachThue" && tk.MaKhach.HasValue)
            {
                var khach = await _khachThueRepo.GetByIdAsync(tk.MaKhach.Value);
                if (khach == null) throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê mã {tk.MaKhach} để cập nhật.");
                
                khach.HoTen = request.HoTen ?? khach.HoTen;
                khach.Sdt = request.Sdt ?? khach.Sdt;
                khach.Email = request.Email ?? khach.Email;
                khach.TrangThai = request.TrangThai ?? khach.TrangThai;
                khach.Cccd = request.Cccd ?? khach.Cccd;
                khach.GioiTinh = request.GioiTinh ?? khach.GioiTinh;
                khach.NgaySinh = request.NgaySinh ?? khach.NgaySinh;
                khach.DiaChiThuongTru = request.DiaChiThuongTru ?? khach.DiaChiThuongTru;
                khach.NgayCapCccd = request.NgayCapCccd ?? khach.NgayCapCccd;
                khach.NoiCapCccd = request.NoiCapCccd ?? khach.NoiCapCccd;

                await _khachThueRepo.UpdateAsync(tk.MaKhach.Value, khach);
                return MapKhachThueToDto(khach);
            }
            if (tk.VaiTro == "NguoiQuanLy" && tk.MaQuanLy.HasValue)
            {
                var quanLy = await _nguoiQuanLyRepo.GetByIdAsync(tk.MaQuanLy.Value);
                if (quanLy == null) throw new KeyNotFoundException($"Không tìm thấy hồ sơ người quản lý mã {tk.MaQuanLy} để cập nhật.");
                
                quanLy.HoTen = request.HoTen ?? quanLy.HoTen;
                quanLy.Sdt = request.Sdt ?? quanLy.Sdt;
                quanLy.Email = request.Email ?? quanLy.Email;
                quanLy.TrangThai = request.TrangThai ?? quanLy.TrangThai;

                await _nguoiQuanLyRepo.UpdateAsync(tk.MaQuanLy.Value, quanLy);
                return MapNguoiQuanLyToDto(quanLy);
            }

            throw new InvalidOperationException($"Tài khoản {maTaiKhoan} có vai trò '{tk.VaiTro}' nhưng thiếu khóa ngoại tương ứng.");
        }

        private static int ParseMaKhachClaim(string? maKhachClaim)
        {
            if (!int.TryParse(maKhachClaim, out int maKhach) || maKhach <= 0)
                throw new UnauthorizedAccessException("Token không chứa claim 'MaKhach' hợp lệ. Vui lòng đăng nhập lại.");
            return maKhach;
        }

        private static HoSoDto MapKhachThueToDto(KhachThue entity) => new()
        {
            MaHoSo = entity.MaKhach,
            VaiTro = "KhachThue",
            HoTen = entity.HoTen,
            Sdt = entity.Sdt,
            Email = entity.Email,
            TrangThai = entity.TrangThai,
            Cccd = entity.Cccd,
            NgaySinh = entity.NgaySinh,
            GioiTinh = entity.GioiTinh,
            DiaChiThuongTru = entity.DiaChiThuongTru,
            NgayCapCccd = entity.NgayCapCccd,
            NoiCapCccd = entity.NoiCapCccd,
            SoTaiKhoan = null,
            TenTaiKhoan = null,
            MaNganHang = null,
            NgayTao = null
        };

        private static HoSoDto MapNguoiQuanLyToDto(NguoiQuanLy entity) => new()
        {
            MaHoSo = entity.MaQuanLy,
            VaiTro = "NguoiQuanLy",
            HoTen = entity.HoTen,
            Sdt = entity.Sdt,
            Email = entity.Email,
            TrangThai = entity.TrangThai,
            SoTaiKhoan = entity.ThongTinNganHang?.SoTaiKhoan,
            TenTaiKhoan = entity.ThongTinNganHang?.ChuTaiKhoan,
            MaNganHang = entity.ThongTinNganHang?.MaNganHang,
            NgayTao = entity.NgayTao,
            Cccd = null,
            NgaySinh = null,
            GioiTinh = null,
            DiaChiThuongTru = null,
            NgayCapCccd = null,
            NoiCapCccd = null
        };
    }
}
