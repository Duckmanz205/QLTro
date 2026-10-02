namespace PhongTroAPI.DTOs
{
    public class CoSoUpsertDto
    {
        public string TenCoSo { get; set; } = string.Empty;
        public string DiaChi { get; set; } = string.Empty;
        public string LoaiHinh { get; set; } = string.Empty;
        public string? MoTa { get; set; }
        public int? MaQuanLy { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }

        public List<int> MaTienIchIds { get; set; } = new();
    }
}