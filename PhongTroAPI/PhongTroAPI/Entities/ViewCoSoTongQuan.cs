using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class ViewCoSoTongQuan
{
    public int MaCoSo { get; set; }

    public string TenCoSo { get; set; } = null!;

    public string DiaChi { get; set; } = null!;

    public int? TongPhong { get; set; }

    public int? PhongTrong { get; set; }

    public int? DangThue { get; set; }

    public int? BaoTri { get; set; }
}
