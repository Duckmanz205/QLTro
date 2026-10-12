using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
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
        private readonly ThongBaoRepository _thongBaoRepo;
        private readonly HopDongRepository _hopDongRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly KhachThueRepository _khachRepo;
        private readonly CounterRepository _counterRepo;

        public ThongBaoController(
            ThongBaoRepository thongBaoRepo,
            HopDongRepository hopDongRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            KhachThueRepository khachRepo,
            CounterRepository counterRepo)
        {
            _thongBaoRepo = thongBaoRepo;
            _hopDongRepo = hopDongRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _khachRepo = khachRepo;
            _counterRepo = counterRepo;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ThongBao>>> GetThongBaos()
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Ok(new List<ThongBao>());
            }

            var tatCaThongBao = await _thongBaoRepo.GetAllAsync();
            var results = tatCaThongBao
                .Where(t => t.MaQuanLy == maQuanLy 
                            && t.TieuDe != "Đặt lịch xem phòng thành công" 
                            && (t.TieuDe == null || !t.TieuDe.StartsWith("Cập nhật sự cố")))
                .OrderByDescending(t => t.NgayGui)
                .ToList();

            return Ok(results);
        }

        [HttpGet("user/{maKhach}")]
        public async Task<ActionResult<IEnumerable<ThongBao>>> GetThongBaoForUser(int maKhach)
        {
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int mkId))
            {
                if (mkId != maKhach) return Forbid();
            }

            var tatCaThongBao = await _thongBaoRepo.GetAllAsync();
            var results = tatCaThongBao
                .Where(t => t.MaKhach == maKhach && t.TieuDe != "Đặt lịch xem phòng mới")
                .OrderByDescending(t => t.NgayGui)
                .ToList();

            return Ok(results);
        }

        [HttpPost]
        public async Task<ActionResult<ThongBao>> PostThongBao(ThongBao thongBao)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Forbid();
            }
            thongBao.MaThongBao = await _counterRepo.GetNextSequenceValueAsync("thongbao_id");
            thongBao.MaQuanLy = maQuanLy;
            thongBao.NgayGui = System.DateTime.Now;
            
            await _thongBaoRepo.CreateAsync(thongBao);

            return CreatedAtAction("GetThongBaos", new { id = thongBao.MaThongBao }, thongBao);
        }

        [HttpGet("danh-sach-khach")]
        public async Task<ActionResult<IEnumerable<object>>> GetDanhSachKhach()
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Forbid();
            }

            var tatCaHopDong = await _hopDongRepo.GetAllAsync();
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            var tatCaKhach = await _khachRepo.GetAllAsync();

            var hopDongs = tatCaHopDong.Where(hd => hd.TrangThai == "Đang hiệu lực" || hd.TrangThai == "Đã ký").ToList();
            
            var results = new List<object>();

            foreach (var hd in hopDongs)
            {
                var phong = tatCaPhong.FirstOrDefault(p => p.MaPhong == hd.MaPhong);
                if (phong != null)
                {
                    var coSo = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == phong.MaCoSo);
                    if (coSo != null && coSo.MaQuanLy == maQuanLy)
                    {
                        var khach = tatCaKhach.FirstOrDefault(k => k.MaKhach == hd.MaKhach);
                        if (khach != null)
                        {
                            results.Add(new
                            {
                                MaKhach = hd.MaKhach,
                                HoTen = khach.HoTen,
                                SoPhong = phong.SoPhong
                            });
                        }
                    }
                }
            }

            // Distinct
            var uniqueResults = results
                .GroupBy(x => new { ((dynamic)x).MaKhach, ((dynamic)x).HoTen, ((dynamic)x).SoPhong })
                .Select(g => g.First())
                .ToList();

            return Ok(uniqueResults);
        }
    }
}
