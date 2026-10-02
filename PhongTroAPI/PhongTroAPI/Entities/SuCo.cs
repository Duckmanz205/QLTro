using System;
using System.Collections.Generic;

namespace PhongTroAPI.Entities;

public partial class SuCo
{
    public int MaSuCo { get; set; }

    public int MaPhong { get; set; }

    public int MaKhach { get; set; }

    public string TieuDe { get; set; } = null!;

    public string? MoTa { get; set; }

    public string? HinhAnh { get; set; }

    public string? TrangThai { get; set; }

    public DateTime? NgayBao { get; set; }

    public DateTime? NgayXuLy { get; set; }

    public virtual KhachThue? MaKhachNavigation { get; set; }

    public virtual Phong? MaPhongNavigation { get; set; }
}
