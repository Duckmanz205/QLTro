namespace PhongTroAPI.Entities.Search
{
    public class OGhepSearchDoc
    {
        public int Id { get; set; }
        public int MaPhong { get; set; }
        public string TieuDe { get; set; } = null!;
        public string? MoTa { get; set; }
        public decimal GiaThue { get; set; }
        public string? YeuCauGioiTinh { get; set; }
        public int TrangThai { get; set; }
    }
}
