using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class ChiSoDienNuoc
{
    public int MaChiSo { get; set; }

    public int MaPhong { get; set; }

    public int Thang { get; set; }

    public int Nam { get; set; }

    public int ChiSoDienCu { get; set; }

    public int? ChiSoDienMoi { get; set; }

    public int ChiSoNuocCu { get; set; }

    public int? ChiSoNuocMoi { get; set; }

    public bool DaLapHoaDon { get; set; }

    public DateTime? NgayCapNhat { get; set; }

    public virtual Phong MaPhongNavigation { get; set; } = null!;
}
