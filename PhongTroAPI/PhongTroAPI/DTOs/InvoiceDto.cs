namespace PhongTroAPI.DTOs;

public class InvoiceDto
{
    public int MaHoaDon { get; set; }
    public int MaPhong { get; set; }
    public int? MaKhach { get; set; }
    public string TenPhong { get; set; } = string.Empty;
    public string TenCoSo { get; set; } = string.Empty;
    public string TenKhachThue { get; set; } = string.Empty;
    public int Thang { get; set; }
    public int Nam { get; set; }
    public double SoDienCu { get; set; }
    public double SoDienMoi { get; set; }
    public double SoNuocCu { get; set; }
    public double SoNuocMoi { get; set; }
    public decimal DonGiaDien { get; set; }
    public decimal DonGiaNuoc { get; set; }
    public decimal TienPhong { get; set; }
    public decimal TienDichVu { get; set; }
    public string? MoTaDichVu { get; set; }
    public decimal PhuPhi { get; set; }
    public string? MoTaPhuPhi { get; set; }
    public decimal TongTien { get; set; }
    public string TrangThai { get; set; } = "Chưa thanh toán";
    public string? NgayLap { get; set; }
    public string? HanThanhToan { get; set; }
    public string? NgayThanhToan { get; set; }
    
    // Banking Details for payment
    public string? SoTaiKhoan { get; set; }
    public string? TenTaiKhoan { get; set; }
    public string? MaBin { get; set; }
    public string? TenVietTat { get; set; }
}

public class InvoiceCreateDto
{
    public int MaPhong { get; set; }
    public int? MaKhach { get; set; }
    public int Thang { get; set; }
    public int Nam { get; set; }
    public double SoDienCu { get; set; }
    public double SoDienMoi { get; set; }
    public double SoNuocCu { get; set; }
    public double SoNuocMoi { get; set; }
    public decimal DonGiaDien { get; set; }
    public decimal DonGiaNuoc { get; set; }
    public decimal TienDichVu { get; set; }
    public string? MoTaDichVu { get; set; }
    public decimal PhuPhi { get; set; }
    public string? MoTaPhuPhi { get; set; }
}

public class InvoiceUpdateStatusDto
{
    public string TrangThai { get; set; } = string.Empty;
}

public class InvoiceUpdateDto
{
    public double SoDienMoi { get; set; }
    public double SoNuocMoi { get; set; }
    public decimal PhuPhi { get; set; }
    public string? MoTaPhuPhi { get; set; }
}
