using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class LichHenXemPhong
{
    public int MaLichHen { get; set; }

    public int? MaKhach { get; set; }

    public string HoTenKhach { get; set; } = null!;

    public string Sdtkhach { get; set; } = null!;

    public int MaPhong { get; set; }

    public DateTime ThoiGianHen { get; set; }

    public string? GhiChu { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual KhachThue? MaKhachNavigation { get; set; }

    public virtual Phong MaPhongNavigation { get; set; } = null!;
}
