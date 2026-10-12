using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TinNhanController : ControllerBase
    {
        private readonly TinNhanRepository _tinNhanRepo;
        private readonly HopDongRepository _hopDongRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly CounterRepository _counterRepo;

        public TinNhanController(
            TinNhanRepository tinNhanRepo,
            HopDongRepository hopDongRepo,
            KhachThueRepository khachThueRepo,
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            NguoiQuanLyRepository quanLyRepo,
            CounterRepository counterRepo)
        {
            _tinNhanRepo = tinNhanRepo;
            _hopDongRepo = hopDongRepo;
            _khachThueRepo = khachThueRepo;
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _quanLyRepo = quanLyRepo;
            _counterRepo = counterRepo;
        }

        [HttpGet("{maAdmin}/{maKhach}")]
        public async Task<ActionResult<IEnumerable<TinNhan>>> GetChatHistory(int maAdmin, int maKhach)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (maAdmin != maQuanLy) return Forbid("Bạn không có quyền xem tin nhắn này.");
            }

            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int maKhachToken))
            {
                if (maKhach != maKhachToken) return Forbid("Bạn không có quyền xem tin nhắn này.");
            }

            var tatCaTinNhan = await _tinNhanRepo.GetAllAsync();
            var history = tatCaTinNhan
                .Where(t => 
                    (t.MaQuanLy == maAdmin) &&
                    ((t.MaNguoiGui == maAdmin && t.VaiTroNguoiGui == "Admin" && t.MaNguoiNhan == maKhach && t.VaiTroNguoiNhan == "User") ||
                     (t.MaNguoiGui == maKhach && t.VaiTroNguoiGui == "User" && t.MaNguoiNhan == maAdmin && t.VaiTroNguoiNhan == "Admin"))
                )
                .OrderBy(t => t.NgayGui)
                .ToList();

            return Ok(history);
        }

        [HttpPost]
        public async Task<ActionResult<TinNhan>> SendMessage(TinNhan tinNhan)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (tinNhan.VaiTroNguoiGui == "Admin") tinNhan.MaNguoiGui = maQuanLy;
                else if (tinNhan.VaiTroNguoiNhan == "Admin") tinNhan.MaNguoiNhan = maQuanLy;
                tinNhan.MaQuanLy = maQuanLy;
            }
            else
            {
                if (tinNhan.VaiTroNguoiNhan == "Admin") tinNhan.MaQuanLy = tinNhan.MaNguoiNhan;
                else if (tinNhan.VaiTroNguoiGui == "Admin") tinNhan.MaQuanLy = tinNhan.MaNguoiGui;

                var maKhachClaim = User.FindFirst("MaKhach")?.Value;
                if (int.TryParse(maKhachClaim, out int maKhach))
                {
                    if (tinNhan.VaiTroNguoiGui == "User") tinNhan.MaNguoiGui = maKhach;
                    else if (tinNhan.VaiTroNguoiNhan == "User") tinNhan.MaNguoiNhan = maKhach;
                }
            }

            tinNhan.MaTinNhan = await _counterRepo.GetNextSequenceValueAsync("tinnhan_id");
            tinNhan.NgayGui = DateTime.Now;
            tinNhan.DaDoc = false;
            
            await _tinNhanRepo.CreateAsync(tinNhan);

            return Ok(tinNhan);
        }

        [HttpGet("Admin/{maAdmin}/Recent")]
        public async Task<ActionResult<IEnumerable<object>>> GetRecentChatsForAdmin(int maAdmin)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (maAdmin != maQuanLy) return Forbid();
            }

            var tatCaHopDong = await _hopDongRepo.GetAllAsync();
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            
            // Khách đang có hợp đồng hiệu lực với quản lý
            var activeTenants = new List<HopDongThue>();
            foreach(var h in tatCaHopDong.Where(h => h.TrangThai == "Đang hiệu lực"))
            {
                var phong = tatCaPhong.FirstOrDefault(p => p.MaPhong == h.MaPhong);
                if (phong != null)
                {
                    var coSo = tatCaCoSo.FirstOrDefault(cs => cs.MaCoSo == phong.MaCoSo);
                    if (coSo != null && coSo.MaQuanLy == maAdmin)
                    {
                        activeTenants.Add(h);
                    }
                }
            }

            var tatCaTinNhan = await _tinNhanRepo.GetAllAsync();
            var messages = tatCaTinNhan.Where(t => t.MaQuanLy == maAdmin).ToList();

            var userIdsWithMessages = messages
                .Select(t => t.VaiTroNguoiGui == "User" ? t.MaNguoiGui : t.MaNguoiNhan)
                .Where(id => id.HasValue)
                .Select(id => id.Value)
                .Distinct()
                .ToList();

            var activeTenantIds = activeTenants.Select(h => h.MaKhach).Distinct().ToList();
            var allUserIds = activeTenantIds.Union(userIdsWithMessages).Distinct().ToList();

            var recentChats = new List<object>();
            var tatCaKhach = await _khachThueRepo.GetAllAsync();

            foreach (var userId in allUserIds)
            {
                var userMessages = messages
                    .Where(t => (t.MaNguoiGui == userId && t.VaiTroNguoiGui == "User") ||
                                (t.MaNguoiNhan == userId && t.VaiTroNguoiNhan == "User"))
                    .OrderByDescending(t => t.NgayGui)
                    .ToList();

                var lastMessage = userMessages.FirstOrDefault();
                
                var hopDong = activeTenants.FirstOrDefault(h => h.MaKhach == userId);
                var khachThue = tatCaKhach.FirstOrDefault(k => k.MaKhach == userId);
                
                string tenKhach = khachThue?.HoTen;
                string soPhong = null;
                int category = 1;

                if (hopDong != null)
                {
                    var phong = tatCaPhong.FirstOrDefault(p => p.MaPhong == hopDong.MaPhong);
                    soPhong = phong?.SoPhong;
                }
                else
                {
                    var pastContracts = new List<HopDongThue>();
                    foreach(var h in tatCaHopDong.Where(h => h.MaKhach == userId))
                    {
                        var p = tatCaPhong.FirstOrDefault(p => p.MaPhong == h.MaPhong);
                        if (p != null)
                        {
                            var cs = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == p.MaCoSo);
                            if (cs != null && cs.MaQuanLy == maAdmin) pastContracts.Add(h);
                        }
                    }

                    var anyContract = pastContracts.OrderByDescending(h => h.NgayBatDau).FirstOrDefault();
                    if (anyContract != null)
                    {
                        category = 3;
                        var p = tatCaPhong.FirstOrDefault(x => x.MaPhong == anyContract.MaPhong);
                        soPhong = p?.SoPhong ?? "N/A";
                    }
                    else
                    {
                        category = 2;
                        soPhong = "N/A";
                    }
                }

                var unreadCount = userMessages.Count(t => t.MaNguoiNhan == maAdmin && t.VaiTroNguoiNhan == "Admin" && t.DaDoc == false);

                recentChats.Add(new
                {
                    MaKhach = userId,
                    TenKhach = tenKhach ?? "Khách " + userId,
                    SoPhong = soPhong,
                    LastMessage = lastMessage?.NoiDung ?? "Chưa có tin nhắn nào",
                    NgayGui = (DateTime?)lastMessage?.NgayGui,
                    IsUnread = unreadCount > 0,
                    UnreadCount = unreadCount,
                    Category = category
                });
            }

            return Ok(recentChats.OrderByDescending(c => ((dynamic)c).NgayGui ?? DateTime.MinValue));
        }

        [HttpGet("User/{maKhach}/Recent")]
        public async Task<ActionResult<IEnumerable<object>>> GetRecentChatsForUser(int maKhach)
        {
            var maKhachClaim = User.FindFirst("MaKhach")?.Value;
            if (int.TryParse(maKhachClaim, out int maKhachToken))
            {
                if (maKhach != maKhachToken) return Forbid();
            }

            var tatCaTinNhan = await _tinNhanRepo.GetAllAsync();
            var messages = tatCaTinNhan
                .Where(t => (t.MaNguoiGui == maKhach && t.VaiTroNguoiGui == "User") ||
                            (t.MaNguoiNhan == maKhach && t.VaiTroNguoiNhan == "User"))
                .ToList();

            var adminIdsWithMessages = messages
                .Select(t => t.VaiTroNguoiGui == "Admin" ? t.MaNguoiGui : t.MaNguoiNhan)
                .Where(id => id.HasValue)
                .Select(id => id.Value)
                .Distinct()
                .ToList();

            var tatCaHopDong = await _hopDongRepo.GetAllAsync();
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();

            var activeContracts = tatCaHopDong
                .Where(h => h.MaKhach == maKhach && (h.TrangThai == "Đang hiệu lực" || h.TrangThai == "Còn hạn" || h.TrangThai == "Đã ký"))
                .ToList();

            var contractAdminIds = new List<int>();
            foreach (var h in activeContracts)
            {
                var phong = tatCaPhong.FirstOrDefault(p => p.MaPhong == h.MaPhong);
                if (phong != null)
                {
                    var coSo = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == phong.MaCoSo);
                    if (coSo != null && coSo.MaQuanLy.HasValue)
                    {
                        contractAdminIds.Add(coSo.MaQuanLy.Value);
                    }
                }
            }

            var allAdminIds = adminIdsWithMessages.Union(contractAdminIds).Distinct().ToList();
            var recentChats = new List<object>();

            foreach (var adminId in allAdminIds)
            {
                var adminMessages = messages
                    .Where(t => (t.MaNguoiGui == adminId && t.VaiTroNguoiGui == "Admin") ||
                                (t.MaNguoiNhan == adminId && t.VaiTroNguoiNhan == "Admin"))
                    .OrderByDescending(t => t.NgayGui)
                    .ToList();

                var lastMessage = adminMessages.FirstOrDefault();
                var admin = await _quanLyRepo.GetByIdAsync(adminId);
                string tenAdmin = admin?.HoTen ?? "Admin " + adminId;

                var unreadCount = adminMessages.Count(t => t.MaNguoiNhan == maKhach && t.VaiTroNguoiNhan == "User" && t.DaDoc == false);

                recentChats.Add(new
                {
                    MaAdmin = adminId,
                    TenAdmin = tenAdmin,
                    LastMessage = lastMessage?.NoiDung ?? "Chưa có tin nhắn nào",
                    NgayGui = (DateTime?)lastMessage?.NgayGui,
                    IsUnread = unreadCount > 0,
                    UnreadCount = unreadCount
                });
            }

            return Ok(recentChats.OrderByDescending(c => ((dynamic)c).NgayGui ?? DateTime.MinValue));
        }
    }
}
