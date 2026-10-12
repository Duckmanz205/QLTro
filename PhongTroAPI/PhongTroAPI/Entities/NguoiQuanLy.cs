using System;
using MongoDB.Bson.Serialization.Attributes;
using PhongTroAPI.Entities.Embedded;

namespace PhongTroAPI.Entities
{
    public partial class NguoiQuanLy
    {
        [BsonId]
        public int MaQuanLy { get; set; }
        
        public string HoTen { get; set; } = null!;
        public string? Sdt { get; set; }
        public string? Email { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayTao { get; set; }

        // Embedded information for NoSQL
        public ThongTinNganHangItem? ThongTinNganHang { get; set; }
    }
}
