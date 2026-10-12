using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class TaiKhoan
    {
        [BsonId]
        public int MaTaiKhoan { get; set; }
        
        public string TenDangNhap { get; set; } = null!;
        public string MatKhau { get; set; } = null!;
        public string VaiTro { get; set; } = null!;
        public int? MaQuanLy { get; set; }
        public int? MaKhach { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayTao { get; set; }
    }
}
