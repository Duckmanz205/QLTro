using System.ComponentModel.DataAnnotations.Schema;

namespace PhongTroAPI.Entities
{
    public partial class NguoiQuanLy
    {
        [NotMapped]
        public string? TenNganHang { get; set; }
    }
}
