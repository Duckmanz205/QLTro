using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using PhongTroAPI.Repositories.Redis;

namespace PhongTroAPI.Services
{
    public class LichHenService
    {
        private readonly LichHenRepository _lichHenRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly NotificationRepository _notiRepo;
        private readonly CounterRepository _counterRepo;

        public LichHenService(
            LichHenRepository lichHenRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            NotificationRepository notiRepo,
            CounterRepository counterRepo)
        {
            _lichHenRepo = lichHenRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _notiRepo = notiRepo;
            _counterRepo = counterRepo;
        }

        public async Task<bool> CreateLichHenAsync(CreateLichHenDto dto)
        {
            var lichHen = new LichHenXemPhong
            {
                MaLichHen = await _counterRepo.GetNextSequenceValueAsync("lichhen_id"),
                MaKhach = dto.MaKhach,        
                HoTenKhach = dto.HoTenKhach ?? "Khách ẩn danh",
                Sdtkhach = dto.SdtKhach,       
                MaPhong = dto.MaPhong,
                ThoiGianHen = dto.ThoiGianHen,
                GhiChu = dto.GhiChu,
                TrangThai = "Chờ xác nhận",    
                NgayTao = DateTime.Now
            };

            await _lichHenRepo.CreateAsync(lichHen);

            var room = await _phongRepo.GetByIdAsync(dto.MaPhong);
            var coSo = room != null ? await _coSoRepo.GetByIdAsync(room.MaCoSo) : null;

            if (room != null && dto.MaKhach.HasValue && dto.MaKhach.Value > 0)
            {
                int? maQuanLy = coSo?.MaQuanLy;
                string tenCoSo = coSo?.TenCoSo ?? "";

                if (maQuanLy.HasValue)
                {
                    var thongBaoAdmin = new ThongBao
                    {
                        MaKhach = dto.MaKhach.Value,
                        MaQuanLy = maQuanLy.Value,
                        TieuDe = "Đặt lịch xem phòng mới",
                        NoiDung = $"Khách hàng {dto.HoTenKhach} đã đặt lịch xem phòng {room.SoPhong} ({tenCoSo}) vào lúc {dto.ThoiGianHen:dd/MM/yyyy HH:mm}.",
                        DaDoc = false,
                        NgayGui = DateTime.Now
                    };
                    // Push notification to Redis for Admin (using user/admin ID convention or separate queue)
                    await _notiRepo.AddNotificationAsync(maQuanLy.Value, thongBaoAdmin);
                }

                var thongBaoUser = new ThongBao
                {
                    MaKhach = dto.MaKhach.Value,
                    MaQuanLy = maQuanLy,
                    TieuDe = "Đặt lịch xem phòng thành công",
                    NoiDung = $"Bạn đã đặt lịch xem phòng {room.SoPhong} ({tenCoSo}) vào lúc {dto.ThoiGianHen:dd/MM/yyyy HH:mm}. Vui lòng chờ admin xác nhận.",
                    DaDoc = false,
                    NgayGui = DateTime.Now
                };
                await _notiRepo.AddNotificationAsync(dto.MaKhach.Value, thongBaoUser);
            }

            return true;
        }

        public async Task<List<LichHenRenderDto>> GetDanhSachLichHenAsync(int? maQuanLy = null)
        {
            var tatCaLH = await _lichHenRepo.GetAllAsync();
            var result = new List<LichHenRenderDto>();

            foreach (var lh in tatCaLH)
            {
                var p = await _phongRepo.GetByIdAsync(lh.MaPhong);
                var c = p != null ? await _coSoRepo.GetByIdAsync(p.MaCoSo) : null;

                if (maQuanLy.HasValue && (c == null || c.MaQuanLy != maQuanLy.Value))
                    continue;

                result.Add(new LichHenRenderDto
                {
                    MaLichHen = lh.MaLichHen,
                    MaKhach = lh.MaKhach,
                    MaPhong = lh.MaPhong,
                    HoTenKhach = lh.HoTenKhach,
                    SdtKhach = lh.Sdtkhach,
                    SoPhong = p?.SoPhong ?? "Trống",       
                    TenCoSo = c?.TenCoSo ?? "Chưa rõ cơ sở", 
                    ThoiGianHen = lh.ThoiGianHen,
                    TrangThai = lh.TrangThai,
                    GhiChu = lh.GhiChu,
                    NgayTao = lh.NgayTao
                });
            }

            return result.OrderByDescending(lh => lh.ThoiGianHen).ToList();
        }

