using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class UtilityReadingController : ControllerBase
{
    private readonly QuanLyPhongTroContext _context;

    public UtilityReadingController(QuanLyPhongTroContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Lấy danh sách chỉ số điện nước theo tháng/năm (bao gồm phòng chưa nhập).
    /// Trả về tất cả phòng kèm chỉ số điện nước (nếu đã nhập) cho tháng/năm đó.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetUtilityReadings([FromQuery] int month, [FromQuery] int year)
    {
        if (month < 1 || month > 12 || year < 2000)
            return BadRequest(new { message = "Tháng/năm không hợp lệ." });

        var roomsQuery = _context.Phongs.AsQueryable();

        var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
        if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int mqId))
        {
            return Ok(new List<object>());
        }
        int maQuanLy = mqId;
        roomsQuery = roomsQuery.Where(p => p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLy);

        // Lấy tất cả phòng kèm thông tin cơ sở + khách thuê (từ hợp đồng) của manager
        var rooms = await roomsQuery
            .Include(p => p.MaCoSoNavigation)
            .OrderBy(p => p.MaCoSo)
            .ThenBy(p => p.SoPhong)
            .Select(p => new
            {
                p.MaPhong,
                p.SoPhong,
                p.Tang,
                p.TrangThai,
                TenCoSo = p.MaCoSoNavigation != null ? p.MaCoSoNavigation.TenCoSo : "",
                MaCoSo = p.MaCoSo,
                DonGiaDien = p.MaCoSoNavigation != null ? p.MaCoSoNavigation.DonGiaDien : 3500,
                DonGiaNuoc = p.MaCoSoNavigation != null ? p.MaCoSoNavigation.DonGiaNuoc : 20000,
                // Lấy khách thuê từ hợp đồng đang hiệu lực
                TenKhachThue = _context.HopDongThues
                    .Where(hd => hd.MaPhong == p.MaPhong && hd.TrangThai == "Đang hiệu lực")
                    .Join(_context.KhachThues, hd => hd.MaKhach, k => k.MaKhach, (hd, k) => k.HoTen)
                    .FirstOrDefault() ?? "",
            })
            .ToListAsync();

        // Lấy chỉ số điện nước đã nhập cho tháng/năm
        var readings = await _context.ChiSoDienNuocs
            .Where(c => c.Thang == month && c.Nam == year)
            .ToListAsync();

        var readingMap = readings.ToDictionary(r => r.MaPhong);

        // Tìm chỉ số mới của tháng trước để làm chỉ số cũ
        int prevMonth = month == 1 ? 12 : month - 1;
        int prevYear = month == 1 ? year - 1 : year;
        var prevReadings = await _context.ChiSoDienNuocs
            .Where(c => c.Thang == prevMonth && c.Nam == prevYear)
            .ToListAsync();
        var prevReadingMap = prevReadings.ToDictionary(r => r.MaPhong);

        // Lấy hóa đơn mới nhất của từng phòng để làm chỉ số cũ mặc định tối cao
        var latestInvoices = await _context.HoaDons.ToListAsync();
        var latestInvoiceMap = latestInvoices
            .GroupBy(h => h.MaPhong)
            .ToDictionary(
                g => g.Key,
                g => g.OrderByDescending(h => h.Nam).ThenByDescending(h => h.Thang).First()
            );

        // Lấy hợp đồng đang hiệu lực để làm chỉ số cũ mặc định ban đầu
        var activeContracts = await _context.HopDongThues
            .Where(hd => hd.TrangThai == "Đang hiệu lực")
            .ToListAsync();
        var activeContractMap = activeContracts
            .GroupBy(hd => hd.MaPhong)
            .ToDictionary(
                g => g.Key,
                g => g.OrderByDescending(hd => hd.NgayBatDau).First()
            );

        var result = rooms.Select(r =>
        {
            var hasReading = readingMap.TryGetValue(r.MaPhong, out var reading);
            var hasPrev = prevReadingMap.TryGetValue(r.MaPhong, out var prevReading);
            var hasLatestInvoice = latestInvoiceMap.TryGetValue(r.MaPhong, out var latestInvoice);
            var hasActiveContract = activeContractMap.TryGetValue(r.MaPhong, out var activeContract);

            int defaultDienCu = hasLatestInvoice 
                ? Convert.ToInt32(latestInvoice.ChiSoDienMoi) 
                : (hasPrev && prevReading!.ChiSoDienMoi.HasValue 
                    ? prevReading.ChiSoDienMoi.Value 
                    : (hasActiveContract && activeContract!.ChiSoDienCu.HasValue ? activeContract.ChiSoDienCu.Value : 0));

            int defaultNuocCu = hasLatestInvoice 
                ? Convert.ToInt32(latestInvoice.ChiSoNuocMoi) 
                : (hasPrev && prevReading!.ChiSoNuocMoi.HasValue 
                    ? prevReading.ChiSoNuocMoi.Value 
                    : (hasActiveContract && activeContract!.ChiSoNuocCu.HasValue ? activeContract.ChiSoNuocCu.Value : 0));

            return new
            {
                r.MaPhong,
                r.SoPhong,
                r.Tang,
                r.TrangThai,
                r.TenCoSo,
                r.MaCoSo,
                r.DonGiaDien,
                r.DonGiaNuoc,
                r.TenKhachThue,
                MaChiSo = hasReading ? reading!.MaChiSo : (int?)null,
                // Chỉ số cũ: lấy từ record hiện tại, nếu không có lấy từ hóa đơn mới nhất hoặc chỉ số mới tháng trước
                ChiSoDienCu = hasReading ? reading!.ChiSoDienCu : defaultDienCu,
                ChiSoDienMoi = hasReading ? reading!.ChiSoDienMoi : (int?)null,
                ChiSoNuocCu = hasReading ? reading!.ChiSoNuocCu : defaultNuocCu,
                ChiSoNuocMoi = hasReading ? reading!.ChiSoNuocMoi : (int?)null,
                DaLapHoaDon = hasReading && reading!.DaLapHoaDon,
            };
        }).ToList();

        return Ok(result);
    }

    /// <summary>
    /// Lưu hoặc cập nhật chỉ số điện nước cho 1 phòng.
    /// Nếu chưa có record thì tạo mới, có rồi thì cập nhật.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SaveReading([FromBody] SaveReadingDto dto)
    {
        if (dto.Thang < 1 || dto.Thang > 12 || dto.Nam < 2000)
            return BadRequest(new { message = "Tháng/năm không hợp lệ." });

        try
        {
            var existing = await _context.ChiSoDienNuocs
                .FirstOrDefaultAsync(c => c.MaPhong == dto.MaPhong && c.Thang == dto.Thang && c.Nam == dto.Nam);

            if (existing != null)
            {
                // Cập nhật
                existing.ChiSoDienCu = dto.ChiSoDienCu;
                existing.ChiSoDienMoi = dto.ChiSoDienMoi;
                existing.ChiSoNuocCu = dto.ChiSoNuocCu;
                existing.ChiSoNuocMoi = dto.ChiSoNuocMoi;
                existing.NgayCapNhat = DateTime.Now;
            }
            else
            {
                // Tạo mới
                var newReading = new ChiSoDienNuoc
                {
                    MaPhong = dto.MaPhong,
                    Thang = dto.Thang,
                    Nam = dto.Nam,
                    ChiSoDienCu = dto.ChiSoDienCu,
                    ChiSoDienMoi = dto.ChiSoDienMoi,
                    ChiSoNuocCu = dto.ChiSoNuocCu,
                    ChiSoNuocMoi = dto.ChiSoNuocMoi,
                    DaLapHoaDon = false,
                    NgayCapNhat = DateTime.Now,
                };
                _context.ChiSoDienNuocs.Add(newReading);
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Lưu chỉ số thành công." });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi lưu chỉ số.", error = ex.Message });
        }
    }

    /// <summary>
    /// Lưu chỉ số điện nước cho nhiều phòng cùng lúc (batch save).
    /// </summary>
    [HttpPost("batch")]
    public async Task<IActionResult> SaveBatchReadings([FromBody] List<SaveReadingDto> dtos)
    {
        if (dtos == null || dtos.Count == 0)
            return BadRequest(new { message = "Không có dữ liệu." });

        try
        {
            foreach (var dto in dtos)
            {
                var existing = await _context.ChiSoDienNuocs
                    .FirstOrDefaultAsync(c => c.MaPhong == dto.MaPhong && c.Thang == dto.Thang && c.Nam == dto.Nam);

                if (existing != null)
                {
                    existing.ChiSoDienCu = dto.ChiSoDienCu;
                    existing.ChiSoDienMoi = dto.ChiSoDienMoi;
                    existing.ChiSoNuocCu = dto.ChiSoNuocCu;
                    existing.ChiSoNuocMoi = dto.ChiSoNuocMoi;
                    existing.NgayCapNhat = DateTime.Now;
                }
                else
                {
                    var newReading = new ChiSoDienNuoc
                    {
                        MaPhong = dto.MaPhong,
                        Thang = dto.Thang,
                        Nam = dto.Nam,
                        ChiSoDienCu = dto.ChiSoDienCu,
                        ChiSoDienMoi = dto.ChiSoDienMoi,
                        ChiSoNuocCu = dto.ChiSoNuocCu,
                        ChiSoNuocMoi = dto.ChiSoNuocMoi,
                        DaLapHoaDon = false,
                        NgayCapNhat = DateTime.Now,
                    };
                    _context.ChiSoDienNuocs.Add(newReading);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = $"Đã lưu chỉ số cho {dtos.Count} phòng." });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi khi lưu chỉ số.", error = ex.Message });
        }
    }
}

public class SaveReadingDto
{
    public int MaPhong { get; set; }
    public int Thang { get; set; }
    public int Nam { get; set; }
    public int ChiSoDienCu { get; set; }
    public int? ChiSoDienMoi { get; set; }
    public int ChiSoNuocCu { get; set; }
    public int? ChiSoNuocMoi { get; set; }
}
