using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BankController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public BankController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // GET: api/Bank
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var banks = await _context.NganHangs
                .AsNoTracking()
                .OrderBy(b => b.TenVietTat)
                .Select(b => new
                {
                    b.MaNganHang,
                    b.TenNganHang,
                    b.TenVietTat,
                    b.MaBin
                })
                .ToListAsync();

            return Ok(banks);
        }
    }
}
