using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json; 
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PdfSharpCore.Drawing;
using PdfSharpCore.Pdf;
using System.IO;
using System.Net.Http;

namespace PhongTroAPI.Services
{
    public class HopDongService
    {
        private readonly QuanLyPhongTroContext _context;

        public HopDongService(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // 1. LẤY TOÀN BỘ DANH SÁCH HỢP ĐỒNG
        public List<HopDongRenderDto> GetAllHopDong(int? maQuanLy = null)
        {
            var query = _context.HopDongThues
                .Include(hd => hd.MaKhachNavigation)
                .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                        .ThenInclude(cs => cs.MaQuanLyNavigation)
                .AsQueryable();

            if (maQuanLy.HasValue)
            {
                query = query.Where(hd => hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy.Value);
            }

            return query
                .OrderByDescending(hd => hd.MaHopDong)
                .Select(hd => new HopDongRenderDto
                {
                    MaHopDong = hd.MaHopDong,
                    MaKhach = hd.MaKhach,
                    MaPhong = hd.MaPhong,
                    TenKhach = hd.MaKhachNavigation.HoTen ?? "N/A",
                    CCCD = hd.MaKhachNavigation.Cccd ?? "N/A",
                    SDT = hd.MaKhachNavigation.Sdt ?? "N/A",
                    SoPhong = hd.MaPhongNavigation.SoPhong,
                    TenCoSo = hd.MaPhongNavigation.MaCoSoNavigation.TenCoSo,
                    GiaThue = hd.MaPhongNavigation.GiaThue,
                    TienCoc = hd.TienCoc ?? 0m,
                    NgayBatDau = hd.NgayBatDau,
                    NgayKetThuc = hd.NgayKetThuc ?? DateOnly.MinValue,
                    TrangThai = hd.TrangThai,
                    UrlChuKySupabase = hd.ChuKy,
                    TenQuanLy = hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null ? hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.HoTen : "N/A",
                    SdtQuanLy = hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null ? hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.Sdt : "N/A",
                    EmailQuanLy = hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null ? hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.Email : "N/A",
                    LyDoKetThucSom = hd.LyDoKetThucSom,
                    NgayMuonKetThuc = hd.NgayMuonKetThuc
                })
                .ToList() 
                .Select(dto => {
                    dto.UrlChuKySupabase = ExtractSupabaseUrl(dto.UrlChuKySupabase);
                    return dto;
                })
                .ToList();
        }

        // 2. TẠO HỢP ĐỒNG NHÁP
        public bool CreateHopDong(CreateHopDongDto dto, int? maQuanLy = null)
        {
            var phong = _context.Phongs.Include(p => p.MaCoSoNavigation).FirstOrDefault(p => p.MaPhong == dto.MaPhong);
            if (phong == null) return false;
            if (maQuanLy.HasValue && phong.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            var hopDong = new HopDongThue
            {
                MaPhong = dto.MaPhong,
                MaKhach = dto.MaKhach,
                NgayBatDau = dto.NgayBatDau,
                NgayKetThuc = dto.NgayKetThuc,
                TienCoc = dto.TienCoc,
                ChiSoDienCu = dto.ChiSoDienCu,
                ChiSoNuocCu = dto.ChiSoNuocCu,
                TrangThai = "Chờ khách ký", 
                NgayTao = DateTime.Now
            };

            _context.HopDongThues.Add(hopDong);
            return _context.SaveChanges() > 0;
        }

        // 3. CẬP NHẬT ĐIỀU KHOẢN HỢP ĐỒNG NHÁP
        public bool UpdateHopDong(int maHopDong, CreateHopDongDto dto, int? maQuanLy = null)
        {
            var hopDong = _context.HopDongThues.Include(hd => hd.MaPhongNavigation).ThenInclude(p => p.MaCoSoNavigation).FirstOrDefault(hd => hd.MaHopDong == maHopDong);
            if (hopDong == null) return false;

            if (maQuanLy.HasValue && hopDong.MaPhongNavigation.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            if (hopDong.TrangThai == "Đang hiệu lực" || hopDong.TrangThai == "Đã ký")
            {
                throw new InvalidOperationException("Hợp đồng này đã được ký kết và đang có hiệu lực. Không thể chỉnh sửa điều khoản!");
            }

            hopDong.NgayBatDau = dto.NgayBatDau;
            hopDong.NgayKetThuc = dto.NgayKetThuc;
            hopDong.TienCoc = dto.TienCoc;

            return _context.SaveChanges() > 0;
        }

        // 4. KÝ SỐ NÂNG CAO (SHA-256 & BỌC JSON VÀO CỘT CHỮ KÝ)
        public bool KyHopDongNangCao(KyHopDongNangCaoDto dto)
        {
            var hopDong = _context.HopDongThues.Find(dto.MaHopDong);
            if (hopDong == null) return false;
            if (hopDong.TrangThai == "Đang hiệu lực") return false;

            try
            {
                string stringToHash = $"{hopDong.MaHopDong}-{hopDong.MaPhong}-{hopDong.MaKhach}-{hopDong.NgayBatDau:yyyyMMdd}-{hopDong.TienCoc}";
                string contractHash = "";

                using (SHA256 sha256 = SHA256.Create())
                {
                    byte[] inputBytes = Encoding.UTF8.GetBytes(stringToHash);
                    byte[] hashBytes = sha256.ComputeHash(inputBytes);
                    contractHash = Convert.ToBase64String(hashBytes);
                }

                var signaturePayload = new
                {
                    ContractHash = contractHash,
                    UrlChuKyKhach = dto.UrlChuKySupabase,
                    PublicKeyKhach = dto.DevicePublicKey,
                    NgayKy = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                };

                hopDong.ChuKy = JsonSerializer.Serialize(signaturePayload); 
                hopDong.TrangThai = "Đang hiệu lực";

                var phong = _context.Phongs.Find(hopDong.MaPhong);
                if (phong != null)
                {
                    phong.TrangThai = "Đang thuê"; 
                }

                // Cập nhật chỉ số điện nước cũ từ hợp đồng vào bảng ChiSoDienNuoc
                var startMonth = hopDong.NgayBatDau.Month;
                var startYear = hopDong.NgayBatDau.Year;
                var existingReading = _context.ChiSoDienNuocs
                    .FirstOrDefault(c => c.MaPhong == hopDong.MaPhong && c.Thang == startMonth && c.Nam == startYear);

                if (existingReading != null)
                {
                    existingReading.ChiSoDienCu = hopDong.ChiSoDienCu ?? 0;
                    existingReading.ChiSoNuocCu = hopDong.ChiSoNuocCu ?? 0;
                    existingReading.NgayCapNhat = DateTime.Now;
                }
                else
                {
                    var newReading = new ChiSoDienNuoc
                    {
                        MaPhong = hopDong.MaPhong,
                        Thang = startMonth,
                        Nam = startYear,
                        ChiSoDienCu = hopDong.ChiSoDienCu ?? 0,
                        ChiSoDienMoi = null,
                        ChiSoNuocCu = hopDong.ChiSoNuocCu ?? 0,
                        ChiSoNuocMoi = null,
                        DaLapHoaDon = false,
                        NgayCapNhat = DateTime.Now
                    };
                    _context.ChiSoDienNuocs.Add(newReading);
                }

                return _context.SaveChanges() > 0;
            }
            catch (Exception)
            {
                return false;
            }
        }

        // 5. XEM CHI TIẾT HỢP ĐỒNG
        public HopDongRenderDto? GetChiTietHopDong(int maHopDong)
        {
            var hd = _context.HopDongThues
                .Include(hd => hd.MaKhachNavigation)
                .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                        .ThenInclude(cs => cs.MaQuanLyNavigation)
                .FirstOrDefault(hd => hd.MaHopDong == maHopDong);

            if (hd == null) return null;

            return new HopDongRenderDto
            {
                MaHopDong = hd.MaHopDong,
                MaKhach = hd.MaKhach,
                MaPhong = hd.MaPhong,
                TenKhach = hd.MaKhachNavigation.HoTen ?? "N/A",
                CCCD = hd.MaKhachNavigation.Cccd ?? "N/A",
                SDT = hd.MaKhachNavigation.Sdt ?? "N/A",
                SoPhong = hd.MaPhongNavigation.SoPhong,
                TenCoSo = hd.MaPhongNavigation.MaCoSoNavigation.TenCoSo,
                GiaThue = hd.MaPhongNavigation.GiaThue,
                TienCoc = hd.TienCoc ?? 0m,
                NgayBatDau = hd.NgayBatDau,
                NgayKetThuc = hd.NgayKetThuc ?? DateOnly.MinValue,
                TrangThai = hd.TrangThai,
                UrlChuKySupabase = ExtractSupabaseUrl(hd.ChuKy),
                TenQuanLy = hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null ? hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.HoTen : "N/A",
                SdtQuanLy = hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null ? hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.Sdt : "N/A",
                EmailQuanLy = hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation != null ? hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLyNavigation.Email : "N/A",
                LyDoKetThucSom = hd.LyDoKetThucSom,
                NgayMuonKetThuc = hd.NgayMuonKetThuc
            };
        }

        // 6. GIA HẠN HỢP ĐỒNG (LƯU VẾT LỊCH SỬ)
        public bool GiaHanHopDong(int maHopDong, GiaHanHopDongDto dto, int? maQuanLy = null)
        {
            var hopDong = _context.HopDongThues.Include(hd => hd.MaPhongNavigation).ThenInclude(p => p.MaCoSoNavigation).FirstOrDefault(hd => hd.MaHopDong == maHopDong);
            if (hopDong == null) return false;

            if (maQuanLy.HasValue && hopDong.MaPhongNavigation.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            var lichSu = new LichSuGiaHan
            {
                MaHopDong = maHopDong,
                NgayBatDauMoi = dto.NgayBatDauMoi,
                NgayKetThucMoi = dto.NgayKetThucMoi,
                GiaThueMoi = dto.GiaThueMoi,
                NgayThucHien = DateTime.Now,
                GhiChu = dto.GhiChu
            };
            _context.LichSuGiaHans.Add(lichSu);

            hopDong.NgayKetThuc = dto.NgayKetThucMoi;
            hopDong.TrangThai = "Đang hiệu lực"; // Chuyển về đang hiệu lực sau khi gia hạn
            
            // Cập nhật lại giá thuê phòng
            var phong = _context.Phongs.Find(hopDong.MaPhong);
            if (phong != null)
            {
                phong.GiaThue = dto.GiaThueMoi;
            }

            return _context.SaveChanges() > 0;
        }

        // 6.1 YÊU CẦU GIA HẠN HỢP ĐỒNG (KHÁCH THUÊ GỬI YÊU CẦU)
        public bool YeuCauGiaHan(int maHopDong, int? maKhach = null)
        {
            var hopDong = _context.HopDongThues.Find(maHopDong);
            if (hopDong == null) return false;

            if (maKhach.HasValue && hopDong.MaKhach != maKhach.Value) return false;

            hopDong.TrangThai = "Chờ gia hạn";
            return _context.SaveChanges() > 0;
        }

        // 6.2 TỪ CHỐI GIA HẠN HỢP ĐỒNG (QUẢN TRỊ VIÊN TỪ CHỐI)
        public bool TuChoiGiaHan(int maHopDong, int? maQuanLy = null)
        {
            var hopDong = _context.HopDongThues.Include(hd => hd.MaPhongNavigation).ThenInclude(p => p.MaCoSoNavigation).FirstOrDefault(hd => hd.MaHopDong == maHopDong);
            if (hopDong == null) return false;

            if (maQuanLy.HasValue && hopDong.MaPhongNavigation.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            hopDong.TrangThai = "Quá hạn";
            return _context.SaveChanges() > 0;
        }

        // 7.0 YÊU CẦU KẾT THÚC HỢP ĐỒNG SỚM (KHÁCH THUÊ GỬI YÊU CẦU)
        public bool YeuCauKetThucSom(int maHopDong, YeuCauKetThucSomDto dto, int? maKhach = null)
        {
            var hopDong = _context.HopDongThues.Find(maHopDong);
            if (hopDong == null) return false;

            if (maKhach.HasValue && hopDong.MaKhach != maKhach.Value) return false;

            // Chỉ cho phép kết thúc sớm khi hợp đồng đang hiệu lực
            if (hopDong.TrangThai != "Đang hiệu lực") return false;

            hopDong.TrangThai = "Chờ kết thúc sớm";
            hopDong.LyDoKetThucSom = dto.LyDo;
            hopDong.NgayMuonKetThuc = dto.NgayMuonKetThuc;
            return _context.SaveChanges() > 0;
        }

        // 7.1 ADMIN DUYỆT KẾT THÚC HỢP ĐỒNG SỚM
        public bool DuyetKetThucSom(int maHopDong, DuyetKetThucSomDto dto, int? maQuanLy = null)
        {
            var hopDong = _context.HopDongThues
                .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                .FirstOrDefault(hd => hd.MaHopDong == maHopDong);
            if (hopDong == null) return false;

            if (maQuanLy.HasValue && hopDong.MaPhongNavigation.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            if (hopDong.TrangThai != "Chờ kết thúc sớm") return false;

            hopDong.TrangThai = "Đã kết thúc sớm";
            hopDong.NgayKetThuc = dto.NgayKetThucThucTe;

            // Trả phòng về trạng thái trống
            var phong = _context.Phongs.Find(hopDong.MaPhong);
            if (phong != null) phong.TrangThai = "Trống";

            return _context.SaveChanges() > 0;
        }

        // 7.2 ADMIN TỪ CHỐI KẾT THÚC HỢP ĐỒNG SỚM
        public bool TuChoiKetThucSom(int maHopDong, int? maQuanLy = null)
        {
            var hopDong = _context.HopDongThues
                .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                .FirstOrDefault(hd => hd.MaHopDong == maHopDong);
            if (hopDong == null) return false;

            if (maQuanLy.HasValue && hopDong.MaPhongNavigation.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            if (hopDong.TrangThai != "Chờ kết thúc sớm") return false;

            // Trả lại trạng thái đang hiệu lực, xóa thông tin yêu cầu
            hopDong.TrangThai = "Đang hiệu lực";
            hopDong.LyDoKetThucSom = null;
            hopDong.NgayMuonKetThuc = null;
            return _context.SaveChanges() > 0;
        }

        //  7. XÓA HỢP ĐỒNG (DỌN RÁC KHÓA NGOẠI TRƯỚC KHI XÓA)
        public bool DeleteHopDong(int maHopDong, int? maQuanLy = null)
        {
            var hopDong = _context.HopDongThues.Include(hd => hd.MaPhongNavigation).ThenInclude(p => p.MaCoSoNavigation).FirstOrDefault(hd => hd.MaHopDong == maHopDong);
            if (hopDong == null) return false;

            if (maQuanLy.HasValue && hopDong.MaPhongNavigation.MaCoSoNavigation.MaQuanLy != maQuanLy.Value) return false;

            if (hopDong.TrangThai == "Đang hiệu lực" || hopDong.TrangThai == "Đã ký")
            {
                throw new InvalidOperationException("Hợp đồng đang có hiệu lực pháp lý, tuyệt đối không được xóa.");
            }

            try
            {
                // Gỡ trạng thái phòng về "Trống"
                var phong = _context.Phongs.Find(hopDong.MaPhong);
                if (phong != null) phong.TrangThai = "Trống";

                // Xóa lịch sử gia hạn dính tới hợp đồng này
                var lichSu = _context.LichSuGiaHans.Where(x => x.MaHopDong == maHopDong).ToList();
                if (lichSu.Any()) _context.LichSuGiaHans.RemoveRange(lichSu);

                // Lưu ý: Mở comment dòng dưới nếu có bảng Hóa Đơn dính khóa ngoại tới Hợp đồng
                // var hoaDons = _context.HoaDons.Where(x => x.MaHopDong == maHopDong).ToList();
                // if (hoaDons.Any()) _context.HoaDons.RemoveRange(hoaDons);

                _context.HopDongThues.Remove(hopDong);
                return _context.SaveChanges() > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi xóa DB: " + ex.InnerException?.Message);
                return false;
            }
        }

        public bool VerifyOwnership(int maHopDong, int maQuanLy)
        {
            return _context.HopDongThues.Any(hd => hd.MaHopDong == maHopDong && hd.MaPhongNavigation.MaCoSoNavigation.MaQuanLy == maQuanLy);
        }

        public bool VerifyCustomerOwnership(int maHopDong, int maKhach)
        {
            return _context.HopDongThues.Any(hd => hd.MaHopDong == maHopDong && hd.MaKhach == maKhach);
        }

        // 🛠️ HÀM PHỤ TRỢ: BÓC TÁCH JSON
        // 🛠️ HÀM PHỤ TRỢ: BÓC TÁCH JSON
        private static string? ExtractSupabaseUrl(string? rawDbValue)
        {
            if (string.IsNullOrEmpty(rawDbValue)) return null;
            if (!rawDbValue.Trim().StartsWith("{")) return rawDbValue; 

            try
            {
                using (JsonDocument doc = JsonDocument.Parse(rawDbValue))
                {
                    if (doc.RootElement.TryGetProperty("UrlChuKyKhach", out JsonElement urlElement))
                    {
                        return urlElement.GetString();
                    }
                }
            }
            catch { }
            return rawDbValue;
        }

        // 8. LẤY HỢP ĐỒNG BẰNG ID (DÀNH CHO XUẤT PDF)
        public HopDongThue? GetById(int id)
        {
            return _context.HopDongThues
                .Include(hd => hd.MaKhachNavigation)
                .Include(hd => hd.MaPhongNavigation)
                    .ThenInclude(p => p.MaCoSoNavigation)
                        .ThenInclude(cs => cs.MaQuanLyNavigation)
                .FirstOrDefault(hd => hd.MaHopDong == id);
        }

        // 9. SINH PDF CHO HỢP ĐỒNG HỖ TRỢ TIẾNG VIỆT VÀ CHỮ KÝ
        public byte[] GeneratePdfBytes(HopDongThue contract)
        {
            var khachTen = contract.MaKhachNavigation?.HoTen ?? "N/A";
            var khachSdt = contract.MaKhachNavigation?.Sdt ?? "N/A";
            var khachCccd = contract.MaKhachNavigation?.Cccd ?? "N/A";

            var phongSo = contract.MaPhongNavigation?.SoPhong ?? "N/A";
            var coSoTen = contract.MaPhongNavigation?.MaCoSoNavigation?.TenCoSo ?? "N/A";
            var coSoDiaChi = contract.MaPhongNavigation?.MaCoSoNavigation?.DiaChi ?? "N/A";

            var quanLyTen = contract.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.HoTen ?? "N/A";
            var quanLySdt = contract.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.Sdt ?? "N/A";
            var quanLyEmail = contract.MaPhongNavigation?.MaCoSoNavigation?.MaQuanLyNavigation?.Email ?? "N/A";

            var streamsToDispose = new List<MemoryStream>();
            XImage? signatureImage = null;
            if (!string.IsNullOrEmpty(contract.ChuKy))
            {
                try
                {
                    string imageUrl = contract.ChuKy;
                    if (!imageUrl.StartsWith("http"))
                    {
                        imageUrl = $"https://yrytwpxxuzscqfpeofsh.supabase.co/storage/v1/object/public/contract-signatures/{contract.ChuKy}";
                    }

                    using (var client = new HttpClient { Timeout = TimeSpan.FromSeconds(5) })
                    {
                        byte[] imageBytes = client.GetByteArrayAsync(imageUrl).GetAwaiter().GetResult();
                        var ms = new MemoryStream(imageBytes);
                        streamsToDispose.Add(ms);
                        signatureImage = XImage.FromStream(() => ms);
                    }
                }
                catch (Exception)
                {
                    // Bỏ qua nếu lỗi tải chữ ký
                }
            }

            try
            {
                var document = new PdfDocument();
                var page = document.AddPage();
                var gfx = XGraphics.FromPdfPage(page);

                // Sử dụng font Arial hỗ trợ tiếng Việt trên Windows
                var fontTitleLarge = new XFont("Arial", 16, XFontStyle.Bold);
                var fontTitleMedium = new XFont("Arial", 12, XFontStyle.Bold);
                var fontTitleSmall = new XFont("Arial", 11, XFontStyle.Bold);
                var fontRegular = new XFont("Arial", 10.5, XFontStyle.Regular);
                var fontItalic = new XFont("Arial", 10.5, XFontStyle.Italic);
                var fontBold = new XFont("Arial", 10.5, XFontStyle.Bold);

                double y = 50;
                double marginLeft = 55;
                double marginRight = 55;
                double contentWidth = page.Width - marginLeft - marginRight;

                // 1. Quốc hiệu tiêu ngữ
                gfx.DrawString("CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM", fontTitleMedium, XBrushes.Black, new XRect(0, y, page.Width, 20), XStringFormats.TopCenter);
                y += 18;
                gfx.DrawString("Độc lập - Tự do - Hạnh phúc", fontTitleSmall, XBrushes.Black, new XRect(0, y, page.Width, 20), XStringFormats.TopCenter);
                y += 12;
                gfx.DrawLine(XPens.Black, 220, y, 375, y);
                y += 30;

                // 2. Tiêu đề hợp đồng
                gfx.DrawString("HỢP ĐỒNG THUÊ PHÒNG TRỌ", fontTitleLarge, XBrushes.Black, new XRect(0, y, page.Width, 25), XStringFormats.TopCenter);
                y += 24;
                gfx.DrawString($"Số: HD-2026-00{contract.MaHopDong}", fontItalic, XBrushes.Black, new XRect(0, y, page.Width, 20), XStringFormats.TopCenter);
                y += 35;

                // 3. Lời mở đầu
                string intro = $"- Căn cứ Bộ luật Dân sự nước Cộng hòa Xã hội Chủ nghĩa Việt Nam hiện hành;\n" +
                               $"- Căn cứ vào nhu cầu và thỏa thuận thực tế của các bên.\n" +
                               $"Hôm nay, ngày {DateTime.Now:dd} tháng {DateTime.Now:MM} năm {DateTime.Now:yyyy}, tại cơ sở {coSoTen}, chúng tôi gồm:";
                y = DrawParagraph(gfx, intro, fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 10;

                // 4. BÊN CHO THUÊ (BÊN A)
                gfx.DrawString("BÊN CHO THUÊ (BÊN A):", fontBold, XBrushes.Black, marginLeft, y);
                y += 18;
                y = DrawWrappedText(gfx, $" - Họ và tên: {quanLyTen}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Số điện thoại: {quanLySdt}      |      Email: {quanLyEmail}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Đại diện cơ sở: {coSoTen}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Địa chỉ cơ sở: {coSoDiaChi}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 10;

                // 5. BÊN THUÊ (BÊN B)
                gfx.DrawString("BÊN THUÊ (BÊN B):", fontBold, XBrushes.Black, marginLeft, y);
                y += 18;
                y = DrawWrappedText(gfx, $" - Họ và tên: {khachTen}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Số điện thoại: {khachSdt}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Số CMND/CCCD: {khachCccd}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 10;

                // 6. ĐIỀU KHOẢN
                gfx.DrawString("CÁC ĐIỀU KHOẢN THỎA THUẬN CHUNG:", fontBold, XBrushes.Black, marginLeft, y);
                y += 18;
                y = DrawWrappedText(gfx, $"Điều 1. Bên A đồng ý cho Bên B thuê phòng số {phongSo} thuộc cơ sở {coSoTen} tại địa chỉ {coSoDiaChi}.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 2. Thời hạn thuê phòng là từ ngày {contract.NgayBatDau:dd/MM/yyyy} đến ngày {contract.NgayKetThuc:dd/MM/yyyy}.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 3. Giá thuê phòng là: {FormatCurrency(contract.MaPhongNavigation?.GiaThue)} VNĐ/tháng (Chưa bao gồm chi phí dịch vụ khác).", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 4. Tiền đặt cọc thuê phòng là: {FormatCurrency(contract.TienCoc)} VNĐ. Khoản tiền cọc này dùng để bảo đảm Bên B thực hiện đầy đủ nghĩa vụ của hợp đồng.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 5. Chỉ số điện cũ khi bàn giao: {contract.ChiSoDienCu ?? 0} kWh. Chỉ số nước cũ khi bàn giao: {contract.ChiSoNuocCu ?? 0} m3.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 6. Hai bên cam kết thực hiện nghiêm túc các điều khoản thỏa thuận nêu trên và tuân thủ nội quy phòng trọ.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 25;

                // 7. Chữ ký
                gfx.DrawString("Đại diện hai bên ký và ghi rõ họ tên để xác nhận:", fontItalic, XBrushes.Black, marginLeft, y);
                y += 25;

                double colWidth = 220;
                double colLeftX = marginLeft;
                double colRightX = marginLeft + contentWidth - colWidth;

                // Bên A
                gfx.DrawString("ĐẠI DIỆN BÊN A (BÊN CHO THUÊ)", fontBold, XBrushes.Black, new XRect(colLeftX, y, colWidth, 20), XStringFormats.TopCenter);
                gfx.DrawString("(Ký, ghi rõ họ tên)", fontItalic, XBrushes.Black, new XRect(colLeftX, y + 16, colWidth, 20), XStringFormats.TopCenter);
                gfx.DrawString(quanLyTen, fontBold, XBrushes.Black, new XRect(colLeftX, y + 105, colWidth, 20), XStringFormats.TopCenter);

                // Bên B
                gfx.DrawString("ĐẠI DIỆN BÊN B (BÊN THUÊ)", fontBold, XBrushes.Black, new XRect(colRightX, y, colWidth, 20), XStringFormats.TopCenter);
                gfx.DrawString("(Ký, ghi rõ họ tên)", fontItalic, XBrushes.Black, new XRect(colRightX, y + 16, colWidth, 20), XStringFormats.TopCenter);

                if (signatureImage != null)
                {
                    double imgW = 100;
                    double imgH = 50;
                    double imgX = colRightX + (colWidth - imgW) / 2;
                    double imgY = y + 40;
                    gfx.DrawImage(signatureImage, imgX, imgY, imgW, imgH);
                }

                gfx.DrawString(khachTen, fontBold, XBrushes.Black, new XRect(colRightX, y + 105, colWidth, 20), XStringFormats.TopCenter);

                using (var outputStream = new MemoryStream())
                {
                    document.Save(outputStream);
                    return outputStream.ToArray();
                }
            }
            finally
            {
                foreach (var stream in streamsToDispose)
                {
                    try { stream.Dispose(); } catch { }
                }
            }
        }

        private double DrawWrappedText(XGraphics gfx, string text, XFont font, XBrush brush, double x, double y, double maxWidth, double lineSpacing = 16)
        {
            string[] words = text.Split(' ');
            string currentLine = "";
            double currentY = y;

            for (int i = 0; i < words.Length; i++)
            {
                string testLine = string.IsNullOrEmpty(currentLine) ? words[i] : currentLine + " " + words[i];
                XSize size = gfx.MeasureString(testLine, font);

                if (size.Width > maxWidth)
                {
                    gfx.DrawString(currentLine, font, brush, x, currentY);
                    currentY += lineSpacing;
                    currentLine = words[i];
                }
                else
                {
                    currentLine = testLine;
                }
            }

            if (!string.IsNullOrEmpty(currentLine))
            {
                gfx.DrawString(currentLine, font, brush, x, currentY);
                currentY += lineSpacing;
            }

            return currentY;
        }

        private double DrawParagraph(XGraphics gfx, string text, XFont font, XBrush brush, double x, double y, double maxWidth, double lineSpacing = 16)
        {
            string[] paragraphs = text.Split('\n');
            double currentY = y;
            foreach (var para in paragraphs)
            {
                currentY = DrawWrappedText(gfx, para, font, brush, x, currentY, maxWidth, lineSpacing);
            }
            return currentY;
        }

        private string FormatCurrency(decimal? value)
        {
            if (!value.HasValue) return "0";
            return value.Value.ToString("#,##0");
        }
    }
}