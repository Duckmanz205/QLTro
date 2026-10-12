using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.Repositories.Mongo;
using System.Linq;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BankController : ControllerBase
    {
        private readonly NganHangRepository _nganHangRepo;

        public BankController(NganHangRepository nganHangRepo)
        {
            _nganHangRepo = nganHangRepo;
        }

        // GET: api/Bank
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var banks = await _nganHangRepo.GetAllAsync();
            var data = banks
                .OrderBy(b => b.TenVietTat)
                .Select(b => new
                {
                    b.MaNganHang,
                    b.TenNganHang,
                    b.TenVietTat,
                    b.MaBin
                })
                .ToList();

            return Ok(data);
        }
    }
}
