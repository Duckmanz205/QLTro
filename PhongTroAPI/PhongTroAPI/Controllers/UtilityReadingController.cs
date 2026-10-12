using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UtilityReadingController : ControllerBase
    {
        private readonly ChiSoRepository _chiSoRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly HopDongRepository _hopDongRepo;
        private readonly KhachThueRepository _khachRepo;
        private readonly HoaDonRepository _hoaDonRepo;
        private readonly CounterRepository _counterRepo;

        public UtilityReadingController(
            ChiSoRepository chiSoRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            HopDongRepository hopDongRepo,
            KhachThueRepository khachRepo,
            HoaDonRepository hoaDonRepo,
            CounterRepository counterRepo)
        {
            _chiSoRepo = chiSoRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _hopDongRepo = hopDongRepo;
            _khachRepo = khachRepo;
            _hoaDonRepo = hoaDonRepo;
            _counterRepo = counterRepo;
        }

        [HttpGet]
        public async Task<IActionResult> GetUtilityReadings([FromQuery] int month, [FromQuery] int year)
        {
            if (month < 1 || month > 12 || year < 2000)
                return BadRequest(new { message = "Tháng/năm không hợp lệ." });

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Ok(new List<object>());
            }

            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            var coSos = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLy).ToList();
            var coSoIds = coSos.Select(cs => cs.MaCoSo).ToHashSet();

            var tatCaPhong = await _phongRepo.GetAllAsync();
            var phongs = tatCaPhong.Where(p => coSoIds.Contains(p.MaCoSo))
                .OrderBy(p => p.MaCoSo)
                .ThenBy(p => p.SoPhong)
                .ToList();

            var tatCaHopDong = await _hopDongRepo.GetAllAsync();
            var activeContracts = tatCaHopDong.Where(hd => hd.TrangThai == "Đang hiệu lực").ToList();
            var activeContractMap = activeContracts
                .GroupBy(hd => hd.MaPhong)
                .ToDictionary(g => g.Key, g => g.OrderByDescending(hd => hd.NgayBatDau).First());

            var tatCaKhach = await _khachRepo.GetAllAsync();

            var tatCaChiSo = await _chiSoRepo.GetAllAsync();
            var readings = tatCaChiSo.Where(c => c.Thang == month && c.Nam == year).ToList();
            var readingMap = readings.ToDictionary(r => r.MaPhong);

            int prevMonth = month == 1 ? 12 : month - 1;
            int prevYear = month == 1 ? year - 1 : year;
            var prevReadings = tatCaChiSo.Where(c => c.Thang == prevMonth && c.Nam == prevYear).ToList();
            var prevReadingMap = prevReadings.ToDictionary(r => r.MaPhong);

            var latestInvoices = await _hoaDonRepo.GetAllAsync();
            var latestInvoiceMap = latestInvoices
                .GroupBy(h => h.MaPhong)
                .ToDictionary(
                    g => g.Key,
                    g => g.OrderByDescending(h => h.Nam).ThenByDescending(h => h.Thang).First()
                );

            var result = phongs.Select(r =>
            {
                var coSo = coSos.FirstOrDefault(cs => cs.MaCoSo == r.MaCoSo);
                
                string tenKhachThue = "";
                if (activeContractMap.TryGetValue(r.MaPhong, out var activeContract))
                {
                    var khach = tatCaKhach.FirstOrDefault(k => k.MaKhach == activeContract.MaKhach);
                    if (khach != null) tenKhachThue = khach.HoTen;
                }

                var hasReading = readingMap.TryGetValue(r.MaPhong, out var reading);
                var hasPrev = prevReadingMap.TryGetValue(r.MaPhong, out var prevReading);
                var hasLatestInvoice = latestInvoiceMap.TryGetValue(r.MaPhong, out var latestInvoice);

                int defaultDienCu = hasLatestInvoice 
                    ? Convert.ToInt32(latestInvoice.ChiSoDienMoi) 
                    : (hasPrev && prevReading!.ChiSoDienMoi.HasValue 
                        ? prevReading.ChiSoDienMoi.Value 
                        : (activeContract != null && activeContract.ChiSoDienCu.HasValue ? activeContract.ChiSoDienCu.Value : 0));

                int defaultNuocCu = hasLatestInvoice 
                    ? Convert.ToInt32(latestInvoice.ChiSoNuocMoi) 
                    : (hasPrev && prevReading!.ChiSoNuocMoi.HasValue 
                        ? prevReading.ChiSoNuocMoi.Value 
                        : (activeContract != null && activeContract.ChiSoNuocCu.HasValue ? activeContract.ChiSoNuocCu.Value : 0));

                return new
                {
                    r.MaPhong,
                    r.SoPhong,
                    r.Tang,
                    r.TrangThai,
                    TenCoSo = coSo?.TenCoSo ?? "",
                    r.MaCoSo,
                    DonGiaDien = coSo?.DonGiaDien ?? 3500,
                    DonGiaNuoc = coSo?.DonGiaNuoc ?? 20000,
                    TenKhachThue = tenKhachThue,
                    MaChiSo = hasReading ? reading!.MaChiSo : (int?)null,
                    ChiSoDienCu = hasReading ? reading!.ChiSoDienCu : defaultDienCu,
                    ChiSoDienMoi = hasReading ? reading!.ChiSoDienMoi : (int?)null,
                    ChiSoNuocCu = hasReading ? reading!.ChiSoNuocCu : defaultNuocCu,
                    ChiSoNuocMoi = hasReading ? reading!.ChiSoNuocMoi : (int?)null,
                    DaLapHoaDon = hasReading && reading!.DaLapHoaDon,
                };
            }).ToList();

            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> SaveReading([FromBody] SaveReadingDto dto)
        {
            if (dto.Thang < 1 || dto.Thang > 12 || dto.Nam < 2000)
                return BadRequest(new { message = "Tháng/năm không hợp lệ." });

            try
            {
                var tatCaChiSo = await _chiSoRepo.GetAllAsync();
                var existing = tatCaChiSo.FirstOrDefault(c => c.MaPhong == dto.MaPhong && c.Thang == dto.Thang && c.Nam == dto.Nam);

                if (existing != null)
                {
                    existing.ChiSoDienCu = dto.ChiSoDienCu;
                    existing.ChiSoDienMoi = dto.ChiSoDienMoi;
                    existing.ChiSoNuocCu = dto.ChiSoNuocCu;
                    existing.ChiSoNuocMoi = dto.ChiSoNuocMoi;
                    existing.NgayCapNhat = DateTime.Now;
                    await _chiSoRepo.UpdateAsync(existing.MaChiSo, existing);
                }
                else
                {
                    var newReading = new ChiSoDienNuoc
                    {
                        MaChiSo = await _counterRepo.GetNextSequenceValueAsync("chiso_id"),
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
                    await _chiSoRepo.CreateAsync(newReading);
                }

                return Ok(new { message = "Lưu chỉ số thành công." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lưu chỉ số.", error = ex.Message });
            }
        }

        [HttpPost("batch")]
        public async Task<IActionResult> SaveBatchReadings([FromBody] List<SaveReadingDto> dtos)
        {
            if (dtos == null || dtos.Count == 0)
                return BadRequest(new { message = "Không có dữ liệu." });

            try
            {
                var tatCaChiSo = await _chiSoRepo.GetAllAsync();

                foreach (var dto in dtos)
                {
                    var existing = tatCaChiSo.FirstOrDefault(c => c.MaPhong == dto.MaPhong && c.Thang == dto.Thang && c.Nam == dto.Nam);

                    if (existing != null)
                    {
                        existing.ChiSoDienCu = dto.ChiSoDienCu;
                        existing.ChiSoDienMoi = dto.ChiSoDienMoi;
                        existing.ChiSoNuocCu = dto.ChiSoNuocCu;
                        existing.ChiSoNuocMoi = dto.ChiSoNuocMoi;
                        existing.NgayCapNhat = DateTime.Now;
                        await _chiSoRepo.UpdateAsync(existing.MaChiSo, existing);
                    }
                    else
                    {
                        var newReading = new ChiSoDienNuoc
                        {
                            MaChiSo = await _counterRepo.GetNextSequenceValueAsync("chiso_id"),
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
                        await _chiSoRepo.CreateAsync(newReading);
                    }
                }

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
}
