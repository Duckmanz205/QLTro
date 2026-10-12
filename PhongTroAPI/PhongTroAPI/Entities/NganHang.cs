using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class NganHang
    {
        [BsonId]
        public int MaNganHang { get; set; }
        
        public string TenNganHang { get; set; } = null!;
        public string? TenVietTat { get; set; }
        public string MaBin { get; set; } = null!;
    }
}
