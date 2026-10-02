using System.ComponentModel.DataAnnotations;

namespace PhongTroAPI.DTOs
{
    public class PhongUpsertDto
    {
        [Required(ErrorMessage = "Mã cơ sở là bắt buộc")]
        public int MaCoSo { get; set; }

        [Required(ErrorMessage = "Số phòng không được trống")]
        [StringLength(20, ErrorMessage = "Số phòng tối đa 20 ký tự")]
        public string SoPhong { get; set; } = string.Empty;

        [Range(1, 100, ErrorMessage = "Tầng phải lớn hơn hoặc bằng 1")]
        public int? Tang { get; set; }

        [Range(typeof(double), "0.01", "10000", ErrorMessage = "Diện tích phải lớn hơn 0")]
        public double? DienTich { get; set; }

        [Range(typeof(decimal), "1", "999999999", ErrorMessage = "Giá thuê phải lớn hơn 0")]
        public decimal GiaThue { get; set; }

        [Range(1, 50, ErrorMessage = "Số người tối đa phải lớn hơn hoặc bằng 1")]
        public int? SoNguoiToiDa { get; set; }

        [Required(ErrorMessage = "Trạng thái phòng là bắt buộc")]
        [RegularExpression("^(Trống|Đang thuê|Bảo trì)$", ErrorMessage = "Trạng thái không hợp lệ")]
        public string TrangThai { get; set; } = string.Empty;

        [StringLength(1000, ErrorMessage = "Mô tả tối đa 1000 ký tự")]
        public string? MoTa { get; set; }
        public List<int> MaTienIchIds { get; set; } = new();
    }
}