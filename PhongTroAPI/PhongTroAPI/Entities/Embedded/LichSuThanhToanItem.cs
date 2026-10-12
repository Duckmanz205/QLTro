using System;

namespace PhongTroAPI.Entities.Embedded
{
    public class LichSuThanhToanItem
    {
        public decimal SoTien { get; set; }
        public DateTime NgayThanhToan { get; set; }
        public string? PhuongThuc { get; set; }
        public string? GhiChu { get; set; }
    }
}
