using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Services
{
    public class OGhepService
    {
        private readonly QuanLyPhongTroContext _context;

        public OGhepService(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // 🌟 1. LOGIC CHI TIẾT Ở GHÉP: TÍNH HOÁ ĐƠN CHIA ĐỀU CHO MOBILE APP
        public OGhepViewDto? GetChiTietOGhepTheoPhong(int maPhong)
        {
            // Lấy thông tin phòng và cơ sở
            var phong = _context.Phongs
                .Include(p => p.MaCoSoNavigation)
                .FirstOrDefault(p => p.MaPhong == maPhong);

            if (phong == null) return null;

            // Tìm tất cả hợp đồng "Đang hiệu lực" của phòng này
            var danhSachHopDong = _context.HopDongThues
                .Include(h => h.MaKhachNavigation)
                .Where(h => h.MaPhong == maPhong && h.TrangThai == "Đang hiệu lực")
                .OrderBy(h => h.NgayBatDau)
                .ToList();

            int soNguoiO = danhSachHopDong.Count;

            // Lấy hóa đơn mới nhất của phòng này
            var hoaDonMoiNhat = _context.HoaDons
                .Where(h => h.MaPhong == maPhong)
                .OrderByDescending(h => h.Nam)
                .ThenByDescending(h => h.Thang)
                .FirstOrDefault();

            decimal tongHoaDon = hoaDonMoiNhat?.TongTien ?? phong.GiaThue; 
            
            // Ép kiểu chia toán học decimal an toàn không lo sập luồng
            decimal tienChiaDeu = soNguoiO > 0 ? (tongHoaDon / (decimal)soNguoiO) : tongHoaDon;

            var dto = new OGhepViewDto
            {
                SoPhong = phong.SoPhong,
                TenCoSo = phong.MaCoSoNavigation?.TenCoSo ?? "Chưa rõ cơ sở",
                SoNguoiO = soNguoiO == 0 ? 1 : soNguoiO, 
                TongHoaDon = tongHoaDon,
                TienChiaDeu = tienChiaDeu
            };

            decimal daThu = 0;

            if (soNguoiO == 0)
            {
                dto.ThanhViens.Add(new ThanhVienOGhepDto
                {
                    MaKhach = 0,
                    HoTen = "Chưa có người ở",
                    VaiTro = "Trống",
                    TrangThaiThanhToan = "Chưa trả",
                    ConPhaiTra = tongHoaDon
                });
                dto.DaThu = 0;
                dto.ConLai = tongHoaDon;
                dto.PhanTramTienDo = 0;
            }
            else
            {
                for (int i = 0; i < danhSachHopDong.Count; i++)
                {
                    var hd = danhSachHopDong[i];
                    bool isChuPhong = (i == 0); 

                    string trangThaiThanhToan = "Chưa trả";
                    if (hoaDonMoiNhat != null)
                    {
                        if (hoaDonMoiNhat.TrangThai == "Đã thanh toán")
                        {
                            trangThaiThanhToan = "Đã trả";
                        }
                        else if (hoaDonMoiNhat.TrangThai == "Quá hạn")
                        {
                            trangThaiThanhToan = "Quá hạn";
                        }
                        else if (isChuPhong && hoaDonMoiNhat.TrangThai == "Một phần") 
                        {
                            trangThaiThanhToan = "Đã trả";
                        }
                    }

                    decimal conPhaiTra = trangThaiThanhToan == "Đã trả" ? 0 : tienChiaDeu;
                    if (trangThaiThanhToan == "Đã trả") daThu += tienChiaDeu;

                    dto.ThanhViens.Add(new ThanhVienOGhepDto
                    {
                        MaKhach = hd.MaKhach,
                        HoTen = hd.MaKhachNavigation?.HoTen ?? "Khách ở ghép",
                        VaiTro = isChuPhong ? "Chủ phòng" : "Ở ghép",
                        TrangThaiThanhToan = trangThaiThanhToan == "Đã trả" ? "Đã trả" : "Chưa trả",
                        ConPhaiTra = conPhaiTra
                    });
                }

                dto.DaThu = daThu;
                dto.ConLai = tongHoaDon - daThu;
                dto.PhanTramTienDo = tongHoaDon > 0 ? (double)(daThu / tongHoaDon) : 0;
            }

            return dto;
        }

        // 🌟 2. TẠO BÀI ĐĂNG TÌM Ở GHÉP MỚI
        public bool CreateOGhep(CreateOGhepDto dto)
        {
            var khach = _context.KhachThues.Find(dto.MaKhach);
            if (khach == null) return false;

            var oghep = new Oghep
            {
                MaKhach = dto.MaKhach,
                TieuDe = dto.TieuDe,
                NoiDung = dto.NoiDung,
                ChiPhiDuKien = dto.ChiPhiDuKien,
                KhuVuc = dto.KhuVuc,
                YeuCauGioiTinh = dto.YeuCauGioiTinh,
                TrangThai = "Đang tìm",
                NgayDang = DateTime.Now
            };

            _context.Ogheps.Add(oghep);
            return _context.SaveChanges() > 0;
        }

        // 🌟 3. LẤY TẤT CẢ BÀI ĐĂNG TÌM Ở GHÉP
        public List<OGhepRenderDto> GetAllOGheps()
        {
            return _context.Ogheps
                .Include(o => o.MaKhachNavigation)
                .Select(o => new OGhepRenderDto
                {
                    MaBaiDang = o.MaBaiDang,
                    MaKhach = o.MaKhach,
                    TenKhach = o.MaKhachNavigation.HoTen ?? "N/A",
                    SDTKhach = o.MaKhachNavigation.Sdt ?? "N/A",
                    TieuDe = o.TieuDe,
                    NoiDung = o.NoiDung,
                    ChiPhiDuKien = o.ChiPhiDuKien,
                    KhuVuc = o.KhuVuc,
                    YeuCauGioiTinh = o.YeuCauGioiTinh,
                    TrangThai = o.TrangThai,
                    NgayDang = o.NgayDang
                })
                .ToList();
        }

        // 🌟 4. LẤY CHI TIẾT BÀI ĐĂNG Ở GHÉP THEO ID BÀI ĐĂNG
        public OGhepRenderDto? GetOGhepById(int id)
        {
            return _context.Ogheps
                .Include(o => o.MaKhachNavigation)
                .Where(o => o.MaBaiDang == id)
                .Select(o => new OGhepRenderDto
                {
                    MaBaiDang = o.MaBaiDang,
                    MaKhach = o.MaKhach,
                    TenKhach = o.MaKhachNavigation.HoTen ?? "N/A",
                    SDTKhach = o.MaKhachNavigation.Sdt ?? "N/A",
                    TieuDe = o.TieuDe,
                    NoiDung = o.NoiDung,
                    ChiPhiDuKien = o.ChiPhiDuKien,
                    KhuVuc = o.KhuVuc,
                    YeuCauGioiTinh = o.YeuCauGioiTinh,
                    TrangThai = o.TrangThai,
                    NgayDang = o.NgayDang
                })
                .FirstOrDefault();
        }

        // 🌟 5. CẬP NHẬT NỘI DUNG BÀI ĐĂNG Ở GHÉP
        public bool UpdateOGhep(int id, CreateOGhepDto dto)
        {
            var oghep = _context.Ogheps.Find(id);
            if (oghep == null) return false;

            oghep.TieuDe = dto.TieuDe;
            oghep.NoiDung = dto.NoiDung;
            oghep.ChiPhiDuKien = dto.ChiPhiDuKien;
            oghep.KhuVuc = dto.KhuVuc;
            oghep.YeuCauGioiTinh = dto.YeuCauGioiTinh;

            return _context.SaveChanges() > 0;
        }

        // 🌟 6. CẬP NHẬT TRẠNG THÁI BÀI ĐĂNG (ĐÃ TÌM ĐƯỢC / ẨN)
        public bool UpdateTrangThai(int id, string trangThai)
        {
            var oghep = _context.Ogheps.Find(id);
            if (oghep == null) return false;

            oghep.TrangThai = trangThai;
            return _context.SaveChanges() > 0;
        }

        // 🌟 7. XÓA BÀI ĐĂNG Ở GHÉP
        public bool DeleteOGhep(int id)
        {
            var oghep = _context.Ogheps.Find(id);
            if (oghep == null) return false;

            _context.Ogheps.Remove(oghep);
            return _context.SaveChanges() > 0;
        }
    }
}