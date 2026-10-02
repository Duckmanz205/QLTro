using System.ComponentModel.DataAnnotations;

namespace PhongTroAPI.DTOs
{
    // DTO cho Bước 1: xác minh tài khoản bằng TenDangNhap + SDT
    public class XacMinhTaiKhoanRequest
    {
        [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
        public string TenDangNhap { get; set; } = string.Empty;

        [Required(ErrorMessage = "Số điện thoại là bắt buộc")]
        public string SDT { get; set; } = string.Empty;
    }

    // DTO cho Bước 2: đặt lại mật khẩu mới
    public class DatLaiMatKhauRequest
    {
        [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
        public string TenDangNhap { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu mới là bắt buộc")]
        [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
        public string MatKhauMoi { get; set; } = string.Empty;
    }
}
