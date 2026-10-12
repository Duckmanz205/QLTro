using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class KhachThue
    {
        [BsonId]
        public int MaKhach { get; set; }
        
        [BsonElement("hoTen")]
        public string? HoTen { get; set; }
        
        [BsonElement("sdt")]
        public string? Sdt { get; set; }
        
        [BsonElement("cccd")]
        public string? Cccd { get; set; }
        
        [BsonElement("email")]
        public string? Email { get; set; }
        
        [BsonElement("ngaySinh")]
        public DateOnly? NgaySinh { get; set; }
        
        [BsonElement("gioiTinh")]
        public string? GioiTinh { get; set; }
        
        [BsonElement("diaChiThuongTru")]
        public string? DiaChiThuongTru { get; set; }
        
        [BsonElement("ngayCapCccd")]
        public DateOnly? NgayCapCccd { get; set; }
        
        [BsonElement("noiCapCccd")]
        public string? NoiCapCccd { get; set; }
        
        [BsonElement("trangThai")]
        public string? TrangThai { get; set; }
    }
}
