using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SuCoController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public SuCoController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // GET: api/SuCo
        // Lấy danh sách tất cả sự cố (Dành cho Admin)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SuCo>>> GetSuCos([FromQuery] int? maQuanLy)
        {
            var query = _context.SuCos
                .Include(s => s.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                .Include(s => s.MaKhachNavigation)
                .AsQueryable();

            if (!maQuanLy.HasValue)
            {
                var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
                if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int mqId))
                {
                    maQuanLy = mqId;
                }
            }

            if (maQuanLy.HasValue)
            {
                query = query.Where(s => s.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy.Value);
            }

            return await query.OrderByDescending(s => s.NgayBao).ToListAsync();
        }

        // GET: api/SuCo/user/5
        // Lấy danh sách sự cố của một khách thuê
        [HttpGet("user/{maKhach}")]
        public async Task<ActionResult<IEnumerable<SuCo>>> GetSuCoForUser(int maKhach)
        {
            return await _context.SuCos
                .Where(s => s.MaKhach == maKhach)
                .Include(s => s.MaPhongNavigation)
                .OrderByDescending(s => s.NgayBao)
                .ToListAsync();
        }

        // GET: api/SuCo/5
        [HttpGet("{id}")]
        public async Task<ActionResult<SuCo>> GetSuCo(int id)
        {
            var suCo = await _context.SuCos
                .Include(s => s.MaPhongNavigation)
                .Include(s => s.MaKhachNavigation)
                .FirstOrDefaultAsync(s => s.MaSuCo == id);

            if (suCo == null)
            {
                return NotFound();
            }

            return suCo;
        }

        // POST: api/SuCo
        // Gửi báo cáo sự cố mới (Dành cho khách thuê)
        [HttpPost]
        public async Task<ActionResult<SuCo>> PostSuCo(SuCo suCo)
        {
            suCo.NgayBao = DateTime.Now;
            suCo.TrangThai = "Chờ xử lý"; // Trạng thái mặc định ban đầu
            
            _context.SuCos.Add(suCo);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetSuCo", new { id = suCo.MaSuCo }, suCo);
        }

        // PUT: api/SuCo/5/status
        // Cập nhật trạng thái sự cố (Dành cho Admin)
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateSuCoStatus(int id, [FromBody] string trangThai)
        {
            var suCo = await _context.SuCos.FindAsync(id);
            if (suCo == null)
            {
                return NotFound();
            }

            suCo.TrangThai = trangThai;
            if (trangThai == "Đã hoàn thành")
            {
                suCo.NgayXuLy = DateTime.Now;
            }

            // Tạo thông báo tự động cho Khách thuê
            var thongBao = new ThongBao
            {
                MaKhach = suCo.MaKhach,
                TieuDe = $"Cập nhật sự cố: {suCo.TieuDe}",
                NoiDung = $"Sự cố '{suCo.TieuDe}' của bạn đã được Admin chuyển sang trạng thái: {trangThai}.",
                NgayGui = DateTime.Now,
                DaDoc = false,
            };
            _context.ThongBaos.Add(thongBao);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!SuCoExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/SuCo/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSuCo(int id)
        {
            var suCo = await _context.SuCos.FindAsync(id);
            if (suCo == null)
            {
                return NotFound();
            }

            _context.SuCos.Remove(suCo);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool SuCoExists(int id)
        {
            return _context.SuCos.Any(e => e.MaSuCo == id);
        }
    }
}
