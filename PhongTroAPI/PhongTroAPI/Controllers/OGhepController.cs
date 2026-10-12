using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.DTOs;
using PhongTroAPI.Services;
using System;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OGhepController : ControllerBase
    {
        private readonly OGhepService _oGhepService; // : Gọi đúng Service tương ứng

        public OGhepController(OGhepService oGhepService)
        {
            _oGhepService = oGhepService;
        }

        // GET: api/OGhep/chi-tiet/{maPhong}
        [HttpGet("chi-tiet/{maPhong}")]
        public async Task<IActionResult> GetChiTietOGhep(int maPhong)
        {
            var result = await _oGhepService.GetChiTietOGhepTheoPhongAsync(maPhong);
            
            if (result == null)
                return NotFound(new { message = "Không tìm thấy phòng yêu cầu hoặc phòng chưa được kích hoạt hệ thống!" });

            return Ok(result);
        }

        // BỔ SUNG ĐỦ LUỒNG ROUTER CRUD ĐỂ APP MOBILE GỌI ĐƯỢC
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateOGhepDto dto)
        {
            var res = await _oGhepService.CreateOGhepAsync(dto);
            return res ? Ok(true) : BadRequest("Thất bại, vui lòng kiểm tra mã khách thuê.");
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await _oGhepService.GetAllOGhepsAsync());
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var data = await _oGhepService.GetOGhepByIdAsync(id);
            if (data == null) return NotFound("Bài đăng không tồn tại!");
            return Ok(data);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CreateOGhepDto dto)
        {
            return await _oGhepService.UpdateOGhepAsync(id, dto) ? Ok(true) : BadRequest("Cập nhật bài đăng thất bại.");
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            return await _oGhepService.DeleteOGhepAsync(id) ? Ok(true) : BadRequest("Xóa bài đăng thất bại.");
        }
    }
}