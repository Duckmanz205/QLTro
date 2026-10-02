using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using PhongTroAPI.DTOs;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ForgotPasswordController : ControllerBase
    {
        private readonly string _connStr;

        public ForgotPasswordController(IConfiguration config)
        {
            _connStr = config.GetConnectionString("DefaultConnection")!;
        }

        // ─────────────────────────────────────────────
        // POST /api/forgotpassword/xac-minh
        // Bước 1: Nhận TenDangNhap + SDT, kiểm tra khớp DB
        // JOIN KhachThue hoặc NguoiQuanLy tuỳ VaiTro (giống pattern Login)
        // ─────────────────────────────────────────────
        [HttpPost("xac-minh")]
        public async Task<IActionResult> XacMinhTaiKhoan([FromBody] XacMinhTaiKhoanRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await using var conn = new SqlConnection(_connStr);
            await conn.OpenAsync();

            // JOIN giống Login: LEFT JOIN KhachThue + NguoiQuanLy để lấy SDT
            const string sql = @"
                SELECT tk.MaTaiKhoan, tk.VaiTro,
                       COALESCE(k.SDT, nql.SDT) AS SDT
                FROM TaiKhoan tk
                LEFT JOIN KhachThue k       ON tk.MaKhach  = k.MaKhach
                LEFT JOIN NguoiQuanLy nql   ON tk.MaQuanLy = nql.MaQuanLy
                WHERE tk.TenDangNhap = @TenDangNhap
                  AND tk.TrangThai   = N'Hoạt động'";

            await using var cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@TenDangNhap", request.TenDangNhap.Trim());

            await using var reader = await cmd.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
                return BadRequest(new { message = "Tên đăng nhập không tồn tại hoặc tài khoản đã bị khóa" });

            var sdtDb = reader.IsDBNull(reader.GetOrdinal("SDT"))
                ? null
                : reader.GetString(reader.GetOrdinal("SDT"));

            await reader.CloseAsync();

            // So sánh SDT plain text — giống cách so sánh MatKhau trong Login
            if (sdtDb == null || sdtDb.Trim() != request.SDT.Trim())
                return BadRequest(new { message = "Số điện thoại không khớp với tài khoản" });

            return Ok(new { message = "Xác minh thành công" });
        }

        // ─────────────────────────────────────────────
        // POST /api/forgotpassword/dat-lai
        // Bước 2: Cập nhật MatKhau mới (plain text, giống Register)
        // ─────────────────────────────────────────────
        [HttpPost("dat-lai")]
        public async Task<IActionResult> DatLaiMatKhau([FromBody] DatLaiMatKhauRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await using var conn = new SqlConnection(_connStr);
            await conn.OpenAsync();

            // Kiểm tra TenDangNhap tồn tại và đang hoạt động
            const string checkSql = @"
                SELECT COUNT(1) FROM TaiKhoan
                WHERE TenDangNhap = @TenDangNhap
                  AND TrangThai   = N'Hoạt động'";

            await using (var checkCmd = new SqlCommand(checkSql, conn))
            {
                checkCmd.Parameters.AddWithValue("@TenDangNhap", request.TenDangNhap.Trim());
                var count = Convert.ToInt32(await checkCmd.ExecuteScalarAsync() ?? 0);
                if (count == 0)
                    return BadRequest(new { message = "Tài khoản không hợp lệ" });
            }

            // UPDATE MatKhau — plain text, giống INSERT trong Register
            const string updateSql = @"
                UPDATE TaiKhoan
                SET MatKhau = @MatKhauMoi
                WHERE TenDangNhap = @TenDangNhap";

            await using var updateCmd = new SqlCommand(updateSql, conn);
            updateCmd.Parameters.AddWithValue("@MatKhauMoi", request.MatKhauMoi);
            updateCmd.Parameters.AddWithValue("@TenDangNhap", request.TenDangNhap.Trim());

            await updateCmd.ExecuteNonQueryAsync();

            return Ok(new { message = "Đặt lại mật khẩu thành công" });
        }
    }
}
