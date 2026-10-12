using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.Entities;
using System.Threading.Tasks;
using System.Collections.Generic;
using PhongTroAPI.Repositories.Mongo;
using System.Linq;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class KhachThueController : ControllerBase
    {
        private readonly KhachThueRepository _khachThueRepo;
        private readonly HopDongRepository _hopDongRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;

        public KhachThueController(
            KhachThueRepository khachThueRepo,
            HopDongRepository hopDongRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo)
        {
            _khachThueRepo = khachThueRepo;
            _hopDongRepo = hopDongRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
        }

        // GET: api/KhachThue
        [HttpGet]
        public async Task<ActionResult<IEnumerable<KhachThue>>> GetKhachThues()
        {
            var khachThues = await _khachThueRepo.GetAllAsync();
            return Ok(khachThues);
        }

        // GET: api/KhachThue/5
        [HttpGet("{id}")]
        public async Task<ActionResult<KhachThue>> GetKhachThue(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await VerifyOwnershipAsync(id, maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var khachThue = await _khachThueRepo.GetByIdAsync(id);

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
                var belongsToAdmin = await VerifyOwnershipAsync(id, maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var existingKhach = await _khachThueRepo.GetByIdAsync(id);
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

            await _khachThueRepo.UpdateAsync(id, existingKhach);

            return NoContent();
        }

        private async Task<bool> VerifyOwnershipAsync(int maKhach, int maQuanLy)
        {
            var hopDongs = await _hopDongRepo.GetAllAsync();
            var khachHopDongs = hopDongs.Where(h => h.MaKhach == maKhach).ToList();
            
            foreach (var hd in khachHopDongs)
            {
                var phong = await _phongRepo.GetByIdAsync(hd.MaPhong);
                if (phong != null)
                {
                    var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
                    if (coSo != null && coSo.MaQuanLy == maQuanLy)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}
