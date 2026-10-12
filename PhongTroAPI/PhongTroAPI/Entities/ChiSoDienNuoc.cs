using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class ChiSoDienNuoc
    {
        [BsonId]
        public int MaChiSo { get; set; }
        
        public int MaPhong { get; set; }
        public int Thang { get; set; }
        public int Nam { get; set; }
        public int ChiSoDienCu { get; set; }
        public int? ChiSoDienMoi { get; set; }
        public int ChiSoNuocCu { get; set; }
        public int? ChiSoNuocMoi { get; set; }
        public bool DaLapHoaDon { get; set; }
        public DateTime? NgayCapNhat { get; set; }
    }
}
