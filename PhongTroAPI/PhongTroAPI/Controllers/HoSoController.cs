using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.DTOs;
using PhongTroAPI.Services;

namespace PhongTroAPI.Controllers
{
    /// <summary>
    /// Controller quản lý API hồ sơ cá nhân.
    /// Cung cấp hai nhóm endpoint:
    /// <list type="bullet">
    ///   <item><description>Nhóm <c>/api/ho-so</c>: Khách Thuê tự thao tác hồ sơ bản thân.</description></item>
    ///   <item><description>Nhóm <c>/api/admin/ho-so</c>: Người Quản Lý xem và chỉnh sửa hồ sơ bất kỳ.</description></item>
    /// </list>
    /// </summary>
    [ApiController]
    [Produces("application/json")]
    public class HoSoController : ControllerBase
    {
        private readonly IHoSoService _hoSoService;

        /// <summary>
        /// Khởi tạo controller với service được inject từ DI container.
        /// </summary>
        /// <param name="hoSoService">Service xử lý business logic hồ sơ.</param>
        public HoSoController(IHoSoService hoSoService)
        {
            _hoSoService = hoSoService;
        }

        // ════════════════════════════════════════════════════════════════
        // NHÓM KHÁCH THUÊ — /api/ho-so
        // ════════════════════════════════════════════════════════════════

