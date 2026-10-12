using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;

namespace PhongTroAPI.Services
{
    public class OGhepService
    {
        private readonly OGhepRepository _oghepRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly HopDongRepository _hopDongRepo;
        private readonly HoaDonRepository _hoaDonRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly CounterRepository _counterRepo;

        public OGhepService(
            OGhepRepository oghepRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            HopDongRepository hopDongRepo,
            HoaDonRepository hoaDonRepo,
            KhachThueRepository khachThueRepo,
            CounterRepository counterRepo)
        {
            _oghepRepo = oghepRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _hopDongRepo = hopDongRepo;
            _hoaDonRepo = hoaDonRepo;
            _khachThueRepo = khachThueRepo;
            _counterRepo = counterRepo;
        }

        public async Task<OGhepViewDto?> GetChiTietOGhepTheoPhongAsync(int maPhong)
        {
            var phong = await _phongRepo.GetByIdAsync(maPhong);
            if (phong == null) return null;

            var coSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);

            var tatCaHopDong = await _hopDongRepo.GetAllAsync();
            var danhSachHopDong = tatCaHopDong
                .Where(h => h.MaPhong == maPhong && h.TrangThai == "Đang hiệu lực")
                .OrderBy(h => h.NgayBatDau)
                .ToList();

            int soNguoiO = danhSachHopDong.Count;

            var tatCaHoaDon = await _hoaDonRepo.GetAllAsync();
            var hoaDonMoiNhat = tatCaHoaDon
                .Where(h => h.MaPhong == maPhong)
                .OrderByDescending(h => h.Nam)
                .ThenByDescending(h => h.Thang)
                .FirstOrDefault();

            decimal tongHoaDon = hoaDonMoiNhat?.TongTien ?? phong.GiaThue; 
            decimal tienChiaDeu = soNguoiO > 0 ? (tongHoaDon / (decimal)soNguoiO) : tongHoaDon;

            var dto = new OGhepViewDto
            {
                SoPhong = phong.SoPhong,
                TenCoSo = coSo?.TenCoSo ?? "Chưa rõ cơ sở",
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
                    var khach = await _khachThueRepo.GetByIdAsync(hd.MaKhach);

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
                        HoTen = khach?.HoTen ?? "Khách ở ghép",
                        VaiTro = isChuPhong ? "Chủ phòng" : "Ở ghép",
                        TrangThaiThanhToan = trangThaiThanhToan,
                        ConPhaiTra = conPhaiTra
                    });
                }

                dto.DaThu = daThu;
                dto.ConLai = tongHoaDon - daThu;
                dto.PhanTramTienDo = tongHoaDon > 0 ? (double)(daThu / tongHoaDon) : 0;
            }

            return dto;
        }

        public async Task<bool> CreateOGhepAsync(CreateOGhepDto dto)
        {
            var khach = await _khachThueRepo.GetByIdAsync(dto.MaKhach);
            if (khach == null) return false;

            var oghep = new OGhep
            {
                MaBaiDang = await _counterRepo.GetNextSequenceValueAsync("oghep_id"),
                MaKhach = dto.MaKhach,
                TieuDe = dto.TieuDe,
                NoiDung = dto.NoiDung,
                ChiPhiDuKien = dto.ChiPhiDuKien,
                KhuVuc = dto.KhuVuc,
                YeuCauGioiTinh = dto.YeuCauGioiTinh,
                TrangThai = "Đang tìm",
                NgayDang = DateTime.Now
            };

            await _oghepRepo.CreateAsync(oghep);
            return true;
        }

        public async Task<List<OGhepRenderDto>> GetAllOGhepsAsync()
        {
            var tatCaOGhep = await _oghepRepo.GetAllAsync();
            var result = new List<OGhepRenderDto>();

            foreach (var o in tatCaOGhep)
            {
                var khach = await _khachThueRepo.GetByIdAsync(o.MaKhach);
                result.Add(new OGhepRenderDto
                {
                    MaBaiDang = o.MaBaiDang,
                    MaKhach = o.MaKhach,
                    TenKhach = khach?.HoTen ?? "N/A",
                    SDTKhach = khach?.Sdt ?? "N/A",
                    TieuDe = o.TieuDe,
                    NoiDung = o.NoiDung,
                    ChiPhiDuKien = o.ChiPhiDuKien,
                    KhuVuc = o.KhuVuc,
                    YeuCauGioiTinh = o.YeuCauGioiTinh,
                    TrangThai = o.TrangThai,
                    NgayDang = o.NgayDang
                });
            }
            return result;
        }

        public async Task<OGhepRenderDto?> GetOGhepByIdAsync(int id)
        {
            var o = await _oghepRepo.GetByIdAsync(id);
            if (o == null) return null;

            var khach = await _khachThueRepo.GetByIdAsync(o.MaKhach);
            return new OGhepRenderDto
            {
                MaBaiDang = o.MaBaiDang,
                MaKhach = o.MaKhach,
                TenKhach = khach?.HoTen ?? "N/A",
                SDTKhach = khach?.Sdt ?? "N/A",
                TieuDe = o.TieuDe,
                NoiDung = o.NoiDung,
                ChiPhiDuKien = o.ChiPhiDuKien,
                KhuVuc = o.KhuVuc,
                YeuCauGioiTinh = o.YeuCauGioiTinh,
                TrangThai = o.TrangThai,
                NgayDang = o.NgayDang
            };
        }

        public async Task<bool> UpdateOGhepAsync(int id, CreateOGhepDto dto)
        {
            var oghep = await _oghepRepo.GetByIdAsync(id);
            if (oghep == null) return false;

            oghep.TieuDe = dto.TieuDe;
            oghep.NoiDung = dto.NoiDung;
            oghep.ChiPhiDuKien = dto.ChiPhiDuKien;
            oghep.KhuVuc = dto.KhuVuc;
            oghep.YeuCauGioiTinh = dto.YeuCauGioiTinh;

            await _oghepRepo.UpdateAsync(id, oghep);
            return true;
        }

        public async Task<bool> UpdateTrangThaiAsync(int id, string trangThai)
        {
            var oghep = await _oghepRepo.GetByIdAsync(id);
            if (oghep == null) return false;

            oghep.TrangThai = trangThai;
            await _oghepRepo.UpdateAsync(id, oghep);
            return true;
        }

        public async Task<bool> DeleteOGhepAsync(int id)
        {
            await _oghepRepo.DeleteAsync(id);
            return true;
        }
    }
}