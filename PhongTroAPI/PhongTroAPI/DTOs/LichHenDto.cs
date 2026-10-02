using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace PhongTroAPI.DTOs
{
    // 1. DTO NHẬN DỮ LIỆU TỪ MOBILE APP (KHI USER BẤM ĐẶT LỊCH)
    public class CreateLichHenDto
    {
        public int? MaKhach { get; set; }        // ID của khách thuê (NULL nếu là khách vãng lai chưa đăng nhập)
        public string? HoTenKhach { get; set; }  // Họ tên khách điền trên form
        
        // Trường chuẩn map khớp với thuộc tính cơ sở dữ liệu Entity Framework
        public string? SdtKhach { get; set; } 

        // Thuộc tính fallback: Tự động đồng bộ nếu code cũ bên Flutter lỡ gọi chữ viết HOA (SDTKhach)
        [JsonIgnore]
        public string? SDTKhach 
        { 
            get => SdtKhach; 
            set => SdtKhach = value; 
        }

        public int MaPhong { get; set; }         // ID phòng muốn xem
        public DateTime ThoiGianHen { get; set; } // Ngày giờ hẹn gặp xem phòng
        public string? GhiChu { get; set; }       // Lời nhắn gửi chủ trọ
    }

    // 2. DTO TRẢ VỀ DANH SÁCH TỔNG HỢP CHO TRANG ADMIN (DUYỆT LỊCH)
    public class LichHenRenderDto
    {
        public int MaLichHen { get; set; }
        public int? MaKhach { get; set; }
        public string HoTenKhach { get; set; } = null!;
        public string SdtKhach { get; set; } = null!;
        public int MaPhong { get; set; }
        public string SoPhong { get; set; } = null!;      // Bốc từ bảng Phong thông qua JOIN LINQ
        public string TenCoSo { get; set; } = null!;      // Bốc từ bảng CoSo thông qua JOIN LINQ
        public DateTime ThoiGianHen { get; set; }
        public string? GhiChu { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayTao { get; set; }
    }
    // 3. DTO TRẢ VỀ TRANG LỊCH SỬ ĐẶT LỊCH CỦA APP MOBILE USER
   
    public class LichHenViewDto
    {
        public int MaLichHen { get; set; }
        public string SoPhong { get; set; } = null!;      // Hiển thị số phòng cho user dễ nhìn
        public string TenCoSo { get; set; } = null!;      // Tên cơ sở nhà trọ
        public DateTime ThoiGianHen { get; set; }
        public string? GhiChu { get; set; }
        public string TrangThai { get; set; } = null!;    // "Chờ xác nhận", "Đã xác nhận", "Đã xem", "Đã hủy"
        public DateTime? NgayTao { get; set; }
    }

    // 4. DTO HỨNG TRẠNG THÁI MỚI KHI ADMIN DUYỆT NHANH (PUT STATUS)
    public class UpdateStatusDto
    {
        public string TrangThaiMoi { get; set; } = null!; // Nhận chuỗi: "Đã xác nhận", "Đã hủy"...
    }
}