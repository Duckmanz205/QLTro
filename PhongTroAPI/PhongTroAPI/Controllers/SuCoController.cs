using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using PhongTroAPI.Repositories.Redis;
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
        private readonly SuCoRepository _suCoRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly KhachThueRepository _khachRepo;
        private readonly CounterRepository _counterRepo;
        private readonly NotificationRepository _notificationRepo;

        public SuCoController(
            SuCoRepository suCoRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            KhachThueRepository khachRepo,
            CounterRepository counterRepo,
            NotificationRepository notificationRepo)
        {
            _suCoRepo = suCoRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _khachRepo = khachRepo;
            _counterRepo = counterRepo;
            _notificationRepo = notificationRepo;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<SuCo>>> GetSuCos([FromQuery] int? maQuanLy)
        {
            var tatCaSuCo = await _suCoRepo.GetAllAsync();
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();

            if (!maQuanLy.HasValue)
            {
                var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
                if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int mqId))
                {
                    maQuanLy = mqId;
                }
            }

            var query = tatCaSuCo.AsQueryable();

            if (maQuanLy.HasValue)
            {
                var coSoIds = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLy.Value).Select(cs => cs.MaCoSo).ToHashSet();
                var phongIds = tatCaPhong.Where(p => coSoIds.Contains(p.MaCoSo)).Select(p => p.MaPhong).ToHashSet();
                
                query = query.Where(s => phongIds.Contains(s.MaPhong));
            }

            return Ok(query.OrderByDescending(s => s.NgayBao).ToList());
        }

        [HttpGet("user/{maKhach}")]
        public async Task<ActionResult<IEnumerable<SuCo>>> GetSuCoForUser(int maKhach)
        {
            var allSuCo = await _suCoRepo.GetAllAsync();
            var results = allSuCo.Where(s => s.MaKhach == maKhach).OrderByDescending(s => s.NgayBao).ToList();
            return Ok(results);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SuCo>> GetSuCo(int id)
        {
            var suCo = await _suCoRepo.GetByIdAsync(id);
            if (suCo == null) return NotFound();
            return suCo;
        }

        [HttpPost]
        public async Task<ActionResult<SuCo>> PostSuCo(SuCo suCo)
        {
            suCo.MaSuCo = await _counterRepo.GetNextSequenceValueAsync("suco_id");
            suCo.NgayBao = DateTime.Now;
            suCo.TrangThai = "Chờ xử lý";
            
            await _suCoRepo.CreateAsync(suCo);
            return CreatedAtAction("GetSuCo", new { id = suCo.MaSuCo }, suCo);
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateSuCoStatus(int id, [FromBody] string trangThai)
        {
            var suCo = await _suCoRepo.GetByIdAsync(id);
            if (suCo == null) return NotFound();

            suCo.TrangThai = trangThai;
            if (trangThai == "Đã hoàn thành")
            {
                suCo.NgayXuLy = DateTime.Now;
            }

            await _suCoRepo.UpdateAsync(id, suCo);

            // Notify user via Redis
            var thongBao = new ThongBao
            {
                MaKhach = suCo.MaKhach,
                TieuDe = $"Cập nhật sự cố: {suCo.TieuDe}",
                NoiDung = $"Sự cố '{suCo.TieuDe}' của bạn đã được Admin chuyển sang trạng thái: {trangThai}.",
                NgayGui = DateTime.Now,
                DaDoc = false,
            };
            await _notificationRepo.AddNotificationAsync(suCo.MaKhach, thongBao);

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSuCo(int id)
        {
            var suCo = await _suCoRepo.GetByIdAsync(id);
            if (suCo == null) return NotFound();

            await _suCoRepo.DeleteAsync(id);
            return NoContent();
        }
    }
}
