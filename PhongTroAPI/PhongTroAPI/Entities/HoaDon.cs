using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class HoaDon
{
    public int MaHoaDon { get; set; }

    public int MaPhong { get; set; }

    public int? MaKhach { get; set; }

    public int Thang { get; set; }

    public int Nam { get; set; }

    public decimal TienPhong { get; set; }

    public int ChiSoDienCu { get; set; }

    public int ChiSoDienMoi { get; set; }

    public decimal DonGiaDien { get; set; }

    public int ChiSoNuocCu { get; set; }

    public int ChiSoNuocMoi { get; set; }

    public decimal DonGiaNuoc { get; set; }

    public decimal? TienDichVu { get; set; }

    public string? MoTaDichVu { get; set; }

    public decimal? PhuPhi { get; set; }

    public string? MoTaPhuPhi { get; set; }

    public decimal TongTien { get; set; }

    public string? TrangThai { get; set; }

    public DateOnly? NgayLap { get; set; }

    public DateOnly? HanThanhToan { get; set; }

    public DateOnly? NgayThanhToan { get; set; }

    public virtual ICollection<LichSuThanhToan> LichSuThanhToans { get; set; } = new List<LichSuThanhToan>();

    public virtual KhachThue? MaKhachNavigation { get; set; }

    public virtual Phong MaPhongNavigation { get; set; } = null!;
}
