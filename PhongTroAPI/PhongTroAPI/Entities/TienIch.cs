using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class TienIch
{
    public int MaTienIch { get; set; }

    public string? TenTienIch { get; set; }

    public virtual ICollection<CoSo> MaCoSos { get; set; } = new List<CoSo>();

    public virtual ICollection<Phong> MaPhongs { get; set; } = new List<Phong>();
}
