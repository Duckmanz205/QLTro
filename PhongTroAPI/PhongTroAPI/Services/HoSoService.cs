using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories;

namespace PhongTroAPI.Services
{
    /// <summary>
    /// Triển khai <see cref="IHoSoService"/>.
    /// Chứa toàn bộ business logic: xác thực claim, phân biệt vai trò, ánh xạ Entity → DTO.
    /// </summary>
    public class HoSoService : IHoSoService
    {
        private readonly IHoSoRepository _repo;

        /// <summary>
        /// Khởi tạo service với repository được inject từ DI container.
        /// </summary>
        /// <param name="repo">Repository truy cập dữ liệu hồ sơ.</param>
        public HoSoService(IHoSoRepository repo)
        {
            _repo = repo;
        }

        // ────────────────────────────────────────────────────────────────
        // KHÁCH THUÊ TỰ THAO TÁC HỒ SƠ BẢN THÂN
        // ────────────────────────────────────────────────────────────────

        /// <inheritdoc/>
        public async Task<HoSoDto> LayHoSoBanThanAsync(string? maKhachClaim, CancellationToken cancellationToken = default)
        {
            int maKhach = ParseMaKhachClaim(maKhachClaim);

            var entity = await _repo.LayHoSoKhachThueAsync(maKhach, cancellationToken);
            if (entity is null)
                throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê với mã {maKhach}.");

            return MapKhachThueToDto(entity);
        }

        /// <inheritdoc/>
        public async Task<HoSoDto> CapNhatHoSoBanThanAsync(string? maKhachClaim, CapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            int maKhach = ParseMaKhachClaim(maKhachClaim);

            bool updated = await _repo.CapNhatHoSoKhachThueAsync(maKhach, request, cancellationToken);
            if (!updated)
                throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê với mã {maKhach} để cập nhật.");

            // Đọc lại dữ liệu mới nhất từ DB để trả về response chính xác
            var entity = await _repo.LayHoSoKhachThueAsync(maKhach, cancellationToken);
            return MapKhachThueToDto(entity!);
        }

        // ────────────────────────────────────────────────────────────────
        // ADMIN THAO TÁC HỒ SƠ BẤT KỲ
        // ────────────────────────────────────────────────────────────────

        /// <inheritdoc/>
        public async Task<HoSoDto> AdminLayHoSoTheoIdAsync(int maTaiKhoan, CancellationToken cancellationToken = default)
        {
            var vaiTroInfo = await _repo.LayVaiTroTaiKhoanAsync(maTaiKhoan, cancellationToken);
            if (vaiTroInfo is null)
                throw new KeyNotFoundException($"Không tìm thấy tài khoản với mã {maTaiKhoan}.");

            var (vaiTro, maKhach, maQuanLy) = vaiTroInfo.Value;

            // Phân biệt và lấy đúng bảng theo vai trò
            if (vaiTro == "KhachThue" && maKhach.HasValue)
            {
                var khach = await _repo.LayHoSoKhachThueAsync(maKhach.Value, cancellationToken);
                if (khach is null)
                    throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê liên kết với tài khoản {maTaiKhoan}.");
                return MapKhachThueToDto(khach);
            }

            if (vaiTro == "NguoiQuanLy" && maQuanLy.HasValue)
            {
                var quanLy = await _repo.LayHoSoNguoiQuanLyAsync(maQuanLy.Value, cancellationToken);
                if (quanLy is null)
                    throw new KeyNotFoundException($"Không tìm thấy hồ sơ người quản lý liên kết với tài khoản {maTaiKhoan}.");
                return MapNguoiQuanLyToDto(quanLy);
            }

            // Trường hợp dữ liệu không nhất quán (VaiTro có nhưng FK null)
            throw new InvalidOperationException(
                $"Tài khoản {maTaiKhoan} có vai trò '{vaiTro}' nhưng thiếu khóa ngoại tương ứng. Dữ liệu có thể bị lỗi.");
        }

