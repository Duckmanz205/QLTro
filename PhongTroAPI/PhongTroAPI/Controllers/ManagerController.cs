using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ManagerController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public ManagerController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // GET: api/Manager/{id}/bank-info
        [HttpGet("{id}/bank-info")]
        public async Task<IActionResult> GetBankInfo(int id)
        {
            var manager = await _context.NguoiQuanLies
                .Include(q => q.MaNganHangNavigation)
                .FirstOrDefaultAsync(q => q.MaQuanLy == id);

            if (manager == null)
                return NotFound("Không tìm thấy thông tin quản lý");

            return Ok(new
            {
                maQuanLy = manager.MaQuanLy,
                hoTen = manager.HoTen,
                soTaiKhoan = manager.SoTaiKhoan ?? string.Empty,
                tenTaiKhoan = manager.TenTaiKhoan ?? string.Empty,
                maNganHang = manager.MaNganHang,
                tenNganHang = manager.MaNganHangNavigation?.TenNganHang ?? string.Empty,
                tenVietTat = manager.MaNganHangNavigation?.TenVietTat ?? string.Empty,
                maBin = manager.MaNganHangNavigation?.MaBin ?? string.Empty
            });
        }

        // PUT: api/Manager/{id}/bank-info
        [HttpPut("{id}/bank-info")]
        public async Task<IActionResult> UpdateBankInfo(int id, [FromBody] UpdateBankInfoDto dto)
        {
            var manager = await _context.NguoiQuanLies.FindAsync(id);
            if (manager == null)
                return NotFound("Không tìm thấy thông tin quản lý");

            // Validate bank
            if (dto.MaNganHang.HasValue)
            {
                var bankExists = await _context.NganHangs.AnyAsync(b => b.MaNganHang == dto.MaNganHang.Value);
                if (!bankExists)
                    return BadRequest("Ngân hàng không hợp lệ");
            }

            manager.SoTaiKhoan = dto.SoTaiKhoan?.Trim();
            manager.TenTaiKhoan = dto.TenTaiKhoan?.Trim();
            manager.MaNganHang = dto.MaNganHang;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật tài khoản ngân hàng thành công" });
        }
    }

    public class UpdateBankInfoDto
    {
        public string? SoTaiKhoan { get; set; }
        public string? TenTaiKhoan { get; set; }
        public int? MaNganHang { get; set; }
    }
}
