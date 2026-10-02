using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class ViewHoaDonUi
{
    public int MaHoaDon { get; set; }

    public int Thang { get; set; }

    public int Nam { get; set; }

    public decimal TongTien { get; set; }

    public string? TrangThai { get; set; }

    public DateOnly? HanThanhToan { get; set; }

    public string SoPhong { get; set; } = null!;

    public string TenCoSo { get; set; } = null!;

    public string? TenKhachThu { get; set; }

    public decimal TienPhong { get; set; }

    public decimal? TienDien { get; set; }

    public decimal? TienNuoc { get; set; }

    public decimal? TienDichVu { get; set; }

    public decimal? PhuPhi { get; set; }
}
