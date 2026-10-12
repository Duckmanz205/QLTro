using System;

namespace PhongTroAPI.Entities.Search
{
    public class HoaDonAnalyticsDoc
    {
        public int Id { get; set; }
        public int MaPhong { get; set; }
        public int MaCoSo { get; set; }
        public decimal TongTien { get; set; }
        public decimal DaThanhToan { get; set; }
        public decimal ConNo { get; set; }
        public int TrangThai { get; set; }
        public DateTime NgayLap { get; set; }
    }
}
