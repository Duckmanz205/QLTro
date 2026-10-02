using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class HinhAnhCoSo
{
    public int MaAnh { get; set; }

    public int MaCoSo { get; set; }

    public string? UrlAnh { get; set; }

    public bool IsMain { get; set; }

    public virtual CoSo MaCoSoNavigation { get; set; } = null!;
}
