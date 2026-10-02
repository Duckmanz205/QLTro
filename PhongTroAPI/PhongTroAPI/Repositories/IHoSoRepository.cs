using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Repositories
{
    /// <summary>
    /// Interface định nghĩa các thao tác dữ liệu cho hồ sơ cá nhân,
    /// tách biệt việc truy cập DB ra khỏi business logic trong Service layer.
    /// </summary>
    public interface IHoSoRepository
    {
        // ── Khách Thuê ───────────────────────────────────────────────────

        /// <summary>
        /// Lấy thông tin hồ sơ của một Khách Thuê theo mã định danh.
        /// </summary>
        /// <param name="maKhach">Mã khách thuê (MaKhach).</param>
        /// <param name="cancellationToken">Token huỷ thao tác bất đồng bộ.</param>
        /// <returns>Entity <see cref="KhachThue"/> nếu tìm thấy; null nếu không tồn tại.</returns>
        Task<KhachThue?> LayHoSoKhachThueAsync(int maKhach, CancellationToken cancellationToken = default);

        /// <summary>
        /// Cập nhật thông tin hồ sơ của một Khách Thuê.
        /// </summary>
        /// <param name="maKhach">Mã khách thuê cần cập nhật.</param>
        /// <param name="request">Dữ liệu cập nhật từ phía Khách Thuê.</param>
        /// <param name="cancellationToken">Token huỷ thao tác bất đồng bộ.</param>
        /// <returns>true nếu cập nhật thành công; false nếu không tìm thấy bản ghi.</returns>
        Task<bool> CapNhatHoSoKhachThueAsync(int maKhach, CapNhatHoSoRequest request, CancellationToken cancellationToken = default);

        /// <summary>
        /// Admin cập nhật hồ sơ của một Khách Thuê bất kỳ (bao gồm cả TrangThai).
        /// </summary>
        /// <param name="maKhach">Mã khách thuê cần cập nhật.</param>
        /// <param name="request">Dữ liệu cập nhật từ Admin.</param>
        /// <param name="cancellationToken">Token huỷ thao tác bất đồng bộ.</param>
        /// <returns>true nếu cập nhật thành công; false nếu không tìm thấy bản ghi.</returns>
        Task<bool> AdminCapNhatHoSoKhachThueAsync(int maKhach, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default);

        // ── Người Quản Lý ────────────────────────────────────────────────

        /// <summary>
        /// Lấy thông tin hồ sơ của một Người Quản Lý theo mã định danh.
        /// </summary>
        /// <param name="maQuanLy">Mã người quản lý (MaQuanLy).</param>
        /// <param name="cancellationToken">Token huỷ thao tác bất đồng bộ.</param>
        /// <returns>Entity <see cref="NguoiQuanLy"/> nếu tìm thấy; null nếu không tồn tại.</returns>
        Task<NguoiQuanLy?> LayHoSoNguoiQuanLyAsync(int maQuanLy, CancellationToken cancellationToken = default);

        /// <summary>
        /// Admin cập nhật hồ sơ của một Người Quản Lý bất kỳ.
        /// </summary>
        /// <param name="maQuanLy">Mã người quản lý cần cập nhật.</param>
        /// <param name="request">Dữ liệu cập nhật từ Admin.</param>
        /// <param name="cancellationToken">Token huỷ thao tác bất đồng bộ.</param>
        /// <returns>true nếu cập nhật thành công; false nếu không tìm thấy bản ghi.</returns>
        Task<bool> AdminCapNhatHoSoNguoiQuanLyAsync(int maQuanLy, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default);

        // ── Tra cứu vai trò theo TaiKhoan ────────────────────────────────

        /// <summary>
        /// Lấy VaiTro và mã định danh tương ứng (MaKhach hoặc MaQuanLy) của một tài khoản.
        /// Dùng để Admin xác định loại hồ sơ trước khi thao tác.
        /// </summary>
        /// <param name="maTaiKhoan">Mã tài khoản (MaTaiKhoan).</param>
        /// <param name="cancellationToken">Token huỷ thao tác bất đồng bộ.</param>
        /// <returns>
        /// Tuple gồm (VaiTro, MaKhach?, MaQuanLy?) nếu tài khoản tồn tại; null nếu không.
        /// </returns>
        Task<(string VaiTro, int? MaKhach, int? MaQuanLy)?> LayVaiTroTaiKhoanAsync(int maTaiKhoan, CancellationToken cancellationToken = default);
    }
}
