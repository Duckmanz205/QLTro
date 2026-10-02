using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.DTOs;
using PhongTroAPI.Services;
using System;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class HopDongController : ControllerBase
    {
        private readonly HopDongService _hopDongService;

        public HopDongController(HopDongService hopDongService)
        {
            _hopDongService = hopDongService;
        }

        // GET: api/HopDong
        [HttpGet]
        public IActionResult GetAll([FromQuery] int? maQuanLy)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;

            if (int.TryParse(maQuanLyClaim, out int maQuanLyToken))
            {
                var data = _hopDongService.GetAllHopDong(maQuanLyToken);
                return Ok(data);
            }
            else if (int.TryParse(maKhachClaim, out int maKhachToken))
            {
                var data = _hopDongService.GetAllHopDong(null)
                    .Where(hd => hd.MaKhach == maKhachToken)
                    .ToList();
                return Ok(data);
            }

            return Ok(new List<object>());
        }

        // GET: api/HopDong/5
        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (!_hopDongService.VerifyOwnership(id, maQuanLy))
                {
                    return Forbid();
                }
            }

            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int maKhach))
            {
                if (!_hopDongService.VerifyCustomerOwnership(id, maKhach))
                {
                    return Forbid();
                }
            }

            var data = _hopDongService.GetChiTietHopDong(id);
            if (data == null) return NotFound("Không tìm thấy hợp đồng!");
            return Ok(data);
        }

        // POST: api/HopDong
        [HttpPost]
        public IActionResult Create([FromBody] CreateHopDongDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            var result = _hopDongService.CreateHopDong(dto, maQuanLy);
            if (result) return Ok(true);
            return BadRequest("Không thể tạo hợp đồng nháp. Vui lòng kiểm tra lại mã phòng/mã khách.");
        }

        // PUT: api/HopDong/5
        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] CreateHopDongDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            try
            {
                var result = _hopDongService.UpdateHopDong(id, dto, maQuanLy);
                if (result) return Ok(true);
                return BadRequest("Không tìm thấy hợp đồng để cập nhật.");
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message); // Trả về thông báo lỗi nếu hợp đồng đã ký
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Lỗi server: " + ex.Message);
            }
        }

        //  DELETE: api/HopDong/5
       [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            try
            {
                var result = _hopDongService.DeleteHopDong(id, maQuanLy);
                if (result) return Ok(true);
                return BadRequest("Không thể xóa do dính khóa ngoại hoặc không tìm thấy!");
            }
            catch (InvalidOperationException ex)
            {
                // Bắt đúng lỗi nghiệp vụ "Đang hiệu lực" và báo về cho App
                return BadRequest(ex.Message); 
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Lỗi server: " + ex.Message);
            }
        }

        // POST: api/HopDong/5/ky (Giao thức ký số từ điện thoại Khách)
        [HttpPost("{id}/ky")]
        public IActionResult KyHopDong(int id, [FromBody] KyHopDongNangCaoDto dto)
        {
            if (id != dto.MaHopDong) return BadRequest("ID không khớp!");
            
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int maKhach))
            {
                if (!_hopDongService.VerifyCustomerOwnership(id, maKhach))
                {
                    return Forbid();
                }
            }

            var result = _hopDongService.KyHopDongNangCao(dto);
            if (result) return Ok(true);
            return BadRequest("Không thể ký hợp đồng. Có thể hợp đồng đã được ký trước đó!");
        }

        // POST: api/HopDong/5/gia-han
        [HttpPost("{id}/gia-han")]
        public IActionResult GiaHan(int id, [FromBody] GiaHanHopDongDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            var result = _hopDongService.GiaHanHopDong(id, dto, maQuanLy);
            if (result) return Ok(true);
            return BadRequest("Gia hạn thất bại.");
        }

        // POST: api/HopDong/5/yeu-cau-gia-han
        [HttpPost("{id}/yeu-cau-gia-han")]
        public IActionResult YeuCauGiaHan(int id)
        {
            int? maKhach = null;
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int mkId))
            {
                maKhach = mkId;
            }

            var result = _hopDongService.YeuCauGiaHan(id, maKhach);
            if (result) return Ok(true);
            return BadRequest("Gửi yêu cầu gia hạn thất bại.");
        }

        // POST: api/HopDong/5/tu-choi-gia-han
        [HttpPost("{id}/tu-choi-gia-han")]
        public IActionResult TuChoiGiaHan(int id)
        {
            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            var result = _hopDongService.TuChoiGiaHan(id, maQuanLy);
            if (result) return Ok(true);
            return BadRequest("Từ chối gia hạn thất bại.");
        }

        // POST: api/HopDong/5/yeu-cau-ket-thuc-som (User gửi yêu cầu kết thúc hợp đồng sớm)
        [HttpPost("{id}/yeu-cau-ket-thuc-som")]
        public IActionResult YeuCauKetThucSom(int id, [FromBody] YeuCauKetThucSomDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            int? maKhach = null;
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int mkId))
            {
                maKhach = mkId;
            }

            var result = _hopDongService.YeuCauKetThucSom(id, dto, maKhach);
            if (result) return Ok(true);
            return BadRequest("Gửi yêu cầu kết thúc sớm thất bại. Hợp đồng phải đang có hiệu lực.");
        }

        // POST: api/HopDong/5/duyet-ket-thuc-som (Admin duyệt yêu cầu kết thúc sớm)
        [HttpPost("{id}/duyet-ket-thuc-som")]
        public IActionResult DuyetKetThucSom(int id, [FromBody] DuyetKetThucSomDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            var result = _hopDongService.DuyetKetThucSom(id, dto, maQuanLy);
            if (result) return Ok(true);
            return BadRequest("Duyệt kết thúc sớm thất bại.");
        }

        // POST: api/HopDong/5/tu-choi-ket-thuc-som (Admin từ chối yêu cầu kết thúc sớm)
        [HttpPost("{id}/tu-choi-ket-thuc-som")]
        public IActionResult TuChoiKetThucSom(int id)
        {
            int? maQuanLy = null;
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int mqId))
            {
                maQuanLy = mqId;
            }

            var result = _hopDongService.TuChoiKetThucSom(id, maQuanLy);
            if (result) return Ok(true);
            return BadRequest("Từ chối yêu cầu kết thúc sớm thất bại.");
        }

        [HttpGet("{id}/export-pdf")]
        public IActionResult ExportContractPdf(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (!_hopDongService.VerifyOwnership(id, maQuanLy))
                {
                    return Forbid();
                }
            }

            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int maKhach))
            {
                if (!_hopDongService.VerifyCustomerOwnership(id, maKhach))
                {
                    return Forbid();
                }
            }

            // 1. Lấy dữ liệu hợp đồng từ SQL Server ra
            var contract = _hopDongService.GetById(id);
            if (contract == null) return NotFound();

            // 2. Vẽ file hoặc đọc file PDF mẫu đã sinh sẵn từ thư mục wwroot/uploads
            byte[] pdfBytes = _hopDongService.GeneratePdfBytes(contract); 

            // 3. Bắn trả về mảng byte dữ liệu thô kèm định dạng Content-Type chuẩn PDF
            return File(pdfBytes, "application/pdf", $"HopDong_{id}.pdf");
        }
    }
}