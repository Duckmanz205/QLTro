using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class ThongBao
{
    public int MaThongBao { get; set; }

    public int MaKhach { get; set; }

    public string TieuDe { get; set; } = null!;

    public string? NoiDung { get; set; }

    public bool? DaDoc { get; set; }

    public DateTime? NgayGui { get; set; }

    public int? MaQuanLy { get; set; }

    public virtual KhachThue? MaKhachNavigation { get; set; }

    public virtual NguoiQuanLy? MaQuanLyNavigation { get; set; }
}
