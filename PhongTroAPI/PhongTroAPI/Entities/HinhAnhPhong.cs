using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class HinhAnhPhong
{
    public int MaAnh { get; set; }

    public int MaPhong { get; set; }

    public string? UrlAnh { get; set; }

    public virtual Phong MaPhongNavigation { get; set; } = null!;
}