        /// <summary>
        /// [KhachThue] Lấy hồ sơ cá nhân của Khách Thuê đang đăng nhập.
        /// MaKhach được đọc trực tiếp từ claim "MaKhach" trong JWT token — không nhận id qua URL.
        /// </summary>
        /// <returns>
        /// 200 OK: Trả về <see cref="HoSoDto"/> chứa thông tin hồ sơ.
        /// 401 Unauthorized: Token không hợp lệ hoặc thiếu claim.
        /// 404 Not Found: Không tìm thấy hồ sơ trong DB.
        /// </returns>
        [HttpGet("api/ho-so/toi")]
        [Authorize(Roles = "KhachThue")]
        [ProducesResponseType(typeof(HoSoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> LayHoSoBanThan(CancellationToken cancellationToken)
        {
            try
            {
                // Lấy claim MaKhach từ JWT — được đặt trong GenerateJwtToken của AuthController
                string? maKhachClaim = User.FindFirst("MaKhach")?.Value;

                var dto = await _hoSoService.LayHoSoBanThanAsync(maKhachClaim, cancellationToken);
                return Ok(dto);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Không có quyền truy cập",
                    statusCode: StatusCodes.Status401Unauthorized);
            }
            catch (KeyNotFoundException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Không tìm thấy hồ sơ",
                    statusCode: StatusCodes.Status404NotFound);
            }
        }

        /// <summary>
        /// [KhachThue] Cập nhật hồ sơ cá nhân của Khách Thuê đang đăng nhập.
        /// Chỉ cho phép cập nhật các trường thông tin cơ bản; TrangThai và MaKhach không được phép thay đổi.
        /// </summary>
        /// <param name="request">Dữ liệu cần cập nhật từ body request.</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// 200 OK: Trả về <see cref="HoSoDto"/> sau khi cập nhật.
        /// 400 Bad Request: Dữ liệu đầu vào không hợp lệ (validation error).
        /// 401 Unauthorized: Token không hợp lệ hoặc thiếu claim.
        /// 404 Not Found: Không tìm thấy hồ sơ trong DB.
        /// </returns>
        [HttpPut("api/ho-so/toi")]
        [Authorize(Roles = "KhachThue")]
        [ProducesResponseType(typeof(HoSoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> CapNhatHoSoBanThan(
            [FromBody] CapNhatHoSoRequest request,
            CancellationToken cancellationToken)
        {
            // ModelState được kiểm tra tự động bởi [ApiController]; nếu lỗi trả 400 ngay
            if (!ModelState.IsValid)
                return ValidationProblem(ModelState);

            try
            {
                string? maKhachClaim = User.FindFirst("MaKhach")?.Value;

                var dto = await _hoSoService.CapNhatHoSoBanThanAsync(maKhachClaim, request, cancellationToken);
                return Ok(dto);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Không có quyền truy cập",
                    statusCode: StatusCodes.Status401Unauthorized);
            }
            catch (KeyNotFoundException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Không tìm thấy hồ sơ",
                    statusCode: StatusCodes.Status404NotFound);
            }
        }

        // ════════════════════════════════════════════════════════════════
        // NHÓM ADMIN — /api/admin/ho-so/{id}
        // Route {id} ở đây là MaTaiKhoan để Admin không cần biết vai trò trước
        // ════════════════════════════════════════════════════════════════

        /// <summary>
        /// [NguoiQuanLy] Admin xem hồ sơ của tài khoản bất kỳ theo MaTaiKhoan.
        /// Service tự động phân biệt vai trò (KhachThue / NguoiQuanLy) và trả về thông tin tương ứng.
        /// </summary>
        /// <param name="id">MaTaiKhoan của tài khoản cần xem hồ sơ.</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// 200 OK: Trả về <see cref="HoSoDto"/>.
        /// 404 Not Found: Không tìm thấy tài khoản hoặc hồ sơ tương ứng.
        /// 500 Internal Server Error: Dữ liệu không nhất quán trong DB.
        /// </returns>
        [HttpGet("api/admin/ho-so/{id:int}")]
        [Authorize(Roles = "NguoiQuanLy")]
        [ProducesResponseType(typeof(HoSoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> AdminLayHoSo(int id, CancellationToken cancellationToken)
        {
            try
            {
                var dto = await _hoSoService.AdminLayHoSoTheoIdAsync(id, cancellationToken);
                return Ok(dto);
            }
            catch (KeyNotFoundException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Không tìm thấy hồ sơ",
                    statusCode: StatusCodes.Status404NotFound);
            }
            catch (InvalidOperationException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Dữ liệu không nhất quán",
                    statusCode: StatusCodes.Status500InternalServerError);
            }
        }

        /// <summary>
        /// [NguoiQuanLy] Admin cập nhật hồ sơ của tài khoản bất kỳ theo MaTaiKhoan.
        /// Admin có thể thay đổi TrangThai và tất cả trường thông tin, kể cả các trường
        /// riêng cho từng loại tài khoản.
        /// </summary>
        /// <param name="id">MaTaiKhoan của tài khoản cần cập nhật hồ sơ.</param>
        /// <param name="request">Dữ liệu cần cập nhật từ body request.</param>
        /// <param name="cancellationToken">Token huỷ bất đồng bộ.</param>
        /// <returns>
        /// 200 OK: Trả về <see cref="HoSoDto"/> sau khi cập nhật.
        /// 400 Bad Request: Dữ liệu đầu vào không hợp lệ.
        /// 404 Not Found: Không tìm thấy tài khoản hoặc hồ sơ tương ứng.
        /// 500 Internal Server Error: Dữ liệu không nhất quán trong DB.
        /// </returns>
        [HttpPut("api/admin/ho-so/{id:int}")]
        [Authorize(Roles = "NguoiQuanLy")]
        [ProducesResponseType(typeof(HoSoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> AdminCapNhatHoSo(
            int id,
            [FromBody] AdminCapNhatHoSoRequest request,
            CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
                return ValidationProblem(ModelState);

            try
            {
                var dto = await _hoSoService.AdminCapNhatHoSoTheoIdAsync(id, request, cancellationToken);
                return Ok(dto);
            }
            catch (KeyNotFoundException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Không tìm thấy hồ sơ",
                    statusCode: StatusCodes.Status404NotFound);
            }
            catch (InvalidOperationException ex)
            {
                return Problem(
                    detail: ex.Message,
                    title: "Dữ liệu không nhất quán",
                    statusCode: StatusCodes.Status500InternalServerError);
            }
        }
    }
}
