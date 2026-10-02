using System;
using System.Collections.Generic;

namespace PhongTroAPI.DTOs
{
    // DTO cho Chủ trọ (Admin)
    public class AdminThongKeDto
    {
        public decimal TongDoanhThuDaThu { get; set; }
        public decimal TongDoanhThuChuaThu { get; set; }
        public int TongSoCoSo { get; set; }
        public int TongSoPhong { get; set; }
        public double TiLeLapDay { get; set; } // (Số phòng đang thuê / Tổng số phòng) * 100
        
        // Thống kê phòng
        public int PhongDangThue { get; set; }
        public int PhongTrong { get; set; }
        public int PhongBaoTri { get; set; }

        // Báo cáo doanh thu 12 tháng của năm được chọn
        public List<DoanhThuThangDto> DoanhThuTheoThang { get; set; } = new();
        
        // Thống kê sự cố
        public int TongSuCo { get; set; }
        public int SuCoChuaXuLy { get; set; }
    }

    public class DoanhThuThangDto
    {
        public int Thang { get; set; }
        public decimal DaThanhToan { get; set; }
        public decimal ChuaThanhToan { get; set; }
    }

    // DTO cho Khách thuê (User)
    public class UserThongKeDto
    {
        public decimal TongTienDaThanhToan { get; set; }
        public decimal TongTienChuaThanhToan { get; set; }
        public decimal TienCocHienTai { get; set; }
        public string? TenPhongHienTai { get; set; }
        public string? TenCoSoHienTai { get; set; }

        // Xu hướng chi tiêu 6 tháng gần nhất
        public List<ChiTieuThangDto> LichSuChiTieu { get; set; } = new();

        // Chỉ số điện nước tiêu thụ 6 tháng gần nhất để vẽ biểu đồ cột
        public List<TieuThuDienNuocDto> LichSuTieuThu { get; set; } = new();
    }

    public class ChiTieuThangDto
    {
        public string KyThanhToan { get; set; } = null!; // "T05/2026"
        public decimal TongTien { get; set; }
    }

    public class TieuThuDienNuocDto
    {
        public string KyThanhToan { get; set; } = null!;
        public int SoDienTieuThu { get; set; } // kWh
        public int SoNuocTieuThu { get; set; } // m3
    }
}
