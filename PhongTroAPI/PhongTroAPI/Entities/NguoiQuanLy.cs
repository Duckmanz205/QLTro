using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class NguoiQuanLy
{
    public int MaQuanLy { get; set; }

    public string HoTen { get; set; } = null!;

    public string? Sdt { get; set; }

    public string? Email { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayTao { get; set; }

    public string? SoTaiKhoan { get; set; }

    public string? TenTaiKhoan { get; set; }

    public int? MaNganHang { get; set; }

    public virtual ICollection<CoSo> CoSos { get; set; } = new List<CoSo>();

    public virtual ICollection<LichSuThanhToan> LichSuThanhToans { get; set; } = new List<LichSuThanhToan>();

    public virtual NganHang? MaNganHangNavigation { get; set; }

    public virtual ICollection<TaiKhoan> TaiKhoans { get; set; } = new List<TaiKhoan>();

    public virtual ICollection<ThongBao> ThongBaos { get; set; } = new List<ThongBao>();

    public virtual ICollection<TinNhan> TinNhans { get; set; } = new List<TinNhan>();
}
