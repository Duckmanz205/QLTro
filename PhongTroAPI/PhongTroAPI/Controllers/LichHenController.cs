using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.DTOs;
using PhongTroAPI.Services;
using System;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class LichHenController : ControllerBase
    {
        private readonly LichHenService _lichHenService;

        public LichHenController(LichHenService lichHenService)
        {
            _lichHenService = lichHenService;
        }

        //  1. POST: /api/LichHen/dat-lich -> Khớp 100% với Service ngầm bên Flutter gọi sang
        [HttpPost("dat-lich")]
        public IActionResult DatLich([FromBody] CreateLichHenDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var isSuccess = _lichHenService.CreateLichHen(dto);
            if (isSuccess) 
                return Ok(new { success = true, message = "Đặt lịch xem phòng thành công!" });
                
            return BadRequest(new { success = false, message = "Đã xảy ra lỗi khi lưu lịch hẹn." });
        }

        //  2. GET: /api/LichHen/lich-su/{maKhach} -> API mới tinh cho 2 trang UI của Thái load lịch sử
        [HttpGet("lich-su/{maKhach}")]
        public IActionResult GetLichSuXemPhong(int maKhach)
        {
            // Gọi hàm xử lý lọc danh sách theo mã khách từ Service của ông
            var data = _lichHenService.GetDanhSachLichHenByKhach(maKhach);
            return Ok(data);
        }

        // 3. GET: /api/LichHen – Dành cho màn hình danh sách tổng cục bên Admin (Giữ nguyên)
        [HttpGet]
        public IActionResult GetDanhSach([FromQuery] int? maQuanLy)
        {
            if (maQuanLy == null)
            {
                var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
                if (int.TryParse(maQuanLyClaim, out int mqId))
                {
                    maQuanLy = mqId;
                }
            }
            if (maQuanLy == null)
            {
                return Ok(new List<object>());
            }
            var data = _lichHenService.GetDanhSachLichHen(maQuanLy);
            return Ok(data);
        }

        // 4. PUT: /api/LichHen/{id}/status -> Dành cho nút Duyệt / Hoàn thành nhanh bên Admin (Giữ nguyên)
        [HttpPut("{id}/status")]
        public IActionResult CapNhatTrangThai(int id, [FromBody] UpdateStatusDto dto)
        {
            if (dto == null || string.IsNullOrEmpty(dto.TrangThaiMoi))
            {
                return BadRequest(new { message = "Dữ liệu trạng thái mới không hợp lệ." });
            }

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (!_lichHenService.VerifyOwnership(id, maQuanLy))
                {
                    return Forbid();
                }
            }

            var isSuccess = _lichHenService.UpdateTrangThaiLich(id, dto.TrangThaiMoi);
            if (isSuccess) 
                return Ok(new { message = $"Đã cập nhật trạng thái lịch hẹn sang: {dto.TrangThaiMoi}" });
                
            return NotFound(new { message = "Không tìm thấy lịch hẹn yêu cầu." });
        }

        // 5. PUT: /api/LichHen/{id} -> Tiếp nhận dữ liệu chỉnh sửa thô từ màn hình AD_EditLich (Giữ nguyên)
        [HttpPut("{id}")]
        public IActionResult SuaThongTinLichHen(int id, [FromBody] CreateLichHenDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (!_lichHenService.VerifyOwnership(id, maQuanLy))
                {
                    return Forbid();
                }
            }

            var isSuccess = _lichHenService.UpdateLichHen(id, dto);
            if (isSuccess) 
                return Ok(new { message = "Cập nhật thông tin lịch hẹn thành công!" });
                
            return NotFound(new { message = "Không tìm thấy lịch hẹn hoặc dữ liệu không thay đổi." });
        }

        // 6. DELETE: /api/LichHen/{id} -> Nút bấm xác nhận xoá hẳn bên màn hình AD_DeleteLich (Giữ nguyên)
        [HttpDelete("{id}")]
        public IActionResult XoaLichHen(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (!_lichHenService.VerifyOwnership(id, maQuanLy))
                {
                    return Forbid();
                }
            }

            var isSuccess = _lichHenService.DeleteLichHen(id);
            if (isSuccess) 
                return Ok(new { message = "Đã xóa vĩnh viễn lịch hẹn ra khỏi cơ sở dữ liệu hệ thống!" });
                
            return NotFound(new { message = "Không tìm thấy lịch hẹn hoặc bản ghi đã bị xóa trước đó." });
        }

        // 7. GET: /api/LichHen/{id} -> Lấy chi tiết 1 lịch hẹn (Giữ nguyên)
        [HttpGet("{id}")]
        public IActionResult GetChiTietLichHen(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (!_lichHenService.VerifyOwnership(id, maQuanLy))
                {
                    return Forbid();
                }
            }

            var data = _lichHenService.GetLichHenById(id);
            
            if (data == null) 
                return NotFound(new { message = "Không tìm thấy thông tin lịch hẹn này." });

            return Ok(data);
        }
    }
}