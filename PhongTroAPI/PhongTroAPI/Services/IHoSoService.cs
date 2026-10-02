using PhongTroAPI.DTOs;

namespace PhongTroAPI.Services
{
    /// <summary>
    /// Interface định nghĩa business logic cho API hồ sơ cá nhân.
    /// Chứa authorization check theo userId lấy từ JWT claim và ánh xạ Entity → DTO.
    /// </summary>
    public interface IHoSoService
    {
        // ── Khách Thuê tự thao tác hồ sơ bản thân ───────────────────────

        /// <summary>
        /// Lấy hồ sơ cá nhân của Khách Thuê đang đăng nhập.
        /// Service sẽ xác thực xem <paramref name="maKhachClaim"/> có hợp lệ không.
        /// </summary>
        /// <param name="maKhachClaim">Giá trị claim "MaKhach" lấy từ JWT token.</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// <see cref="HoSoDto"/> nếu thành công;
        /// hoặc ném <see cref="UnauthorizedAccessException"/> nếu claim không hợp lệ;
        /// hoặc ném <see cref="KeyNotFoundException"/> nếu không tìm thấy hồ sơ.
        /// </returns>
        Task<HoSoDto> LayHoSoBanThanAsync(string? maKhachClaim, CancellationToken cancellationToken = default);

        /// <summary>
        /// Khách Thuê cập nhật hồ sơ cá nhân của chính mình.
        /// </summary>
        /// <param name="maKhachClaim">Giá trị claim "MaKhach" lấy từ JWT token.</param>
        /// <param name="request">Dữ liệu cần cập nhật.</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// <see cref="HoSoDto"/> sau khi cập nhật thành công;
        /// hoặc ném exception tương ứng nếu thất bại.
        /// </returns>
        Task<HoSoDto> CapNhatHoSoBanThanAsync(string? maKhachClaim, CapNhatHoSoRequest request, CancellationToken cancellationToken = default);

        // ── Admin thao tác hồ sơ bất kỳ ─────────────────────────────────

        /// <summary>
        /// Admin xem hồ sơ của tài khoản bất kỳ theo MaTaiKhoan.
        /// Service sẽ tự động xác định vai trò (KhachThue / NguoiQuanLy) của tài khoản đó.
        /// </summary>
        /// <param name="maTaiKhoan">Mã tài khoản của người cần xem hồ sơ.</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// <see cref="HoSoDto"/> nếu tìm thấy;
        /// hoặc ném <see cref="KeyNotFoundException"/> nếu tài khoản không tồn tại.
        /// </returns>
        Task<HoSoDto> AdminLayHoSoTheoIdAsync(int maTaiKhoan, CancellationToken cancellationToken = default);

        /// <summary>
        /// Admin cập nhật hồ sơ của tài khoản bất kỳ theo MaTaiKhoan.
        /// Service tự động phân biệt vai trò để cập nhật đúng bảng.
        /// </summary>
        /// <param name="maTaiKhoan">Mã tài khoản của người cần cập nhật hồ sơ.</param>
        /// <param name="request">Dữ liệu cần cập nhật (Admin request).</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// <see cref="HoSoDto"/> sau khi cập nhật thành công;
        /// hoặc ném exception tương ứng nếu thất bại.
        /// </returns>
        Task<HoSoDto> AdminCapNhatHoSoTheoIdAsync(int maTaiKhoan, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default);
    }
}
