using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class LichSuGiaHan
{
    public int MaGiaHan { get; set; }

    public int MaHopDong { get; set; }

    public DateOnly NgayBatDauMoi { get; set; }

    public DateOnly NgayKetThucMoi { get; set; }

    public decimal GiaThueMoi { get; set; }

    public DateTime? NgayThucHien { get; set; }

    public string? GhiChu { get; set; }

    public virtual HopDongThue MaHopDongNavigation { get; set; } = null!;
}
