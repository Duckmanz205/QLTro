using System.ComponentModel.DataAnnotations;

namespace PhongTroAPI.DTOs
{
    /// <summary>
    /// Request body dành riêng cho Admin (NguoiQuanLy) cập nhật hồ sơ bất kỳ.
    /// Admin có thể cập nhật cả hồ sơ Khách Thuê lẫn Người Quản Lý và có thêm quyền
    /// thay đổi trạng thái tài khoản.
    /// </summary>
    public class AdminCapNhatHoSoRequest
    {
        // ── Trường chung (áp dụng cho cả KhachThue và NguoiQuanLy) ───

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

        /// <summary>
        /// Trạng thái tài khoản. Admin được phép thay đổi trường này (vd: "Đang ở", "Đã rời đi", "Hoạt động", "Đã khoá").
        /// Nếu null, giữ nguyên trạng thái hiện tại.
        /// </summary>
        [MaxLength(50, ErrorMessage = "Trạng thái không quá 50 ký tự.")]
        public string? TrangThai { get; set; }

        // ── Trường chỉ dành cho Khách Thuê ────────────────────────────

        /// <summary>Số CCCD/CMND. Tối đa 20 ký tự. (Chỉ áp dụng khi cập nhật hồ sơ Khách Thuê.)</summary>
        [MaxLength(20, ErrorMessage = "Số CCCD không quá 20 ký tự.")]
        public string? Cccd { get; set; }

        /// <summary>Ngày sinh (định dạng yyyy-MM-dd). (Chỉ áp dụng khi cập nhật hồ sơ Khách Thuê.)</summary>
        public DateOnly? NgaySinh { get; set; }

        /// <summary>Giới tính. Tối đa 10 ký tự. (Chỉ áp dụng khi cập nhật hồ sơ Khách Thuê.)</summary>
        [MaxLength(10, ErrorMessage = "Giới tính không quá 10 ký tự.")]
        public string? GioiTinh { get; set; }

        /// <summary>Địa chỉ thường trú. Tối đa 255 ký tự. (Chỉ áp dụng khi cập nhật hồ sơ Khách Thuê.)</summary>
        [MaxLength(255, ErrorMessage = "Địa chỉ thường trú không quá 255 ký tự.")]
        public string? DiaChiThuongTru { get; set; }

        /// <summary>Ngày cấp CCCD. (Chỉ áp dụng khi cập nhật hồ sơ Khách Thuê.)</summary>
        public DateOnly? NgayCapCccd { get; set; }

        /// <summary>Nơi cấp CCCD. Tối đa 155 ký tự. (Chỉ áp dụng khi cập nhật hồ sơ Khách Thuê.)</summary>
        [MaxLength(155, ErrorMessage = "Nơi cấp CCCD không quá 155 ký tự.")]
        public string? NoiCapCccd { get; set; }

        // ── Trường chỉ dành cho Người Quản Lý ─────────────────────────

        /// <summary>Số tài khoản ngân hàng. Tối đa 50 ký tự. (Chỉ áp dụng khi cập nhật hồ sơ Người Quản Lý.)</summary>
        [MaxLength(50, ErrorMessage = "Số tài khoản không quá 50 ký tự.")]
        public string? SoTaiKhoan { get; set; }

        /// <summary>Tên chủ tài khoản ngân hàng. Tối đa 150 ký tự. (Chỉ áp dụng khi cập nhật hồ sơ Người Quản Lý.)</summary>
        [MaxLength(150, ErrorMessage = "Tên tài khoản không quá 150 ký tự.")]
        public string? TenTaiKhoan { get; set; }

        /// <summary>Mã ngân hàng (FK sang bảng NganHang). (Chỉ áp dụng khi cập nhật hồ sơ Người Quản Lý.)</summary>
        public int? MaNganHang { get; set; }
    }
}
