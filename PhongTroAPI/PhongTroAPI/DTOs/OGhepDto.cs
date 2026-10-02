using System;

namespace PhongTroAPI.DTOs
{
    public class CreateOGhepDto
    {
        public int MaKhach { get; set; }
        public string TieuDe { get; set; } = null!;
        public string? NoiDung { get; set; }
        public decimal ChiPhiDuKien { get; set; }
        public string? KhuVuc { get; set; }
        public string? YeuCauGioiTinh { get; set; }
    }

    public class OGhepRenderDto
    {
        public int MaBaiDang { get; set; }
        public int MaKhach { get; set; }
        public string TenKhach { get; set; } = null!;
        public string SDTKhach { get; set; } = null!;
        public string TieuDe { get; set; } = null!;
        public string? NoiDung { get; set; }
        public decimal ChiPhiDuKien { get; set; }
        public string? KhuVuc { get; set; }
        public string? YeuCauGioiTinh { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayDang { get; set; }
    }
    public class OGhepViewDto
    {
        public string SoPhong { get; set; } = null!;
        public string TenCoSo { get; set; } = null!;
        public int SoNguoiO { get; set; }
        public decimal TongHoaDon { get; set; }
        public decimal TienChiaDeu { get; set; }
        public decimal DaThu { get; set; }
        public decimal ConLai { get; set; }
        public double PhanTramTienDo { get; set; }
        public List<ThanhVienOGhepDto> ThanhViens { get; set; } = new();
    }

    public class ThanhVienOGhepDto
    {
        public int MaKhach { get; set; }
        public string HoTen { get; set; } = null!;
        public string VaiTro { get; set; } = null!;
        public string TrangThaiThanhToan { get; set; } = null!;
        public decimal ConPhaiTra { get; set; }
    }
}
