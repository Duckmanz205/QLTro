using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class Phong
{
    public int MaPhong { get; set; }

    public int MaCoSo { get; set; }

    public string SoPhong { get; set; } = null!;

    public int? Tang { get; set; }

    public double? DienTich { get; set; }

    public decimal GiaThue { get; set; }

    public int? SoNguoiToiDa { get; set; }

    public string? TrangThai { get; set; }

    public string? MoTa { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual ICollection<ChiSoDienNuoc> ChiSoDienNuocs { get; set; } = new List<ChiSoDienNuoc>();

    public virtual ICollection<HinhAnhPhong> HinhAnhPhongs { get; set; } = new List<HinhAnhPhong>();

    public virtual ICollection<HoaDon> HoaDons { get; set; } = new List<HoaDon>();

    public virtual ICollection<HopDongThue> HopDongThues { get; set; } = new List<HopDongThue>();

    public virtual ICollection<LichHenXemPhong> LichHenXemPhongs { get; set; } = new List<LichHenXemPhong>();

    public virtual CoSo MaCoSoNavigation { get; set; } = null!;

    public virtual ICollection<SuCo> SuCos { get; set; } = new List<SuCo>();

    public virtual ICollection<TienIch> MaTienIches { get; set; } = new List<TienIch>();
}
