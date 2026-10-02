using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class KhachThue
{
    public int MaKhach { get; set; }

    public string? HoTen { get; set; }

    public string? Sdt { get; set; }

    public string? Cccd { get; set; }

    public string? Email { get; set; }

    public DateOnly? NgaySinh { get; set; }

    public string? GioiTinh { get; set; }

    public string? DiaChiThuongTru { get; set; }

    public DateOnly? NgayCapCccd { get; set; }

    public string? NoiCapCccd { get; set; }

    public string? TrangThai { get; set; }

    public virtual ICollection<HoaDon> HoaDons { get; set; } = new List<HoaDon>();

    public virtual ICollection<HopDongThue> HopDongThues { get; set; } = new List<HopDongThue>();

    public virtual ICollection<LichHenXemPhong> LichHenXemPhongs { get; set; } = new List<LichHenXemPhong>();

    public virtual ICollection<Oghep> Ogheps { get; set; } = new List<Oghep>();

    public virtual ICollection<SuCo> SuCos { get; set; } = new List<SuCo>();

    public virtual ICollection<TaiKhoan> TaiKhoans { get; set; } = new List<TaiKhoan>();

    public virtual ICollection<ThongBao> ThongBaos { get; set; } = new List<ThongBao>();
}
