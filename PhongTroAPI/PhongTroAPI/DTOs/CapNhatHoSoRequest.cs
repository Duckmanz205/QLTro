using System.ComponentModel.DataAnnotations;

namespace PhongTroAPI.DTOs
{
    /// <summary>
    /// Request body cho Khách Thuê tự cập nhật hồ sơ cá nhân của mình.
    /// Khách thuê chỉ được chỉnh sửa thông tin cơ bản; các trường nhạy cảm như TrangThai không được phép thay đổi.
    /// </summary>
    public class CapNhatHoSoRequest
    {
        /// <summary>Họ và tên đầy đủ. Bắt buộc, tối đa 100 ký tự.</summary>
        [Required(ErrorMessage = "Họ tên không được để trống.")]
        [MaxLength(100, ErrorMessage = "Họ tên không quá 100 ký tự.")]
        public string HoTen { get; set; } = string.Empty;

        /// <summary>Số điện thoại. Tối đa 15 ký tự.</summary>
        [MaxLength(15, ErrorMessage = "Số điện thoại không quá 15 ký tự.")]
        public string? Sdt { get; set; }

        /// <summary>Địa chỉ email. Tối đa 100 ký tự, phải đúng định dạng email.</summary>
        [MaxLength(100, ErrorMessage = "Email không quá 100 ký tự.")]
        [EmailAddress(ErrorMessage = "Địa chỉ email không hợp lệ.")]
        public string? Email { get; set; }

        /// <summary>Số CCCD/CMND. Tối đa 20 ký tự.</summary>
        [MaxLength(20, ErrorMessage = "Số CCCD không quá 20 ký tự.")]
        public string? Cccd { get; set; }

        /// <summary>Ngày sinh (định dạng yyyy-MM-dd).</summary>
        public DateOnly? NgaySinh { get; set; }

        /// <summary>Giới tính. Tối đa 10 ký tự (vd: "Nam", "Nữ", "Khác").</summary>
        [MaxLength(10, ErrorMessage = "Giới tính không quá 10 ký tự.")]
        public string? GioiTinh { get; set; }

        /// <summary>Địa chỉ thường trú. Tối đa 255 ký tự.</summary>
        [MaxLength(255, ErrorMessage = "Địa chỉ thường trú không quá 255 ký tự.")]
        public string? DiaChiThuongTru { get; set; }

        /// <summary>Ngày cấp CCCD (định dạng yyyy-MM-dd).</summary>
        public DateOnly? NgayCapCccd { get; set; }

        /// <summary>Nơi cấp CCCD. Tối đa 155 ký tự.</summary>
        [MaxLength(155, ErrorMessage = "Nơi cấp CCCD không quá 155 ký tự.")]
        public string? NoiCapCccd { get; set; }
    }
}
