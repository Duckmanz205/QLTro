using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.DTOs;
using PhongTroAPI.Services;

namespace PhongTroAPI.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class InvoiceController : ControllerBase
{
    private readonly IInvoiceService _invoiceService;

    public InvoiceController(IInvoiceService invoiceService)
    {
        _invoiceService = invoiceService;
    }

    /// <summary>
    /// Lấy danh sách hóa đơn. Nếu không truyền month/year sẽ trả về tất cả.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<InvoiceDto>>> GetInvoices([FromQuery] int? month, [FromQuery] int? year)
    {
        try
        {
            if (month.HasValue && (month < 1 || month > 12))
            {
                return BadRequest(new { message = "Tháng không hợp lệ (1-12)." });
            }
            if (year.HasValue && year < 2000)
            {
                return BadRequest(new { message = "Năm không hợp lệ." });
            }

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Ok(new List<InvoiceDto>());
            }

            var invoices = await _invoiceService.GetInvoicesAsync(month, year, maQuanLy);
            return Ok(invoices);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi lấy danh sách hóa đơn.", error = ex.Message });
        }
    }

    /// <summary>
    /// Lấy danh sách hóa đơn theo mã khách thuê.
    /// </summary>
    [HttpGet("by-customer/{maKhach}")]
    public async Task<ActionResult<List<InvoiceDto>>> GetInvoicesByCustomer(int maKhach)
    {
        try
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;

            if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _invoiceService.VerifyCustomerOwnershipAsync(maKhach, maQuanLy);
                if (!belongsToAdmin) return Forbid();
            }
            else if (!string.IsNullOrEmpty(maKhachClaim) && int.TryParse(maKhachClaim, out int userMaKhach))
            {
                if (userMaKhach != maKhach) return Forbid();
            }
            else
            {
                return Forbid();
            }

            var invoices = await _invoiceService.GetInvoicesByCustomerAsync(maKhach);
            return Ok(invoices);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi lấy danh sách hóa đơn theo khách.", error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<InvoiceDto>> GetInvoice(int id)
    {
        try
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _invoiceService.VerifyInvoiceOwnershipAsync(id, maQuanLy);
                if (!belongsToAdmin) return Forbid();
            }

            var invoice = await _invoiceService.GetInvoiceByIdAsync(id);
            if (invoice == null)
            {
                return NotFound(new { message = "Không tìm thấy hóa đơn." });
            }
            return Ok(invoice);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi lấy chi tiết hóa đơn.", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<InvoiceDto>> CreateInvoice([FromBody] InvoiceCreateDto createDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _invoiceService.VerifyRoomOwnershipAsync(createDto.MaPhong, maQuanLy);
                if (!belongsToAdmin) return Forbid("Phòng không thuộc quyền quản lý của bạn.");
            }

            if (createDto.SoDienMoi < createDto.SoDienCu || createDto.SoNuocMoi < createDto.SoNuocCu)
            {
                return BadRequest(new { message = "Chỉ số mới không được nhỏ hơn chỉ số cũ." });
            }

            var createdInvoice = await _invoiceService.CreateInvoiceAsync(createDto);
            return CreatedAtAction(nameof(GetInvoice), new { id = createdInvoice.MaHoaDon }, createdInvoice);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi tạo hóa đơn.", error = ex.Message });
        }
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] InvoiceUpdateStatusDto updateDto)
    {
        try
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _invoiceService.VerifyInvoiceOwnershipAsync(id, maQuanLy);
                if (!belongsToAdmin) return Forbid();
            }

            var success = await _invoiceService.UpdateInvoiceStatusAsync(id, updateDto);
            if (!success)
            {
                return NotFound(new { message = "Không tìm thấy hóa đơn cần cập nhật." });
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi cập nhật trạng thái hóa đơn.", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateInvoice(int id, [FromBody] InvoiceUpdateDto updateDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _invoiceService.VerifyInvoiceOwnershipAsync(id, maQuanLy);
                if (!belongsToAdmin) return Forbid();
            }

            var success = await _invoiceService.UpdateInvoiceAsync(id, updateDto);
            if (!success)
            {
                return NotFound(new { message = "Không tìm thấy hóa đơn cần cập nhật." });
            }

            return Ok(new { message = "Cập nhật hóa đơn thành công!" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi cập nhật hóa đơn.", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteInvoice(int id)
    {
        try
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (!string.IsNullOrEmpty(maQuanLyClaim) && int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _invoiceService.VerifyInvoiceOwnershipAsync(id, maQuanLy);
                if (!belongsToAdmin) return Forbid();
            }

            var success = await _invoiceService.DeleteInvoiceAsync(id);
            if (!success)
            {
                return NotFound(new { message = "Không tìm thấy hóa đơn cần xóa." });
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi xóa hóa đơn.", error = ex.Message });
        }
    }
}
