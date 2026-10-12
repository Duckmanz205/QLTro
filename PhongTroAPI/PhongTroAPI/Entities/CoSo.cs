using System;
using System.Collections.Generic;
using MongoDB.Bson.Serialization.Attributes;
using PhongTroAPI.Entities.Embedded;

namespace PhongTroAPI.Entities
{
    public partial class CoSo
    {
        [BsonId]
        public int MaCoSo { get; set; }
        
        public string TenCoSo { get; set; } = null!;
        public string DiaChi { get; set; } = null!;
        public string? MoTa { get; set; }
        public string? LoaiHinh { get; set; }
        public int? MaQuanLy { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public double? DanhGia { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayTao { get; set; }
        public decimal DonGiaDien { get; set; }
        public decimal DonGiaNuoc { get; set; }

        // Embedded collections for NoSQL
        public List<HinhAnhItem> HinhAnhCoSos { get; set; } = new List<HinhAnhItem>();
        public List<TienIchItem> TienIches { get; set; } = new List<TienIchItem>();
    }
}
