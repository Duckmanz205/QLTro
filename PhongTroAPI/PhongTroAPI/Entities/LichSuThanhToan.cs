using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class LichSuThanhToan
{
    public int MaThanhToan { get; set; }

    public int MaHoaDon { get; set; }

    public decimal SoTien { get; set; }

    public string? PhuongThuc { get; set; }

    public DateTime? NgayThanhToan { get; set; }

    public int? NguoiGhiNhan { get; set; }

    public virtual HoaDon MaHoaDonNavigation { get; set; } = null!;

    public virtual NguoiQuanLy? NguoiGhiNhanNavigation { get; set; }
}
