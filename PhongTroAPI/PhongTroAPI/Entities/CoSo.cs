using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class CoSo
{
    public int MaCoSo { get; set; }

    public string TenCoSo { get; set; } = null!;

    public string DiaChi { get; set; } = null!;

    public string? MoTa { get; set; }

    public string? LoaiHinh { get; set; }

    public int? MaQuanLy { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public double? DanhGia { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayTao { get; set; }

    public decimal DonGiaDien { get; set; }

    public decimal DonGiaNuoc { get; set; }

    public virtual ICollection<HinhAnhCoSo> HinhAnhCoSos { get; set; } = new List<HinhAnhCoSo>();

    public virtual NguoiQuanLy? MaQuanLyNavigation { get; set; }

    public virtual ICollection<Phong> Phongs { get; set; } = new List<Phong>();

    public virtual ICollection<TienIch> MaTienIches { get; set; } = new List<TienIch>();
}
