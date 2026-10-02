using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class TaiKhoan
{
    public int MaTaiKhoan { get; set; }

    public string TenDangNhap { get; set; } = null!;

    public string MatKhau { get; set; } = null!;

    public string VaiTro { get; set; } = null!;

    public int? MaQuanLy { get; set; }

    public int? MaKhach { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual KhachThue? MaKhachNavigation { get; set; }

    public virtual NguoiQuanLy? MaQuanLyNavigation { get; set; }
}
