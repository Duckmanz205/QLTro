using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ThongBaoController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public ThongBaoController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // GET: api/ThongBao
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ThongBao>>> GetThongBaos()
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Ok(new List<ThongBao>());
            }

            var query = _context.ThongBaos.AsQueryable()
                .Where(t => t.MaQuanLy == maQuanLy 
                            && t.TieuDe != "Đặt lịch xem phòng thành công" 
                            && !t.TieuDe.StartsWith("Cập nhật sự cố"));

            return await query.OrderByDescending(t => t.NgayGui).ToListAsync();
        }

        // GET: api/ThongBao/user/5
        [HttpGet("user/{maKhach}")]
        public async Task<ActionResult<IEnumerable<ThongBao>>> GetThongBaoForUser(int maKhach)
        {
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int mkId))
            {
                if (mkId != maKhach)
                {
                    return Forbid();
                }
            }

            return await _context.ThongBaos
                .Where(t => t.MaKhach == maKhach && t.TieuDe != "Đặt lịch xem phòng mới")
                .OrderByDescending(t => t.NgayGui)
                .ToListAsync();
        }

        // POST: api/ThongBao
        [HttpPost]
        public async Task<ActionResult<ThongBao>> PostThongBao(ThongBao thongBao)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Forbid();
            }
            thongBao.MaQuanLy = maQuanLy;
            thongBao.NgayGui = System.DateTime.Now;
            _context.ThongBaos.Add(thongBao);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetThongBaos", new { id = thongBao.MaThongBao }, thongBao);
        }

        // GET: api/ThongBao/danh-sach-khach
        [HttpGet("danh-sach-khach")]
        public async Task<ActionResult<IEnumerable<object>>> GetDanhSachKhach()
        {
            var query = _context.HopDongThues
                .Include(hd => hd.MaKhachNavigation)
                .Include(hd => hd.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
                .Where(hd => hd.TrangThai == "Đang hiệu lực" || hd.TrangThai == "Đã ký");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                query = query.Where(hd => hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy);
            }

            var khachThues = await query
                .Select(hd => new
                {
                    MaKhach = hd.MaKhach,
                    HoTen = hd.MaKhachNavigation.HoTen,
                    SoPhong = hd.MaPhongNavigation.SoPhong
                })
                .Distinct()
                .ToListAsync();
            
            return Ok(khachThues);
        }
    }
}
