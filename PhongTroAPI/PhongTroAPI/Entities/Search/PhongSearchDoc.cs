using System.Collections.Generic;

namespace PhongTroAPI.Entities.Search
{
    public class PhongSearchDoc
    {
        public int Id { get; set; }
        public string TenPhong { get; set; } = null!;
        public decimal GiaThue { get; set; }
        public decimal DienTich { get; set; }
        public int SoNguoiToiDa { get; set; }
        public string? MoTa { get; set; }
        public int TrangThai { get; set; }
        public int MaCoSo { get; set; }
        public List<int> TienIch { get; set; } = new List<int>();
    }
}
