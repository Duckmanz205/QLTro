namespace PhongTroAPI.DTOs
{
    /// <summary>
    /// DTO phản hồi hồ sơ cá nhân dùng chung cho cả Khách Thuê và Người Quản Lý.
    /// Các trường không áp dụng với một loại vai trò sẽ trả về null.
    /// </summary>
    public class HoSoDto
    {
        // ── Thông tin chung ──────────────────────────────────────────

        /// <summary>Mã định danh nội bộ của hồ sơ (MaKhach hoặc MaQuanLy).</summary>
        public int MaHoSo { get; set; }

        /// <summary>Vai trò tài khoản: "KhachThue" hoặc "NguoiQuanLy".</summary>
        public string VaiTro { get; set; } = string.Empty;

        /// <summary>Họ và tên đầy đủ.</summary>
        public string? HoTen { get; set; }

        /// <summary>Số điện thoại.</summary>
        public string? Sdt { get; set; }

        /// <summary>Địa chỉ email.</summary>
        public string? Email { get; set; }

        /// <summary>Trạng thái tài khoản (Đang ở / Hoạt động / Đã khoá...).</summary>
        public string? TrangThai { get; set; }

        // ── Chỉ dành cho Khách Thuê ──────────────────────────────────

        /// <summary>Số CCCD (chỉ có với Khách Thuê).</summary>
        public string? Cccd { get; set; }

        /// <summary>Ngày sinh (chỉ có với Khách Thuê).</summary>
        public DateOnly? NgaySinh { get; set; }

        /// <summary>Giới tính (chỉ có với Khách Thuê).</summary>
        public string? GioiTinh { get; set; }

        /// <summary>Địa chỉ thường trú (chỉ có với Khách Thuê).</summary>
        public string? DiaChiThuongTru { get; set; }

        /// <summary>Ngày cấp CCCD (chỉ có với Khách Thuê).</summary>
        public DateOnly? NgayCapCccd { get; set; }

        /// <summary>Nơi cấp CCCD (chỉ có với Khách Thuê).</summary>
        public string? NoiCapCccd { get; set; }

        // ── Chỉ dành cho Người Quản Lý ───────────────────────────────

        /// <summary>Số tài khoản ngân hàng (chỉ có với Người Quản Lý).</summary>
        public string? SoTaiKhoan { get; set; }

        /// <summary>Tên chủ tài khoản ngân hàng (chỉ có với Người Quản Lý).</summary>
        public string? TenTaiKhoan { get; set; }

        /// <summary>Mã ngân hàng liên kết (chỉ có với Người Quản Lý).</summary>
        public int? MaNganHang { get; set; }

        /// <summary>Ngày tạo tài khoản (chỉ có với Người Quản Lý).</summary>
        public DateTime? NgayTao { get; set; }
    }
}
