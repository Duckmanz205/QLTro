using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json; 
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Entities.Embedded;
using PdfSharpCore.Drawing;
using PdfSharpCore.Pdf;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using PhongTroAPI.Repositories.Mongo;

namespace PhongTroAPI.Services
{
    public class HopDongService
    {
        private readonly HopDongRepository _hopDongRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly ChiSoRepository _chiSoRepo;
        private readonly CounterRepository _counterRepo;

        public HopDongService(
            HopDongRepository hopDongRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            KhachThueRepository khachThueRepo,
            NguoiQuanLyRepository quanLyRepo,
            ChiSoRepository chiSoRepo,
            CounterRepository counterRepo)
        {
            _hopDongRepo = hopDongRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _khachThueRepo = khachThueRepo;
            _quanLyRepo = quanLyRepo;
            _chiSoRepo = chiSoRepo;
            _counterRepo = counterRepo;
        }

        public async Task<List<HopDongRenderDto>> GetAllHopDongAsync(int? maQuanLy = null)
        {
            var allHD = await _hopDongRepo.GetAllAsync();
            var result = new List<HopDongRenderDto>();

            foreach (var hd in allHD)
            {
                var phong = await _phongRepo.GetByIdAsync(hd.MaPhong);
                var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;
                
                if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value))
                    continue;

                var khach = await _khachThueRepo.GetByIdAsync(hd.MaKhach);
                var quanLy = coSo?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(coSo.MaQuanLy.Value) : null;

                var dto = new HopDongRenderDto
                {
                    MaHopDong = hd.MaHopDong,
                    MaKhach = hd.MaKhach,
                    MaPhong = hd.MaPhong,
                    TenKhach = khach?.HoTen ?? "N/A",
                    CCCD = khach?.Cccd ?? "N/A",
                    SDT = khach?.Sdt ?? "N/A",
                    SoPhong = phong?.SoPhong ?? "N/A",
                    TenCoSo = coSo?.TenCoSo ?? "N/A",
                    GiaThue = phong?.GiaThue ?? 0m,
                    TienCoc = hd.TienCoc ?? 0m,
                    NgayBatDau = hd.NgayBatDau,
                    NgayKetThuc = hd.NgayKetThuc ?? DateOnly.MinValue,
                    TrangThai = hd.TrangThai,
                    UrlChuKySupabase = ExtractSupabaseUrl(hd.ChuKy),
                    TenQuanLy = quanLy?.HoTen ?? "N/A",
                    SdtQuanLy = quanLy?.Sdt ?? "N/A",
                    EmailQuanLy = quanLy?.Email ?? "N/A",
                    LyDoKetThucSom = hd.LyDoKetThucSom,
                    NgayMuonKetThuc = hd.NgayMuonKetThuc
                };
                result.Add(dto);
            }

