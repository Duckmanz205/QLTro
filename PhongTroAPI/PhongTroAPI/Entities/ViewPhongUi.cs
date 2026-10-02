using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class ViewPhongUi
{
    public int MaPhong { get; set; }

    public int MaCoSo { get; set; }

    public string TenCoSo { get; set; } = null!;

    public string DiaChi { get; set; } = null!;

    public string SoPhong { get; set; } = null!;

    public int? Tang { get; set; }

    public double? DienTich { get; set; }

    public decimal GiaThue { get; set; }

    public int? SoNguoiToiDa { get; set; }

    public string? TrangThai { get; set; }

    public string? MoTa { get; set; }

    public string? TrangThaiHienThi { get; set; }
}
