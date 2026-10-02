using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class Oghep
{
    public int MaBaiDang { get; set; }

    public int MaKhach { get; set; }

    public string TieuDe { get; set; } = null!;

    public string? NoiDung { get; set; }

    public decimal ChiPhiDuKien { get; set; }

    public string? KhuVuc { get; set; }

    public string? YeuCauGioiTinh { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayDang { get; set; }

    public virtual KhachThue MaKhachNavigation { get; set; } = null!;
}
