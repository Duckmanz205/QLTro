using System;

namespace PhongTroAPI.DTOs
{
    public class CreateHopDongDto
    {
        public int MaPhong { get; set; }
        public int MaKhach { get; set; }
        public DateOnly NgayBatDau { get; set; }
        public DateOnly? NgayKetThuc { get; set; }
        public decimal TienCoc { get; set; }
        public int? ChiSoDienCu { get; set; }
        public int? ChiSoNuocCu { get; set; }
    }

    public class HopDongRenderDto
    {
        public int MaHopDong { get; set; }
        public int MaKhach { get; set; }
        public int MaPhong { get; set; }
        public string TenKhach { get; set; } = null!;
        public string CCCD { get; set; } = null!;
        public string SDT { get; set; } = null!;
        public string SoPhong { get; set; } = null!;
        public string TenCoSo { get; set; } = null!;
        public decimal GiaThue { get; set; }
        public decimal TienCoc { get; set; }
        public DateOnly NgayBatDau { get; set; }
        public DateOnly NgayKetThuc { get; set; }
        public string? TrangThai { get; set; }
        public string? ChuKyBase64 { get; set; }

        public string? UrlChuKySupabase { get; set; }
        public string? TenQuanLy { get; set; }
        public string? SdtQuanLy { get; set; }
        public string? EmailQuanLy { get; set; }
        public string? LyDoKetThucSom { get; set; }
        public DateOnly? NgayMuonKetThuc { get; set; }
    }

    public class GiaHanHopDongDto
    {
        public DateOnly NgayBatDauMoi { get; set; }
        public DateOnly NgayKetThucMoi { get; set; }
        public decimal GiaThueMoi { get; set; }
        public string? GhiChu { get; set; }
    }

    public class YeuCauKetThucSomDto
    {
        public string? LyDo { get; set; }
        public DateOnly NgayMuonKetThuc { get; set; }
    }

    public class DuyetKetThucSomDto
    {
        public DateOnly NgayKetThucThucTe { get; set; }
        public string? GhiChu { get; set; }
    }
}
