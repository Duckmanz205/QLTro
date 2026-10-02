using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ThongKeController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public ThongKeController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // -------------------------------------------------------------
        // GET /api/thongke/admin
        // Thống kê doanh thu & vận hành của Chủ trọ
        // -------------------------------------------------------------
        [HttpGet("admin")]
        [Authorize(Roles = "NguoiQuanLy,Admin")]
        public async Task<IActionResult> GetAdminStats([FromQuery] int year)
        {
            if (year <= 0) year = DateTime.Now.Year;

            // Lấy MaQuanLy an toàn từ Token JWT
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            // 1. Lấy danh sách Cơ sở & Phòng của chủ trọ này
            var coSos = await _context.CoSos
                .Where(cs => cs.MaQuanLy == maQuanLy)
                .Select(cs => cs.MaCoSo)
                .ToListAsync();

            var phongs = await _context.Phongs
                .Where(p => coSos.Contains(p.MaCoSo))
                .Select(p => new { p.MaPhong, p.TrangThai })
                .ToListAsync();

            int tongSoPhong = phongs.Count;
            int phongDangThue = phongs.Count(p => p.TrangThai == "Đang thuê");
            int phongTrong = phongs.Count(p => p.TrangThai == "Trống");
            int phongBaoTri = phongs.Count(p => p.TrangThai == "Bảo trì");
            double tiLeLapDay = tongSoPhong > 0 ? Math.Round((double)phongDangThue / tongSoPhong * 100, 1) : 0;

            var phongIds = phongs.Select(p => p.MaPhong).ToList();

            // 2. Lấy dữ liệu Hóa đơn
            var hoaDons = await _context.HoaDons
                .Where(h => phongIds.Contains(h.MaPhong) && h.Nam == year)
                .Select(h => new { h.TongTien, h.TrangThai, h.Thang })
                .ToListAsync();

            decimal tongDoanhThuDaThu = hoaDons.Where(h => h.TrangThai == "Đã thanh toán").Sum(h => h.TongTien);
            decimal tongDoanhThuChuaThu = hoaDons.Where(h => h.TrangThai == "Chưa thanh toán" || h.TrangThai == "Chờ duyệt").Sum(h => h.TongTien);

            // Doanh thu chi tiết 12 tháng
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

            // 3. Sự cố
            var suCos = await _context.SuCos
                .Where(s => phongIds.Contains(s.MaPhong))
                .Select(s => s.TrangThai)
                .ToListAsync();

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

        // -------------------------------------------------------------
        // GET /api/thongke/user
        // Thống kê chi tiêu & điện nước tiêu thụ của Khách thuê
        // -------------------------------------------------------------
        [HttpGet("user")]
        [Authorize(Roles = "KhachThue")]
        public async Task<IActionResult> GetUserStats()
        {
            // Lấy MaKhach an toàn từ Token JWT
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (string.IsNullOrEmpty(maKhachClaim) || !int.TryParse(maKhachClaim, out int maKhach))
            {
                return Unauthorized("Không tìm thấy mã khách thuê hợp lệ trong token.");
            }

            // 1. Lấy thông tin phòng hiện tại & Tiền cọc từ Hợp đồng đang hoạt động
            var hopDong = await _context.HopDongThues
                .Include(h => h.MaPhongNavigation)
                .ThenInclude(p => p.MaCoSoNavigation)
                .FirstOrDefaultAsync(h => h.MaKhach == maKhach && h.TrangThai == "Còn hạn");

            decimal tienCoc = hopDong?.TienCoc ?? 0;
            string? tenPhong = hopDong?.MaPhongNavigation?.SoPhong;
            string? tenCoSo = hopDong?.MaPhongNavigation?.MaCoSoNavigation?.TenCoSo;

            // 2. Lấy danh sách hóa đơn lịch sử (Sắp xếp theo năm, tháng mới nhất)
            var hoaDons = await _context.HoaDons
                .Where(h => h.MaKhach == maKhach)
                .OrderByDescending(h => h.Nam)
                .ThenByDescending(h => h.Thang)
                .Take(6) // Lấy 6 tháng gần nhất
                .ToListAsync();

            decimal tongDaThanhToan = await _context.HoaDons
                .Where(h => h.MaKhach == maKhach && h.TrangThai == "Đã thanh toán")
                .SumAsync(h => h.TongTien);

            decimal tongChuaThanhToan = await _context.HoaDons
                .Where(h => h.MaKhach == maKhach && h.TrangThai != "Đã thanh toán")
                .SumAsync(h => h.TongTien);

            // Xử lý list ngược lại để vẽ biểu đồ từ cũ tới mới (Trái sang Phải)
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
