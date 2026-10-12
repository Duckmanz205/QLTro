using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.Repositories.Mongo;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ManagerController : ControllerBase
    {
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly NganHangRepository _nganHangRepo;

        public ManagerController(NguoiQuanLyRepository quanLyRepo, NganHangRepository nganHangRepo)
        {
            _quanLyRepo = quanLyRepo;
            _nganHangRepo = nganHangRepo;
        }

        // GET: api/Manager/{id}/bank-info
        [HttpGet("{id}/bank-info")]
        public async Task<IActionResult> GetBankInfo(int id)
        {
            var manager = await _quanLyRepo.GetByIdAsync(id);

            if (manager == null)
                return NotFound("Không tìm thấy thông tin quản lý");

            string tenNganHang = string.Empty;
            string tenVietTat = string.Empty;
            string maBin = string.Empty;

            if (manager.ThongTinNganHang != null && manager.ThongTinNganHang.MaNganHang.HasValue)
            {
                var bank = await _nganHangRepo.GetByIdAsync(manager.ThongTinNganHang.MaNganHang.Value);
                if (bank != null)
                {
                    tenNganHang = bank.TenNganHang ?? string.Empty;
                    tenVietTat = bank.TenVietTat ?? string.Empty;
                    maBin = bank.MaBin ?? string.Empty;
                }
            }

            return Ok(new
            {
                maQuanLy = manager.MaQuanLy,
                hoTen = manager.HoTen,
                soTaiKhoan = manager.ThongTinNganHang?.SoTaiKhoan ?? string.Empty,
                chuTaiKhoan = manager.ThongTinNganHang?.ChuTaiKhoan ?? string.Empty,
                maNganHang = manager.ThongTinNganHang?.MaNganHang,
                tenNganHang = tenNganHang,
                tenVietTat = tenVietTat,
                maBin = maBin
            });
        }

        // PUT: api/Manager/{id}/bank-info
        [HttpPut("{id}/bank-info")]
        public async Task<IActionResult> UpdateBankInfo(int id, [FromBody] UpdateBankInfoDto dto)
        {
            var manager = await _quanLyRepo.GetByIdAsync(id);
            if (manager == null)
                return NotFound("Không tìm thấy thông tin quản lý");

            // Validate bank
            if (dto.MaNganHang.HasValue)
            {
                var bank = await _nganHangRepo.GetByIdAsync(dto.MaNganHang.Value);
                if (bank == null)
                    return BadRequest("Ngân hàng không hợp lệ");
            }

            if (manager.ThongTinNganHang == null) manager.ThongTinNganHang = new PhongTroAPI.Entities.Embedded.ThongTinNganHangItem();
            manager.ThongTinNganHang.SoTaiKhoan = dto.SoTaiKhoan?.Trim();
            manager.ThongTinNganHang.ChuTaiKhoan = dto.ChuTaiKhoan?.Trim();
            if (manager.ThongTinNganHang != null) manager.ThongTinNganHang.MaNganHang = dto.MaNganHang;

            await _quanLyRepo.UpdateAsync(id, manager);

            return Ok(new { message = "Cập nhật tài khoản ngân hàng thành công" });
        }
    }

    public class UpdateBankInfoDto
    {
        public string? SoTaiKhoan { get; set; }
        public string? ChuTaiKhoan { get; set; }
        public int? MaNganHang { get; set; }
    }
}
