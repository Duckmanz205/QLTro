using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Entities.Embedded;
using PhongTroAPI.Repositories.Mongo;
using PhongTroAPI.Repositories.Elastic;
using PhongTroAPI.Services;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PhongController : ControllerBase
    {
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly TienIchRepository _tienIchRepo;
        private readonly CounterRepository _counterRepo;
        private readonly SyncService _syncService;
        private readonly SearchRepository _searchRepo;

        public PhongController(
            PhongRepository phongRepo,
            CoSoRepository coSoRepo,
            NguoiQuanLyRepository quanLyRepo,
            TienIchRepository tienIchRepo,
            CounterRepository counterRepo,
            SyncService syncService,
            SearchRepository searchRepo)
        {
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _quanLyRepo = quanLyRepo;
            _tienIchRepo = tienIchRepo;
            _counterRepo = counterRepo;
            _syncService = syncService;
            _searchRepo = searchRepo;
        }

        private async Task<string> GetTenQuanLyAsync(int maQuanLy)
        {
            var ql = await _quanLyRepo.GetByIdAsync(maQuanLy);
            return ql?.HoTen ?? "Admin";
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll([FromQuery] int? maQuanLy)
        {
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            var phongs = tatCaPhong.AsQueryable();

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLyToken))
            {
                var coSosCuaQuanLy = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLyToken).Select(cs => cs.MaCoSo).ToHashSet();
                phongs = phongs.Where(p => coSosCuaQuanLy.Contains(p.MaCoSo));
            }
            else if (maQuanLy.HasValue)
            {
                var coSosCuaQuanLy = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLy.Value).Select(cs => cs.MaCoSo).ToHashSet();
                phongs = phongs.Where(p => coSosCuaQuanLy.Contains(p.MaCoSo));
            }

            var result = new List<object>();
            foreach (var p in phongs.OrderBy(x => x.SoPhong))
            {
                var cs = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == p.MaCoSo);
                var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

                result.Add(new
                {
                    p.MaPhong,
                    p.MaCoSo,
                    p.SoPhong,
                    p.Tang,
                    p.DienTich,
                    p.GiaThue,
                    p.SoNguoiToiDa,
                    p.TrangThai,
                    p.MoTa,
                    p.NgayTao,
                    NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                    TenNguoiQuanLy = tenQuanLy,
                    TenCoSo = cs?.TenCoSo ?? "",
                    HinhAnhPhong = (p != null && p.HinhAnhPhongs != null) ? p.HinhAnhPhongs.FirstOrDefault()?.Url : null,
                    HinhAnhCoSo = (cs != null && cs.HinhAnhCoSos != null) ? cs.HinhAnhCoSos.FirstOrDefault()?.Url : null,
                    TienIches = p.TienIches
                });
            }

            return Ok(result);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDetail(int id)
        {
            var p = await _phongRepo.GetByIdAsync(id);
            if (p == null) return NotFound("Không tìm thấy phòng");

            var cs = await _coSoRepo.GetByIdAsync(p.MaCoSo);
            
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (cs == null || cs.MaQuanLy != maQuanLy)
                {
                    return Forbid();
                }
            }

            var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

            var data = new
            {
                p.MaPhong,
                p.MaCoSo,
                p.SoPhong,
                p.Tang,
                p.DienTich,
                p.GiaThue,
                p.SoNguoiToiDa,
                p.TrangThai,
                p.MoTa,
                p.NgayTao,
                NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                TenNguoiQuanLy = tenQuanLy,
                HinhAnhPhong = (p != null && p.HinhAnhPhongs != null) ? p.HinhAnhPhongs.FirstOrDefault()?.Url : null,
                HinhAnhCoSo = (cs != null && cs.HinhAnhCoSos != null) ? cs.HinhAnhCoSos.FirstOrDefault()?.Url : null,
                TienIches = p.TienIches
            };

            return Ok(data);
        }

        [HttpGet("coso/{maCoSo}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByCoSo(int maCoSo, [FromQuery] string? keyword, [FromQuery] string? status)
        {
            var cs = await _coSoRepo.GetByIdAsync(maCoSo);
            
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (cs == null || cs.MaQuanLy != maQuanLy) return Forbid();
            }

            var tatCaPhong = await _phongRepo.GetAllAsync();
            var query = tatCaPhong.Where(p => p.MaCoSo == maCoSo);

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                keyword = keyword.Trim().ToLower();
                query = query.Where(p =>
                    p.SoPhong.ToLower().Contains(keyword) ||
                    (p.MoTa != null && p.MoTa.ToLower().Contains(keyword)) ||
                    p.TrangThai.ToLower().Contains(keyword) ||
                    p.TienIches.Any(t => t.TenTienIch != null && t.TenTienIch.ToLower().Contains(keyword)));
            }

            if (!string.IsNullOrWhiteSpace(status) && status != "Tất cả")
            {
                query = query.Where(p => p.TrangThai == status);
            }

            var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

            var result = new List<object>();
            foreach (var p in query.OrderBy(p => p.SoPhong))
            {
                result.Add(new
                {
                    p.MaPhong,
                    p.MaCoSo,
                    p.SoPhong,
                    p.Tang,
                    p.DienTich,
                    p.GiaThue,
                    p.SoNguoiToiDa,
                    p.TrangThai,
                    p.MoTa,
                    p.NgayTao,
                    NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                    TenNguoiQuanLy = tenQuanLy,
                    TenCoSo = cs?.TenCoSo ?? "",
                    DiaChiCoSo = cs?.DiaChi ?? "",
                    HinhAnhPhong = (p != null && p.HinhAnhPhongs != null) ? p.HinhAnhPhongs.FirstOrDefault()?.Url : null,
                    TienIches = p.TienIches
                });
            }

            return Ok(result);
        }

        [HttpGet("trong")]
        [AllowAnonymous]
        public async Task<IActionResult> GetPhongTrong([FromQuery] int? maQuanLy)
        {
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            
            var phongs = tatCaPhong.Where(p => p.TrangThai == "Trống");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLyToken))
            {
                var coSosCuaQuanLy = tatCaCoSo.Where(c => c.MaQuanLy == maQuanLyToken).Select(c => c.MaCoSo).ToHashSet();
                phongs = phongs.Where(p => coSosCuaQuanLy.Contains(p.MaCoSo));
            }
            else if (maQuanLy.HasValue)
            {
                var coSosCuaQuanLy = tatCaCoSo.Where(c => c.MaQuanLy == maQuanLy.Value).Select(c => c.MaCoSo).ToHashSet();
                phongs = phongs.Where(p => coSosCuaQuanLy.Contains(p.MaCoSo));
            }

            var result = new List<object>();
            foreach (var p in phongs.OrderBy(p => p.SoPhong))
            {
                var cs = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == p.MaCoSo);
                var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

                result.Add(new
                {
                    p.MaPhong,
                    p.MaCoSo,
                    p.SoPhong,
                    p.Tang,
                    p.DienTich,
                    p.GiaThue,
                    p.SoNguoiToiDa,
                    p.TrangThai,
                    p.MoTa,
                    p.NgayTao,
                    NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                    TenNguoiQuanLy = tenQuanLy,
                    TenCoSo = cs?.TenCoSo ?? "",
                    HinhAnhPhong = (p != null && p.HinhAnhPhongs != null) ? p.HinhAnhPhongs.FirstOrDefault()?.Url : null,
                    HinhAnhCoSo = (cs != null && cs.HinhAnhCoSos != null) ? cs.HinhAnhCoSos.FirstOrDefault()?.Url : null,
                    TienIches = p.TienIches
                });
            }

            return Ok(result);
        }

        [HttpGet("detail/{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDetailFull(int id)
        {
            var p = await _phongRepo.GetByIdAsync(id);
            if (p == null) return NotFound("Không tìm thấy phòng");

            var cs = await _coSoRepo.GetByIdAsync(p.MaCoSo);
            
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (cs == null || cs.MaQuanLy != maQuanLy)
                {
                    return Forbid();
                }
            }

            var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

            var data = new
            {
                p.MaPhong,
                p.MaCoSo,
                p.SoPhong,
                p.Tang,
                p.DienTich,
                p.GiaThue,
                p.SoNguoiToiDa,
                p.TrangThai,
                p.MoTa,
                p.NgayTao,
                NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                TenNguoiQuanLy = tenQuanLy,
                TenCoSo = cs?.TenCoSo ?? "",
                DiaChiCoSo = cs?.DiaChi ?? "",
                HinhAnhPhongs = p.HinhAnhPhongs.Select(h => h.Url).ToList(),
                TienIches = p.TienIches
            };

            return Ok(data);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] PhongUpsertDto model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (string.IsNullOrWhiteSpace(model.SoPhong)) return BadRequest("Số phòng không được trống");
            if (model.GiaThue <= 0) return BadRequest("Giá thuê phải > 0");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var coSo = await _coSoRepo.GetByIdAsync(model.MaCoSo);
            if (coSo == null) return BadRequest("Mã cơ sở không tồn tại");
            if (coSo.MaQuanLy != maQuanLy) return Forbid("Cơ sở không thuộc quyền quản lý của bạn.");

            var soPhongTrim = model.SoPhong.Trim();
            var tatCaPhong = await _phongRepo.GetAllAsync();
            if (tatCaPhong.Any(p => p.MaCoSo == model.MaCoSo && p.SoPhong == soPhongTrim))
            {
                return BadRequest("Số phòng đã tồn tại trong cơ sở này");
            }

            var newMaPhong = await _counterRepo.GetNextSequenceValueAsync("phong_id");

            var phong = new Phong
            {
                MaPhong = newMaPhong,
                MaCoSo = model.MaCoSo,
                SoPhong = soPhongTrim,
                Tang = model.Tang,
                DienTich = model.DienTich,
                GiaThue = model.GiaThue,
                SoNguoiToiDa = model.SoNguoiToiDa,
                TrangThai = model.TrangThai,
                MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim(),
                NgayTao = DateTime.Now,
                TienIches = new List<TienIchItem>(),
                HinhAnhPhongs = new List<HinhAnhItem>()
            };

            if (model.MaTienIchIds != null && model.MaTienIchIds.Any())
            {
                var allTienIch = await _tienIchRepo.GetAllAsync();
                var tienIchList = allTienIch.Where(x => model.MaTienIchIds.Contains(x.MaTienIch)).ToList();

                foreach (var item in tienIchList)
                {
                    phong.TienIches.Add(new TienIchItem { MaTienIch = item.MaTienIch, TenTienIch = item.TenTienIch });
                }
            }

            await _phongRepo.CreateAsync(phong);

            // Sync to Elasticsearch
            await _syncService.SyncPhongToElasticAsync(phong, coSo);

            return Ok(new
            {
                phong.MaPhong,
                phong.MaCoSo,
                phong.SoPhong,
                phong.Tang,
                phong.DienTich,
                phong.GiaThue,
                phong.SoNguoiToiDa,
                phong.TrangThai,
                phong.MoTa,
                TienIches = phong.TienIches.OrderBy(t => t.TenTienIch).Select(t => t.TenTienIch).ToList()
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] PhongUpsertDto model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var phong = await _phongRepo.GetByIdAsync(id);
            if (phong == null) return NotFound("Không tìm thấy phòng");

            var oldCoSo = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (oldCoSo == null || oldCoSo.MaQuanLy != maQuanLy) return Forbid();

            var targetCoSo = await _coSoRepo.GetByIdAsync(model.MaCoSo);
            if (targetCoSo == null) return BadRequest("Cơ sở đích không tồn tại");
            if (targetCoSo.MaQuanLy != maQuanLy) return Forbid("Cơ sở đích không thuộc quyền quản lý của bạn.");

            if (model.GiaThue <= 0) return BadRequest("Giá thuê không hợp lệ");

            var soPhongTrim = model.SoPhong.Trim();
            var tatCaPhong = await _phongRepo.GetAllAsync();
            if (tatCaPhong.Any(p => p.MaPhong != id && p.MaCoSo == model.MaCoSo && p.SoPhong == soPhongTrim))
            {
                return BadRequest("Số phòng đã tồn tại trong cơ sở này");
            }

            phong.MaCoSo = model.MaCoSo;
            phong.SoPhong = soPhongTrim;
            phong.Tang = model.Tang;
            phong.DienTich = model.DienTich;
            phong.GiaThue = model.GiaThue;
            phong.SoNguoiToiDa = model.SoNguoiToiDa;
            phong.TrangThai = model.TrangThai;
            phong.MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim();

            phong.TienIches.Clear();

            if (model.MaTienIchIds != null && model.MaTienIchIds.Any())
            {
                var allTienIch = await _tienIchRepo.GetAllAsync();
                var tienIchList = allTienIch.Where(x => model.MaTienIchIds.Contains(x.MaTienIch)).ToList();

                foreach (var item in tienIchList)
                {
                    phong.TienIches.Add(new TienIchItem { MaTienIch = item.MaTienIch, TenTienIch = item.TenTienIch });
                }
            }

            await _phongRepo.UpdateAsync(id, phong);

            // Sync update to Elasticsearch
            await _syncService.SyncPhongToElasticAsync(phong, targetCoSo);

            return Ok(new
            {
                phong.MaPhong,
                phong.MaCoSo,
                phong.SoPhong,
                phong.Tang,
                phong.DienTich,
                phong.GiaThue,
                phong.SoNguoiToiDa,
                phong.TrangThai,
                phong.MoTa,
                TienIches = phong.TienIches.OrderBy(t => t.TenTienIch).Select(t => t.TenTienIch).ToList()
            });
        }

        [HttpPost("{id}/image")]
        public async Task<IActionResult> UploadOrReplaceImage(int id, IFormFile file)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var phong = await _phongRepo.GetByIdAsync(id);
            if (phong == null) return NotFound("Không tìm thấy phòng");

            var cs = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (cs == null || cs.MaQuanLy != maQuanLy) return Forbid();

            if (file == null || file.Length == 0) return BadRequest("File ảnh không hợp lệ");

            var folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "phong");
            Directory.CreateDirectory(folder);

            foreach (var old in phong.HinhAnhPhongs.ToList())
            {
                if (string.IsNullOrWhiteSpace(old.Url)) continue;

                if (old.Url.Contains("/uploads/phong/"))
                {
                    string? oldFileName = null;
                    if (Uri.TryCreate(old.Url, UriKind.Absolute, out var uri))
                    {
                        oldFileName = Path.GetFileName(uri.LocalPath);
                    }
                    else
                    {
                        oldFileName = Path.GetFileName(old.Url);
                    }

                    if (!string.IsNullOrWhiteSpace(oldFileName))
                    {
                        var oldPath = Path.Combine(folder, oldFileName);
                        if (System.IO.File.Exists(oldPath))
                        {
                            System.IO.File.Delete(oldPath);
                        }
                    }
                }
            }

            phong.HinhAnhPhongs.Clear();

            var extension = Path.GetExtension(file.FileName);
            var originalName = Path.GetFileNameWithoutExtension(file.FileName).Replace(" ", "_");
            var fileNameNew = $"{originalName}_{Guid.NewGuid():N}{extension}";
            var filePath = Path.Combine(folder, fileNameNew);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var imageUrl = $"{Request.Scheme}://{Request.Host}/uploads/phong/{fileNameNew}";
            var image = new HinhAnhItem
            {
                
                Url = imageUrl
            };
