using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.Entities;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class KhachThueController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public KhachThueController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // GET: api/KhachThue
        [HttpGet]
        public async Task<ActionResult<IEnumerable<KhachThue>>> GetKhachThues()
        {
            // Trả về toàn bộ danh sách khách thuê để Chủ trọ/Quản lý có thể tìm kiếm và lập hợp đồng mới
            return await _context.KhachThues.ToListAsync();
        }

        // GET: api/KhachThue/5
        [HttpGet("{id}")]
        public async Task<ActionResult<KhachThue>> GetKhachThue(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.HopDongThues
                    .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                    .AnyAsync(hd => hd.MaKhach == id && hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy);

                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var khachThue = await _context.KhachThues
                .FirstOrDefaultAsync(k => k.MaKhach == id);

            if (khachThue == null)
            {
                return NotFound();
            }

            return khachThue;
        }

        // PUT: api/KhachThue/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutKhachThue(int id, KhachThue khachThue)
        {
            if (id != khachThue.MaKhach)
            {
                return BadRequest("ID không khớp");
            }

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.HopDongThues
                    .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                    .AnyAsync(hd => hd.MaKhach == id && hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy);

                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var existingKhach = await _context.KhachThues.FindAsync(id);
            if (existingKhach == null)
            {
                return NotFound("Không tìm thấy khách thuê");
            }

            existingKhach.HoTen = khachThue.HoTen;
            existingKhach.Sdt = khachThue.Sdt;
            existingKhach.Email = khachThue.Email;
            existingKhach.Cccd = khachThue.Cccd;
            existingKhach.GioiTinh = khachThue.GioiTinh;
            existingKhach.DiaChiThuongTru = khachThue.DiaChiThuongTru;

            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
