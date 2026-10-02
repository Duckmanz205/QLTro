using System.ComponentModel.DataAnnotations;

namespace PhongTroAPI.DTOs
{
    // DTO cho yêu cầu đăng ký tài khoản mới (KhachThue)
    public class RegisterRequest
    {
        [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
        [MaxLength(50, ErrorMessage = "Tên đăng nhập không được quá 50 ký tự")]
        public string TenDangNhap { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
        [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
        public string MatKhau { get; set; } = string.Empty;

        [Required(ErrorMessage = "Họ tên là bắt buộc")]
        public string HoTen { get; set; } = string.Empty;

        public string? SDT { get; set; }

        public string VaiTro { get; set; } = "KhachThue";
    }

    // DTO cho yêu cầu đăng nhập
    public class LoginRequest
    {
        [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
        public string TenDangNhap { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
        public string MatKhau { get; set; } = string.Empty;
    }

    // DTO trả về sau khi đăng nhập / đăng ký thành công
    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public int MaTaiKhoan { get; set; }
        public string TenDangNhap { get; set; } = string.Empty;
        public string HoTen { get; set; } = string.Empty;   // Lấy từ KhachThue.HoTen
        public string VaiTro { get; set; } = string.Empty;
        public int? MaKhach { get; set; }
        public int? MaQuanLy { get; set; }
    }

    // DTO cho yêu cầu đặt lại mật khẩu khi quên
    public class ForgotPasswordRequest
    {
        [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
        public string TenDangNhap { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu mới là bắt buộc")]
        [MinLength(6, ErrorMessage = "Mật khẩu mới phải có ít nhất 6 ký tự")]
        public string NewPassword { get; set; } = string.Empty;
    }
}
