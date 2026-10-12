using System;
using System.Collections.Generic;
using MongoDB.Bson.Serialization.Attributes;
using PhongTroAPI.Entities.Embedded;

namespace PhongTroAPI.Entities
{
    public partial class Phong
    {
        [BsonId]
        public int MaPhong { get; set; }
        
        public int MaCoSo { get; set; }
        public string SoPhong { get; set; } = null!;
        public int? Tang { get; set; }
        public double? DienTich { get; set; }
        public decimal GiaThue { get; set; }
        public int? SoNguoiToiDa { get; set; }
        public string? TrangThai { get; set; }
        public string? MoTa { get; set; }
        public DateTime? NgayTao { get; set; }

        // Embedded collections for NoSQL
        public List<HinhAnhItem> HinhAnhPhongs { get; set; } = new List<HinhAnhItem>();
        public List<TienIchItem> TienIches { get; set; } = new List<TienIchItem>();
    }
}
