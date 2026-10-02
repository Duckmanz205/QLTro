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
        public IActionResult GetChiTietOGhep(int maPhong)
        {
            var result = _oGhepService.GetChiTietOGhepTheoPhong(maPhong);
            
            if (result == null)
                return NotFound(new { message = "Không tìm thấy phòng yêu cầu hoặc phòng chưa được kích hoạt hệ thống!" });

            return Ok(result);
        }

        // BỔ SUNG ĐỦ LUỒNG ROUTER CRUD ĐỂ APP MOBILE GỌI ĐƯỢC
        [HttpPost]
        public IActionResult Create([FromBody] CreateOGhepDto dto)
        {
            var res = _oGhepService.CreateOGhep(dto);
            return res ? Ok(true) : BadRequest("Thất bại, vui lòng kiểm tra mã khách thuê.");
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_oGhepService.GetAllOGheps());
        }

        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var data = _oGhepService.GetOGhepById(id);
            if (data == null) return NotFound("Bài đăng không tồn tại!");
            return Ok(data);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] CreateOGhepDto dto)
        {
            return _oGhepService.UpdateOGhep(id, dto) ? Ok(true) : BadRequest("Cập nhật bài đăng thất bại.");
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            return _oGhepService.DeleteOGhep(id) ? Ok(true) : BadRequest("Xóa bài đăng thất bại.");
        }
    }
}