            return result.OrderByDescending(x => x.MaHopDong).ToList();
        }

        public async Task<bool> CreateHopDongAsync(CreateHopDongDto dto, int? maQuanLy = null)
        {
            var phong = await _phongRepo.GetByIdAsync(dto.MaPhong);
            if (phong == null) return false;

            var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;

            var maHD = await _counterRepo.GetNextSequenceValueAsync("hopdong_id");

            var hopDong = new HopDongThue
            {
                MaHopDong = maHD,
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

            await _hopDongRepo.CreateAsync(hopDong);
            return true;
        }

        public async Task<bool> UpdateHopDongAsync(int maHopDong, CreateHopDongDto dto, int? maQuanLy = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;

            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;

            if (hopDong.TrangThai == "Đang hiệu lực" || hopDong.TrangThai == "Đã ký")
            {
                throw new InvalidOperationException("Hợp đồng này đã được ký kết và đang có hiệu lực. Không thể chỉnh sửa điều khoản!");
            }

            hopDong.NgayBatDau = dto.NgayBatDau;
            hopDong.NgayKetThuc = dto.NgayKetThuc;
            hopDong.TienCoc = dto.TienCoc;

            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);
            return true;
        }

        public async Task<bool> KyHopDongNangCaoAsync(KyHopDongNangCaoDto dto)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(dto.MaHopDong);
            if (hopDong == null || hopDong.TrangThai == "Đang hiệu lực") return false;

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
                await _hopDongRepo.UpdateAsync(hopDong.MaHopDong, hopDong);

                var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
                if (phong != null)
                {
                    phong.TrangThai = "Đang thuê"; 
                    await _phongRepo.UpdateAsync(phong.MaPhong, phong);
                }

                var startMonth = hopDong.NgayBatDau.Month;
                var startYear = hopDong.NgayBatDau.Year;
                
                var allChiSo = await _chiSoRepo.GetAllAsync();
                var existingReading = allChiSo.FirstOrDefault(c => c.MaPhong == hopDong.MaPhong && c.Thang == startMonth && c.Nam == startYear);

                if (existingReading != null)
                {
                    existingReading.ChiSoDienCu = hopDong.ChiSoDienCu ?? 0;
                    existingReading.ChiSoNuocCu = hopDong.ChiSoNuocCu ?? 0;
                    existingReading.NgayCapNhat = DateTime.Now;
                    await _chiSoRepo.UpdateAsync(existingReading.MaChiSo, existingReading);
                }
                else
                {
                    var newReading = new ChiSoDienNuoc
                    {
                        MaChiSo = await _counterRepo.GetNextSequenceValueAsync("chisodiennuoc_id"),
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
                    await _chiSoRepo.CreateAsync(newReading);
                }

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<HopDongRenderDto?> GetChiTietHopDongAsync(int maHopDong)
        {
            var hd = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hd == null) return null;

            var phong = await _phongRepo.GetByIdAsync(hd.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;
            var khach = await _khachThueRepo.GetByIdAsync(hd.MaKhach);
            var quanLy = coSo?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(coSo.MaQuanLy.Value) : null;

            return new HopDongRenderDto
            {
                MaHopDong = hd.MaHopDong,
                MaKhach = hd.MaKhach,
                MaPhong = hd.MaPhong,
                TenKhach = khach?.HoTen ?? "N/A",
                CCCD = khach?.Cccd ?? "N/A",
                SDT = khach?.Sdt ?? "N/A",
                SoPhong = phong?.SoPhong ?? "N/A",
                TenCoSo = coSo?.TenCoSo ?? "N/A",
                GiaThue = phong?.GiaThue ?? 0m,
                TienCoc = hd.TienCoc ?? 0m,
                NgayBatDau = hd.NgayBatDau,
                NgayKetThuc = hd.NgayKetThuc ?? DateOnly.MinValue,
                TrangThai = hd.TrangThai,
                UrlChuKySupabase = ExtractSupabaseUrl(hd.ChuKy),
                TenQuanLy = quanLy?.HoTen ?? "N/A",
                SdtQuanLy = quanLy?.Sdt ?? "N/A",
                EmailQuanLy = quanLy?.Email ?? "N/A",
                LyDoKetThucSom = hd.LyDoKetThucSom,
                NgayMuonKetThuc = hd.NgayMuonKetThuc
            };
        }

        public async Task<bool> GiaHanHopDongAsync(int maHopDong, GiaHanHopDongDto dto, int? maQuanLy = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;

            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;

            var lichSu = new LichSuGiaHanItem
            {
                TuNgay = dto.NgayBatDauMoi.ToDateTime(TimeOnly.MinValue),
                DenNgay = dto.NgayKetThucMoi.ToDateTime(TimeOnly.MinValue),
                /* GiaThueMoi mapping not present */ // = dto./* GiaThueMoi mapping not present */ //,
                NgayGiaHan = DateTime.Now,
                GhiChu = dto.GhiChu
            };
            
            hopDong.LichSuGiaHans.Add(lichSu);
            hopDong.NgayKetThuc = dto.NgayKetThucMoi;
            hopDong.TrangThai = "Đang hiệu lực";
            
            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);
            
            if (phong != null)
            {
                // phong.GiaThue = dto.GiaThueMoi; // dto doesn't have GiaThueMoi
                await _phongRepo.UpdateAsync(phong.MaPhong, phong);
            }

            return true;
        }

        public async Task<bool> YeuCauGiaHanAsync(int maHopDong, int? maKhach = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            if (maKhach.HasValue && hopDong.MaKhach != maKhach.Value) return false;

            hopDong.TrangThai = "Chờ gia hạn";
            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);
            return true;
        }

        public async Task<bool> TuChoiGiaHanAsync(int maHopDong, int? maQuanLy = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;

            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;

            hopDong.TrangThai = "Quá hạn";
            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);
            return true;
        }

        public async Task<bool> YeuCauKetThucSomAsync(int maHopDong, YeuCauKetThucSomDto dto, int? maKhach = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            if (maKhach.HasValue && hopDong.MaKhach != maKhach.Value) return false;
            if (hopDong.TrangThai != "Đang hiệu lực") return false;

            hopDong.TrangThai = "Chờ kết thúc sớm";
            hopDong.LyDoKetThucSom = dto.LyDo;
            hopDong.NgayMuonKetThuc = dto.NgayMuonKetThuc;
            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);
            return true;
        }

        public async Task<bool> DuyetKetThucSomAsync(int maHopDong, DuyetKetThucSomDto dto, int? maQuanLy = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;

            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;
            if (hopDong.TrangThai != "Chờ kết thúc sớm") return false;

            hopDong.TrangThai = "Đã kết thúc sớm";
            hopDong.NgayKetThuc = dto.NgayKetThucThucTe;
            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);

            if (phong != null)
            {
                phong.TrangThai = "Trống";
                await _phongRepo.UpdateAsync(phong.MaPhong, phong);
            }

            return true;
        }

        public async Task<bool> TuChoiKetThucSomAsync(int maHopDong, int? maQuanLy = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;

            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;
            if (hopDong.TrangThai != "Chờ kết thúc sớm") return false;

            hopDong.TrangThai = "Đang hiệu lực";
            hopDong.LyDoKetThucSom = null;
            hopDong.NgayMuonKetThuc = null;
            await _hopDongRepo.UpdateAsync(maHopDong, hopDong);
            return true;
        }

        public async Task<bool> DeleteHopDongAsync(int maHopDong, int? maQuanLy = null)
        {
            var hopDong = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hopDong == null) return false;

            var phong = await _phongRepo.GetByIdAsync(hopDong.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;

            if (maQuanLy.HasValue && (coSo == null || coSo.MaQuanLy != maQuanLy.Value)) return false;

            if (hopDong.TrangThai == "Đang hiệu lực" || hopDong.TrangThai == "Đã ký")
            {
                throw new InvalidOperationException("Hợp đồng đang có hiệu lực pháp lý, tuyệt đối không được xóa.");
            }

            if (phong != null)
            {
                phong.TrangThai = "Trống";
                await _phongRepo.UpdateAsync(phong.MaPhong, phong);
            }

            await _hopDongRepo.DeleteAsync(maHopDong);
            return true;
        }

        public async Task<bool> VerifyOwnershipAsync(int maHopDong, int maQuanLy)
        {
            var hd = await _hopDongRepo.GetByIdAsync(maHopDong);
            if (hd == null) return false;
            var phong = await _phongRepo.GetByIdAsync(hd.MaPhong);
            if (phong == null) return false;
            var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            return coSo != null && coSo.MaQuanLy == maQuanLy;
        }

        public async Task<bool> VerifyCustomerOwnershipAsync(int maHopDong, int maKhach)
        {
            var hd = await _hopDongRepo.GetByIdAsync(maHopDong);
            return hd != null && hd.MaKhach == maKhach;
        }

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

        public async Task<HopDongThue?> GetByIdAsync(int id)
        {
            return await _hopDongRepo.GetByIdAsync(id);
        }

        public async Task<byte[]> GeneratePdfBytesAsync(HopDongThue contract)
        {
            var khach = await _khachThueRepo.GetByIdAsync(contract.MaKhach);
            var phong = await _phongRepo.GetByIdAsync(contract.MaPhong);
            var coSo = phong != null ? await _coSoRepo.GetByIdAsync(phong.MaCoSo) : null;
            var quanLy = coSo?.MaQuanLy.HasValue == true ? await _quanLyRepo.GetByIdAsync(coSo.MaQuanLy.Value) : null;

            var khachTen = khach?.HoTen ?? "N/A";
            var khachSdt = khach?.Sdt ?? "N/A";
            var khachCccd = khach?.Cccd ?? "N/A";

            var phongSo = phong?.SoPhong ?? "N/A";
            var coSoTen = coSo?.TenCoSo ?? "N/A";
            var coSoDiaChi = coSo?.DiaChi ?? "N/A";

            var quanLyTen = quanLy?.HoTen ?? "N/A";
            var quanLySdt = quanLy?.Sdt ?? "N/A";
            var quanLyEmail = quanLy?.Email ?? "N/A";

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
                }
            }

            try
            {
                var document = new PdfDocument();
                var page = document.AddPage();
                var gfx = XGraphics.FromPdfPage(page);

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

                gfx.DrawString("CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM", fontTitleMedium, XBrushes.Black, new XRect(0, y, page.Width, 20), XStringFormats.TopCenter);
                y += 18;
                gfx.DrawString("Độc lập - Tự do - Hạnh phúc", fontTitleSmall, XBrushes.Black, new XRect(0, y, page.Width, 20), XStringFormats.TopCenter);
                y += 12;
                gfx.DrawLine(XPens.Black, 220, y, 375, y);
                y += 30;

                gfx.DrawString("HỢP ĐỒNG THUÊ PHÒNG TRỌ", fontTitleLarge, XBrushes.Black, new XRect(0, y, page.Width, 25), XStringFormats.TopCenter);
                y += 24;
                gfx.DrawString($"Số: HD-2026-00{contract.MaHopDong}", fontItalic, XBrushes.Black, new XRect(0, y, page.Width, 20), XStringFormats.TopCenter);
                y += 35;

                string intro = $"- Căn cứ Bộ luật Dân sự nước Cộng hòa Xã hội Chủ nghĩa Việt Nam hiện hành;\n" +
                               $"- Căn cứ vào nhu cầu và thỏa thuận thực tế của các bên.\n" +
                               $"Hôm nay, ngày {DateTime.Now:dd} tháng {DateTime.Now:MM} năm {DateTime.Now:yyyy}, tại cơ sở {coSoTen}, chúng tôi gồm:";
                y = DrawParagraph(gfx, intro, fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 10;

                gfx.DrawString("BÊN CHO THUÊ (BÊN A):", fontBold, XBrushes.Black, marginLeft, y);
                y += 18;
                y = DrawWrappedText(gfx, $" - Họ và tên: {quanLyTen}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Số điện thoại: {quanLySdt}      |      Email: {quanLyEmail}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Đại diện cơ sở: {coSoTen}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Địa chỉ cơ sở: {coSoDiaChi}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 10;

                gfx.DrawString("BÊN THUÊ (BÊN B):", fontBold, XBrushes.Black, marginLeft, y);
                y += 18;
                y = DrawWrappedText(gfx, $" - Họ và tên: {khachTen}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Số điện thoại: {khachSdt}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $" - Số CMND/CCCD: {khachCccd}", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 10;

                gfx.DrawString("CÁC ĐIỀU KHOẢN THỎA THUẬN CHUNG:", fontBold, XBrushes.Black, marginLeft, y);
                y += 18;
                y = DrawWrappedText(gfx, $"Điều 1. Bên A đồng ý cho Bên B thuê phòng số {phongSo} thuộc cơ sở {coSoTen} tại địa chỉ {coSoDiaChi}.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 2. Thời hạn thuê phòng là từ ngày {contract.NgayBatDau:dd/MM/yyyy} đến ngày {contract.NgayKetThuc:dd/MM/yyyy}.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 3. Giá thuê phòng là: {FormatCurrency(phong?.GiaThue)} VNĐ/tháng (Chưa bao gồm chi phí dịch vụ khác).", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 4. Tiền đặt cọc thuê phòng là: {FormatCurrency(contract.TienCoc)} VNĐ. Khoản tiền cọc này dùng để bảo đảm Bên B thực hiện đầy đủ nghĩa vụ của hợp đồng.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 5. Chỉ số điện cũ khi bàn giao: {contract.ChiSoDienCu ?? 0} kWh. Chỉ số nước cũ khi bàn giao: {contract.ChiSoNuocCu ?? 0} m3.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y = DrawWrappedText(gfx, $"Điều 6. Hai bên cam kết thực hiện nghiêm túc các điều khoản thỏa thuận nêu trên và tuân thủ nội quy phòng trọ.", fontRegular, XBrushes.Black, marginLeft, y, contentWidth, 16);
                y += 25;

                gfx.DrawString("Đại diện hai bên ký và ghi rõ họ tên để xác nhận:", fontItalic, XBrushes.Black, marginLeft, y);
                y += 25;

                double colWidth = 220;
                double colLeftX = marginLeft;
                double colRightX = marginLeft + contentWidth - colWidth;

                gfx.DrawString("ĐẠI DIỆN BÊN A (BÊN CHO THUÊ)", fontBold, XBrushes.Black, new XRect(colLeftX, y, colWidth, 20), XStringFormats.TopCenter);
                gfx.DrawString("(Ký, ghi rõ họ tên)", fontItalic, XBrushes.Black, new XRect(colLeftX, y + 16, colWidth, 20), XStringFormats.TopCenter);
                gfx.DrawString(quanLyTen, fontBold, XBrushes.Black, new XRect(colLeftX, y + 105, colWidth, 20), XStringFormats.TopCenter);

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