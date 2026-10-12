using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ThongKeController : ControllerBase
    {
        private readonly CoSoRepository _coSoRepo;
        private readonly PhongRepository _phongRepo;
        private readonly HoaDonRepository _hoaDonRepo;
        private readonly SuCoRepository _suCoRepo;
        private readonly HopDongRepository _hopDongRepo;

        public ThongKeController(
            CoSoRepository coSoRepo,
            PhongRepository phongRepo,
            HoaDonRepository hoaDonRepo,
            SuCoRepository suCoRepo,
            HopDongRepository hopDongRepo)
        {
            _coSoRepo = coSoRepo;
            _phongRepo = phongRepo;
            _hoaDonRepo = hoaDonRepo;
            _suCoRepo = suCoRepo;
            _hopDongRepo = hopDongRepo;
        }

        [HttpGet("admin")]
        [Authorize(Roles = "NguoiQuanLy,Admin")]
        public async Task<IActionResult> GetAdminStats([FromQuery] int year)
        {
            if (year <= 0) year = DateTime.Now.Year;

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            var coSos = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLy).ToList();
            var coSoIds = coSos.Select(cs => cs.MaCoSo).ToHashSet();

            var tatCaPhong = await _phongRepo.GetAllAsync();
            var phongs = tatCaPhong.Where(p => coSoIds.Contains(p.MaCoSo)).ToList();

            int tongSoPhong = phongs.Count;
            int phongDangThue = phongs.Count(p => p.TrangThai == "Đang thuê");
            int phongTrong = phongs.Count(p => p.TrangThai == "Trống");
            int phongBaoTri = phongs.Count(p => p.TrangThai == "Bảo trì");
            double tiLeLapDay = tongSoPhong > 0 ? Math.Round((double)phongDangThue / tongSoPhong * 100, 1) : 0;

            var phongIds = phongs.Select(p => p.MaPhong).ToHashSet();

            var tatCaHoaDon = await _hoaDonRepo.GetAllAsync();
            var hoaDons = tatCaHoaDon.Where(h => phongIds.Contains(h.MaPhong) && h.Nam == year).ToList();

            decimal tongDoanhThuDaThu = hoaDons.Where(h => h.TrangThai == "Đã thanh toán").Sum(h => h.TongTien);
            decimal tongDoanhThuChuaThu = hoaDons.Where(h => h.TrangThai == "Chưa thanh toán" || h.TrangThai == "Chờ duyệt").Sum(h => h.TongTien);

            var doanhThuThangList = new List<DoanhThuThangDto>();
            for (int m = 1; m <= 12; m++)
            {
                var hdsTrongThang = hoaDons.Where(h => h.Thang == m).ToList();
                doanhThuThangList.Add(new DoanhThuThangDto
                {
                    Thang = m,
                    DaThanhToan = hdsTrongThang.Where(h => h.TrangThai == "Đã thanh toán").Sum(h => h.TongTien),
                    ChuaThanhToan = hdsTrongThang.Where(h => h.TrangThai == "Chưa thanh toán" || h.TrangThai == "Chờ duyệt").Sum(h => h.TongTien)
                });
            }

            var tatCaSuCo = await _suCoRepo.GetAllAsync();
            var suCos = tatCaSuCo.Where(s => phongIds.Contains(s.MaPhong)).Select(s => s.TrangThai).ToList();

            var dto = new AdminThongKeDto
            {
                TongDoanhThuDaThu = tongDoanhThuDaThu,
                TongDoanhThuChuaThu = tongDoanhThuChuaThu,
                TongSoCoSo = coSos.Count,
                TongSoPhong = tongSoPhong,
                TiLeLapDay = tiLeLapDay,
                PhongDangThue = phongDangThue,
                PhongTrong = phongTrong,
                PhongBaoTri = phongBaoTri,
                DoanhThuTheoThang = doanhThuThangList,
                TongSuCo = suCos.Count,
                SuCoChuaXuLy = suCos.Count(s => s == "Chưa xử lý" || s == "Đang xử lý")
            };

            return Ok(dto);
        }

        [HttpGet("user")]
        [Authorize(Roles = "KhachThue")]
        public async Task<IActionResult> GetUserStats()
        {
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (string.IsNullOrEmpty(maKhachClaim) || !int.TryParse(maKhachClaim, out int maKhach))
            {
                return Unauthorized("Không tìm thấy mã khách thuê hợp lệ trong token.");
            }

            var tatCaHopDong = await _hopDongRepo.GetAllAsync();
            var hopDong = tatCaHopDong.FirstOrDefault(h => h.MaKhach == maKhach && (h.TrangThai == "Còn hạn" || h.TrangThai == "Đang hiệu lực"));

            decimal tienCoc = hopDong?.TienCoc ?? 0;
            string tenPhong = null;
            string tenCoSo = null;

            if (hopDong != null)
            {
                var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
                if (phong != null)
                {
                    tenPhong = phong.SoPhong;
                    var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
                    if (coSo != null)
                    {
                        tenCoSo = coSo.TenCoSo;
                    }
                }
            }

            var tatCaHoaDon = await _hoaDonRepo.GetAllAsync();
            var userHoaDons = tatCaHoaDon.Where(h => h.MaKhach == maKhach).ToList();

            var hoaDons = userHoaDons
                .OrderByDescending(h => h.Nam)
                .ThenByDescending(h => h.Thang)
                .Take(6)
                .ToList();

            decimal tongDaThanhToan = userHoaDons
                .Where(h => h.TrangThai == "Đã thanh toán")
                .Sum(h => h.TongTien);

            decimal tongChuaThanhToan = userHoaDons
                .Where(h => h.TrangThai != "Đã thanh toán")
                .Sum(h => h.TongTien);

            var hoaDonsXuHuong = hoaDons.AsEnumerable().Reverse().ToList();

            var lichSuChiTieu = hoaDonsXuHuong.Select(h => new ChiTieuThangDto
            {
                KyThanhToan = $"T{h.Thang:D2}/{h.Nam}",
                TongTien = h.TongTien
            }).ToList();

            var lichSuTieuThu = hoaDonsXuHuong.Select(h => new TieuThuDienNuocDto
            {
                KyThanhToan = $"T{h.Thang:D2}/{h.Nam}",
                SoDienTieuThu = h.ChiSoDienMoi - h.ChiSoDienCu,
                SoNuocTieuThu = h.ChiSoNuocMoi - h.ChiSoNuocCu
            }).ToList();

            var dto = new UserThongKeDto
            {
                TongTienDaThanhToan = tongDaThanhToan,
                TongTienChuaThanhToan = tongChuaThanhToan,
                TienCocHienTai = tienCoc,
                TenPhongHienTai = tenPhong,
                TenCoSoHienTai = tenCoSo,
                LichSuChiTieu = lichSuChiTieu,
                LichSuTieuThu = lichSuTieuThu
            };

            return Ok(dto);
        }
    }
}
