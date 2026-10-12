using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class LichHenXemPhong
    {
        [BsonId]
        public int MaLichHen { get; set; }
        
        public int? MaKhach { get; set; }
        public string HoTenKhach { get; set; } = null!;
        public string Sdtkhach { get; set; } = null!;
        public int MaPhong { get; set; }
        public DateTime ThoiGianHen { get; set; }
        public string? GhiChu { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayTao { get; set; }
    }
}
