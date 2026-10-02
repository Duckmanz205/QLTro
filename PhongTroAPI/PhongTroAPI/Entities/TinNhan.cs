using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class TinNhan
{
    public int MaTinNhan { get; set; }

    public int? MaNguoiGui { get; set; }

    public string VaiTroNguoiGui { get; set; } = null!;

    public int? MaNguoiNhan { get; set; }

    public string VaiTroNguoiNhan { get; set; } = null!;

    public string NoiDung { get; set; } = null!;

    public DateTime? NgayGui { get; set; }

    public bool? DaDoc { get; set; }

    public int? MaQuanLy { get; set; }

    public virtual NguoiQuanLy? MaQuanLyNavigation { get; set; }
}