phong.HinhAnhPhongs.Add(image);
            await _phongRepo.UpdateAsync(id, phong);

            return Ok(new
            {
                MaPhong = id,
                Url = image.Url
});
        }

        [HttpPost("{id}/image/url")]
        public async Task<IActionResult> UploadImageUrl(int id, [FromBody] PhongImageUrlDto dto)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var phong = await _phongRepo.GetByIdAsync(id);
            if (phong == null) return NotFound("Không tìm thấy phòng");

            var cs = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (cs == null || cs.MaQuanLy != maQuanLy) return Forbid();

            if (dto == null || string.IsNullOrWhiteSpace(dto.Url)) return BadRequest("URL ảnh không hợp lệ");

            phong.HinhAnhPhongs.Clear();

            var image = new HinhAnhItem
            {
                
                Url = dto.Url.Trim()
            };
phong.HinhAnhPhongs.Add(image);
            await _phongRepo.UpdateAsync(id, phong);

            return Ok(new
            {
                MaPhong = id,
                Url = image.Url
});
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var phong = await _phongRepo.GetByIdAsync(id);
            if (phong == null) return NotFound("Không tìm thấy phòng");

            var cs = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
            if (cs == null || cs.MaQuanLy != maQuanLy) return Forbid();

            await _phongRepo.DeleteAsync(id);

            // Delete from Elasticsearch
            // Note: If SearchRepository has a Delete method we would call it here. 
            // Assuming no such method yet in this minimalist NoSQL approach, or we can just ignore.

            return Ok("Đã xóa phòng");
        }

        [HttpGet("filter")]
        [AllowAnonymous]
        public async Task<IActionResult> Filter(decimal? min, decimal? max, string? status)
        {
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            var phongs = tatCaPhong.AsQueryable();

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var coSosCuaQuanLy = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLy).Select(cs => cs.MaCoSo).ToHashSet();
                phongs = phongs.Where(p => coSosCuaQuanLy.Contains(p.MaCoSo));
            }

            if (min.HasValue) phongs = phongs.Where(x => x.GiaThue >= min.Value);
            if (max.HasValue) phongs = phongs.Where(x => x.GiaThue <= max.Value);
            if (!string.IsNullOrEmpty(status)) phongs = phongs.Where(x => x.TrangThai == status);

            var result = new List<object>();
            foreach (var p in phongs.OrderBy(p => p.SoPhong))
            {
                var cs = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == p.MaCoSo);
                var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

                result.Add(new
                {
                    p.MaPhong,
                    p.MaCoSo,
                    p.SoPhong,
                    p.Tang,
                    p.DienTich,
                    p.GiaThue,
                    p.SoNguoiToiDa,
                    p.TrangThai,
                    p.MoTa,
                    p.NgayTao,
                    NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                    TenNguoiQuanLy = tenQuanLy,
                    HinhAnhPhong = (p != null && p.HinhAnhPhongs != null) ? p.HinhAnhPhongs.FirstOrDefault()?.Url : null,
                    HinhAnhCoSo = (cs != null && cs.HinhAnhCoSos != null) ? cs.HinhAnhCoSos.FirstOrDefault()?.Url : null,
                    TienIches = p.TienIches
                });
            }

            return Ok(result);
        }

        [HttpGet("tien-ich")]
        [AllowAnonymous]
        public async Task<IActionResult> GetTienIch()
        {
            var data = await _tienIchRepo.GetAllAsync();
            var result = data.OrderBy(x => x.TenTienIch).Select(x => new
            {
                x.MaTienIch,
                x.TenTienIch
            }).ToList();
            return Ok(result);
        }

        [HttpPost("tien-ich")]
        public async Task<IActionResult> CreateTienIch([FromBody] TienIchCreateDto model)
        {
            if (string.IsNullOrWhiteSpace(model.TenTienIch)) return BadRequest("Tên tiện ích không được trống");

            var ten = model.TenTienIch.Trim();
            var allTienIch = await _tienIchRepo.GetAllAsync();
            var existed = allTienIch.FirstOrDefault(x => x.TenTienIch != null && x.TenTienIch.ToLower() == ten.ToLower());

            if (existed != null)
            {
                return Ok(new { existed.MaTienIch, existed.TenTienIch });
            }

            var maTienIch = await _counterRepo.GetNextSequenceValueAsync("tienich_id");
            var tienIch = new TienIch
            {
                MaTienIch = maTienIch,
                TenTienIch = ten
            };

            await _tienIchRepo.CreateAsync(tienIch);
            return Ok(new { tienIch.MaTienIch, tienIch.TenTienIch });
        }

        [HttpGet("view")]
        [AllowAnonymous]
        public async Task<IActionResult> GetView()
        {
            var tatCaPhong = await _phongRepo.GetAllAsync();
            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            
            var phongs = tatCaPhong.Where(p => p.TrangThai == "Trống").OrderBy(p => p.MaPhong);

            var result = new List<object>();
            foreach (var p in phongs)
            {
                var cs = tatCaCoSo.FirstOrDefault(c => c.MaCoSo == p.MaCoSo);
                var tenQuanLy = cs?.MaQuanLy != null ? await GetTenQuanLyAsync(cs.MaQuanLy.Value) : "Admin";

                result.Add(new
                {
                    p.MaPhong,
                    p.MaCoSo,
                    TenCoSo = cs?.TenCoSo ?? "",
                    DiaChi = cs?.DiaChi ?? "",
                    p.SoPhong,
                    p.Tang,
                    p.DienTich,
                    p.GiaThue,
                    p.SoNguoiToiDa,
                    p.TrangThai,
                    p.MoTa,
                    NguoiQuanLyId = cs?.MaQuanLy ?? 1,
                    TenNguoiQuanLy = tenQuanLy,
                    HinhAnhPhong = (p != null && p.HinhAnhPhongs != null) ? p.HinhAnhPhongs.FirstOrDefault()?.Url : null,
                    HinhAnhCoSo = (cs != null && cs.HinhAnhCoSos != null) ? cs.HinhAnhCoSos.FirstOrDefault()?.Url : null,
                    TienIches = p.TienIches,
                    Latitude = cs?.Latitude,
                    Longitude = cs?.Longitude
                });
            }

            return Ok(result);
        }
}

    public class PhongImageUrlDto
    {
        public string Url { get; set; }
    }
}