        public async Task<bool> VerifyOwnershipAsync(int maLichHen, int maQuanLy)
        {
            var lh = await _lichHenRepo.GetByIdAsync(maLichHen);
            if (lh == null) return false;
            var p = await _phongRepo.GetByIdAsync(lh.MaPhong);
            if (p == null) return false;
            var c = await _coSoRepo.GetByIdAsync(p.MaCoSo);
            return c != null && c.MaQuanLy == maQuanLy;
        }

        public async Task<bool> UpdateTrangThaiLichAsync(int id, string trangThaiMoi)
        {
            var lichHen = await _lichHenRepo.GetByIdAsync(id);
            if (lichHen == null) return false;

            lichHen.TrangThai = trangThaiMoi;
            await _lichHenRepo.UpdateAsync(id, lichHen);
            return true; 
        }

        public async Task<bool> UpdateLichHenAsync(int id, CreateLichHenDto dto)
        {
            var lichHen = await _lichHenRepo.GetByIdAsync(id);
            if (lichHen == null) return false;

            lichHen.MaKhach = dto.MaKhach; 
            lichHen.HoTenKhach = dto.HoTenKhach;
            lichHen.Sdtkhach = dto.SdtKhach;     
            lichHen.MaPhong = dto.MaPhong;
            lichHen.ThoiGianHen = dto.ThoiGianHen;
            lichHen.GhiChu = dto.GhiChu;

            await _lichHenRepo.UpdateAsync(id, lichHen);
            return true;
        }

        public async Task<bool> DeleteLichHenAsync(int id)
        {
            await _lichHenRepo.DeleteAsync(id);
            return true;
        }

        public async Task<object?> GetLichHenByIdAsync(int id)
        {
            var lh = await _lichHenRepo.GetByIdAsync(id);
            if (lh == null) return null;

            var p = await _phongRepo.GetByIdAsync(lh.MaPhong);
            var c = p != null ? await _coSoRepo.GetByIdAsync(p.MaCoSo) : null;

            return new
            {
                MaLichHen = lh.MaLichHen,
                MaKhach = lh.MaKhach,
                HoTenKhach = lh.HoTenKhach,
                SDTKhach = lh.Sdtkhach,
                ThoiGianHen = lh.ThoiGianHen,
                GhiChu = lh.GhiChu,
                TrangThai = lh.TrangThai,
                SoPhong = p?.SoPhong ?? "Trống",
                TenCoSo = c?.TenCoSo ?? "Chưa rõ cơ sở"
            };
        }

        public async Task<List<LichHenViewDto>> GetDanhSachLichHenByKhachAsync(int maKhach)
        {
            var tatCaLH = await _lichHenRepo.GetAllAsync();
            var customerLH = tatCaLH.Where(l => l.MaKhach == maKhach).ToList();
            
            var result = new List<LichHenViewDto>();
            foreach (var l in customerLH)
            {
                var p = await _phongRepo.GetByIdAsync(l.MaPhong);
                var c = p != null ? await _coSoRepo.GetByIdAsync(p.MaCoSo) : null;

                result.Add(new LichHenViewDto
                {
                    MaLichHen = l.MaLichHen,
                    SoPhong = p?.SoPhong ?? "Trống",
                    TenCoSo = c?.TenCoSo ?? "Chưa rõ cơ sở",
                    ThoiGianHen = l.ThoiGianHen,
                    GhiChu = l.GhiChu,
                    TrangThai = l.TrangThai ?? "Chờ xác nhận",
                    NgayTao = l.NgayTao
                });
            }

            return result.OrderByDescending(l => l.ThoiGianHen).ToList();
        }
    }
}