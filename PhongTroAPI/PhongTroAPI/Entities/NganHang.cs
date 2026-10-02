using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class NganHang
{
    public int MaNganHang { get; set; }

    public string TenNganHang { get; set; } = null!;

    public string? TenVietTat { get; set; }

    public string MaBin { get; set; } = null!;

    public virtual ICollection<NguoiQuanLy> NguoiQuanLies { get; set; } = new List<NguoiQuanLy>();
}
