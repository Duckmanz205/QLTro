using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class TinNhan
    {
        [BsonId]
        public int MaTinNhan { get; set; }
        
        public int? MaNguoiGui { get; set; }
        public string VaiTroNguoiGui { get; set; } = null!;
        public int? MaNguoiNhan { get; set; }
        public string VaiTroNguoiNhan { get; set; } = null!;
        public string NoiDung { get; set; } = null!;
        public DateTime? NgayGui { get; set; }
        public bool? DaDoc { get; set; }
        public int? MaQuanLy { get; set; }

        // New field for NoSQL chatting
        public string ConversationKey { get; set; } = null!;
    }
}
