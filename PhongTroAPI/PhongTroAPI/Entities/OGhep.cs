using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class OGhep
    {
        [BsonId]
        public int MaBaiDang { get; set; }
        
        public int MaKhach { get; set; }
        public string TieuDe { get; set; } = null!;
        public string? NoiDung { get; set; }
        public decimal ChiPhiDuKien { get; set; }
        public string? KhuVuc { get; set; }
        public string? YeuCauGioiTinh { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayDang { get; set; }
    }
}
