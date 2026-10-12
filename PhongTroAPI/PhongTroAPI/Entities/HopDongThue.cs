using System;
using System.Collections.Generic;
using MongoDB.Bson.Serialization.Attributes;
using PhongTroAPI.Entities.Embedded;

namespace PhongTroAPI.Entities
{
    public partial class HopDongThue
    {
        [BsonId]
        public int MaHopDong { get; set; }
        
        public int MaPhong { get; set; }
        public int MaKhach { get; set; }
        public DateOnly NgayBatDau { get; set; }
        public DateOnly? NgayKetThuc { get; set; }
        public decimal? TienCoc { get; set; }
        public string? TrangThai { get; set; }
        public DateTime? NgayTao { get; set; }
        public string? ChuKy { get; set; }
        public int? ChiSoDienCu { get; set; }
        public int? ChiSoNuocCu { get; set; }
        public string? UrlChuKyKhach { get; set; }
        public string? ContractHash { get; set; }
        public string? PublicKeyKhach { get; set; }
        public DateTime? NgayKy { get; set; }
        public string? LyDoKetThucSom { get; set; }
        public DateOnly? NgayMuonKetThuc { get; set; }

        public List<LichSuGiaHanItem> LichSuGiaHans { get; set; } = new List<LichSuGiaHanItem>();
    }
}
