using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NguoiQuanLyController : ControllerBase
    {
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly NganHangRepository _nganHangRepo;
        private readonly CounterRepository _counterRepo;

        public NguoiQuanLyController(
            NguoiQuanLyRepository quanLyRepo,
            NganHangRepository nganHangRepo,
            CounterRepository counterRepo)
        {
            _quanLyRepo = quanLyRepo;
            _nganHangRepo = nganHangRepo;
            _counterRepo = counterRepo;
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<NguoiQuanLy>> GetNguoiQuanLy(int id)
        {
            var nguoiQuanLy = await _quanLyRepo.GetByIdAsync(id);
            if (nguoiQuanLy == null) return NotFound();

            if (nguoiQuanLy.ThongTinNganHang != null && nguoiQuanLy.ThongTinNganHang.MaNganHang.HasValue)
            {
                var bank = await _nganHangRepo.GetByIdAsync(nguoiQuanLy.ThongTinNganHang.MaNganHang.Value);
                if (bank != null)
                {
                    if (nguoiQuanLy.ThongTinNganHang != null) nguoiQuanLy.ThongTinNganHang.TenNganHang = bank.TenNganHang;
                }
            }

            return nguoiQuanLy;
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> PutNguoiQuanLy(int id, NguoiQuanLy nguoiQuanLy)
        {
            if (id != nguoiQuanLy.MaQuanLy) return BadRequest();

            var existingManager = await _quanLyRepo.GetByIdAsync(id);
            if (existingManager == null) return NotFound();

            if (!string.IsNullOrEmpty(nguoiQuanLy.ThongTinNganHang?.TenNganHang))
            {
                var allBanks = await _nganHangRepo.GetAllAsync();
                var bank = allBanks.FirstOrDefault(b => b.TenNganHang == nguoiQuanLy.ThongTinNganHang?.TenNganHang);
                
                if (bank == null)
                {
                    int newMaNganHang = await _counterRepo.GetNextSequenceValueAsync("nganhang_id");
                    bank = new NganHang { MaNganHang = newMaNganHang, TenNganHang = nguoiQuanLy.ThongTinNganHang?.TenNganHang, MaBin = "0000" };
                    await _nganHangRepo.CreateAsync(bank);
                }
                existingManager.ThongTinNganHang.MaNganHang = bank.MaNganHang;
            }

            existingManager.HoTen = nguoiQuanLy.HoTen;
            if (existingManager.ThongTinNganHang == null) existingManager.ThongTinNganHang = new PhongTroAPI.Entities.Embedded.ThongTinNganHangItem();

            existingManager.Sdt = nguoiQuanLy.Sdt;
            existingManager.Email = nguoiQuanLy.Email;
            existingManager.ThongTinNganHang.SoTaiKhoan = nguoiQuanLy.ThongTinNganHang?.SoTaiKhoan;
            existingManager.ThongTinNganHang.ChuTaiKhoan = nguoiQuanLy.ThongTinNganHang?.ChuTaiKhoan;

            await _quanLyRepo.UpdateAsync(id, existingManager);
            return NoContent();
        }
    }
}