        /// <inheritdoc/>
        public async Task<HoSoDto> AdminCapNhatHoSoTheoIdAsync(int maTaiKhoan, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            var vaiTroInfo = await _repo.LayVaiTroTaiKhoanAsync(maTaiKhoan, cancellationToken);
            if (vaiTroInfo is null)
                throw new KeyNotFoundException($"Không tìm thấy tài khoản với mã {maTaiKhoan}.");

            var (vaiTro, maKhach, maQuanLy) = vaiTroInfo.Value;

            if (vaiTro == "KhachThue" && maKhach.HasValue)
            {
                bool ok = await _repo.AdminCapNhatHoSoKhachThueAsync(maKhach.Value, request, cancellationToken);
                if (!ok)
                    throw new KeyNotFoundException($"Không tìm thấy hồ sơ khách thuê mã {maKhach} để cập nhật.");

                var entity = await _repo.LayHoSoKhachThueAsync(maKhach.Value, cancellationToken);
                return MapKhachThueToDto(entity!);
            }

            if (vaiTro == "NguoiQuanLy" && maQuanLy.HasValue)
            {
                bool ok = await _repo.AdminCapNhatHoSoNguoiQuanLyAsync(maQuanLy.Value, request, cancellationToken);
                if (!ok)
                    throw new KeyNotFoundException($"Không tìm thấy hồ sơ người quản lý mã {maQuanLy} để cập nhật.");

                var entity = await _repo.LayHoSoNguoiQuanLyAsync(maQuanLy.Value, cancellationToken);
                return MapNguoiQuanLyToDto(entity!);
            }

            throw new InvalidOperationException(
                $"Tài khoản {maTaiKhoan} có vai trò '{vaiTro}' nhưng thiếu khóa ngoại tương ứng. Dữ liệu có thể bị lỗi.");
        }

        // ────────────────────────────────────────────────────────────────
        // PRIVATE HELPERS
        // ────────────────────────────────────────────────────────────────

        /// <summary>
        /// Phân tích chuỗi claim "MaKhach" thành int.
        /// Ném <see cref="UnauthorizedAccessException"/> nếu claim null hoặc không phải số nguyên.
        /// </summary>
        private static int ParseMaKhachClaim(string? maKhachClaim)
        {
            if (!int.TryParse(maKhachClaim, out int maKhach) || maKhach <= 0)
                throw new UnauthorizedAccessException(
                    "Token không chứa claim 'MaKhach' hợp lệ. Vui lòng đăng nhập lại.");
            return maKhach;
        }

        /// <summary>
        /// Ánh xạ entity <see cref="KhachThue"/> sang <see cref="HoSoDto"/>.
        /// </summary>
        private static HoSoDto MapKhachThueToDto(KhachThue entity) => new()
        {
            MaHoSo           = entity.MaKhach,
            VaiTro           = "KhachThue",
            HoTen            = entity.HoTen,
            Sdt              = entity.Sdt,
            Email            = entity.Email,
            TrangThai        = entity.TrangThai,
            Cccd             = entity.Cccd,
            NgaySinh         = entity.NgaySinh,
            GioiTinh         = entity.GioiTinh,
            DiaChiThuongTru  = entity.DiaChiThuongTru,
            NgayCapCccd      = entity.NgayCapCccd,
            NoiCapCccd       = entity.NoiCapCccd,
            // Các trường NguoiQuanLy giữ null
            SoTaiKhoan  = null,
            TenTaiKhoan = null,
            MaNganHang  = null,
            NgayTao     = null
        };

        /// <summary>
        /// Ánh xạ entity <see cref="NguoiQuanLy"/> sang <see cref="HoSoDto"/>.
        /// </summary>
        private static HoSoDto MapNguoiQuanLyToDto(NguoiQuanLy entity) => new()
        {
            MaHoSo      = entity.MaQuanLy,
            VaiTro      = "NguoiQuanLy",
            HoTen       = entity.HoTen,
            Sdt         = entity.Sdt,
            Email       = entity.Email,
            TrangThai   = entity.TrangThai,
            SoTaiKhoan  = entity.SoTaiKhoan,
            TenTaiKhoan = entity.TenTaiKhoan,
            MaNganHang  = entity.MaNganHang,
            NgayTao     = entity.NgayTao,
            // Các trường KhachThue giữ null
            Cccd            = null,
            NgaySinh        = null,
            GioiTinh        = null,
            DiaChiThuongTru = null,
            NgayCapCccd     = null,
            NoiCapCccd      = null
        };
    }
}
