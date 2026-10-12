using System;
using MongoDB.Bson.Serialization.Attributes;

namespace PhongTroAPI.Entities
{
    public partial class TienIch
    {
        [BsonId]
        public int MaTienIch { get; set; }
        
        public string? TenTienIch { get; set; }
    }
}
