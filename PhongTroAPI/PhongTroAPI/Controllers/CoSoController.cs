using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Entities.Embedded;
using Microsoft.AspNetCore.Authorization;
using System.Threading.Tasks;
using System.Linq;
using System;
using System.IO;
using System.Collections.Generic;
using PhongTroAPI.Repositories.Mongo;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CoSoController : ControllerBase
    {
        private readonly CoSoRepository _coSoRepo;
        private readonly PhongRepository _phongRepo;
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly TienIchRepository _tienIchRepo;
        private readonly CounterRepository _counterRepo;

        public CoSoController(
            CoSoRepository coSoRepo,
            PhongRepository phongRepo,
            NguoiQuanLyRepository quanLyRepo,
            TienIchRepository tienIchRepo,
            CounterRepository counterRepo)
        {
            _coSoRepo = coSoRepo;
            _phongRepo = phongRepo;
            _quanLyRepo = quanLyRepo;
            _tienIchRepo = tienIchRepo;
            _counterRepo = counterRepo;
        }

        // GET: danh sách cơ sở
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var coSos = await _coSoRepo.GetAllAsync();
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                coSos = coSos.Where(cs => cs.MaQuanLy == maQuanLy).ToList();
            }
            return Ok(coSos);
        }

        // GET: chi tiết cơ sở + phòng + ảnh + quản lý + bản đồ
        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDetail(int id)
        {
            var cs = await _coSoRepo.GetByIdAsync(id);
            if (cs == null) return NotFound("Không tìm thấy cơ sở");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (cs.MaQuanLy != maQuanLy)
                {
                    return Forbid("Bạn không có quyền truy cập cơ sở này.");
                }
            }

            var phongs = await _phongRepo.GetAllAsync();
            var coSoPhongs = phongs.Where(p => p.MaCoSo == id).ToList();
            
            var quanLy = cs.MaQuanLy.HasValue ? await _quanLyRepo.GetByIdAsync(cs.MaQuanLy.Value) : null;

            var hinhAnhChinh = cs.HinhAnhCoSos
                .OrderByDescending(x => x.IsMain)
                .ThenBy(x => x.MaAnh)
                .Select(x => x.UrlAnh)
                .FirstOrDefault();

            var data = new
            {
                maCoSo = cs.MaCoSo,
                tenCoSo = cs.TenCoSo,
                diaChi = cs.DiaChi,
                loaiHinh = cs.LoaiHinh,
                maQuanLy = cs.MaQuanLy,
                moTa = cs.MoTa,
                latitude = cs.Latitude,
                longitude = cs.Longitude,
                donGiaDien = cs.DonGiaDien,
                donGiaNuoc = cs.DonGiaNuoc,

                tenQuanLy = quanLy?.HoTen,
                soDienThoaiQuanLy = quanLy?.Sdt,
                emailQuanLy = quanLy?.Email,

                hinhAnhCoSo = hinhAnhChinh,

                tongPhong = coSoPhongs.Count,
                phongTrong = coSoPhongs.Count(p => p.TrangThai == "Trống"),
                daThue = coSoPhongs.Count(p => p.TrangThai == "Đang thuê"),

                tienIches = cs.TienIches
                    .OrderBy(t => t.TenTienIch)
                    .Select(t => new
                    {
                        maTienIch = t.MaTienIch,
                        tenTienIch = t.TenTienIch
                    })
                    .ToList(),

                phongs = coSoPhongs
                    .OrderBy(p => p.SoPhong)
                    .Select(p => new
                    {
                        maPhong = p.MaPhong,
                        soPhong = p.SoPhong,
                        trangThai = p.TrangThai
                    })
                    .ToList()
            };

            return Ok(data);
        }

        // GET: phòng theo cơ sở
        [HttpGet("{id}/phong")]
        [AllowAnonymous]
        public async Task<IActionResult> GetPhongByCoSo(int id)
        {
            var cs = await _coSoRepo.GetByIdAsync(id);
            if (cs == null) return NotFound("Không tìm thấy cơ sở");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (cs.MaQuanLy != maQuanLy) return Forbid();
            }

            var phongs = await _phongRepo.GetAllAsync();
            var data = phongs.Where(p => p.MaCoSo == id).ToList();

            return Ok(data);
        }

        [HttpGet("managers")]
        public async Task<IActionResult> GetManagers()
        {
            var allQuanLy = await _quanLyRepo.GetAllAsync();
            var allCoSo = await _coSoRepo.GetAllAsync();

            var data = allQuanLy
                .Select(ql => new
                {
                    MaQuanLy = ql.MaQuanLy,
                    TenQuanLy = ql.HoTen,
                    SoDienThoai = ql.Sdt,
                    Email = ql.Email,
                    SoCoSo = allCoSo.Count(cs => cs.MaQuanLy == ql.MaQuanLy)
                })
                .Where(x => x.SoCoSo > 0)
                .OrderBy(x => x.MaQuanLy)
                .ToList();

            return Ok(data);
        }

        [HttpGet("dashboard")]
        public async Task<IActionResult> Dashboard()
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var tatCaCoSo = await _coSoRepo.GetAllAsync();
            var coSos = tatCaCoSo.Where(cs => cs.MaQuanLy == maQuanLy).ToList();
            var tatCaPhong = await _phongRepo.GetAllAsync();

            var data = new List<object>();

            foreach (var cs in coSos)
            {
                var phongs = tatCaPhong.Where(p => p.MaCoSo == cs.MaCoSo).ToList();
                var hinhAnhChinh = cs.HinhAnhCoSos
                    .OrderByDescending(x => x.IsMain)
                    .ThenBy(x => x.MaAnh)
                    .Select(x => x.UrlAnh)
                    .FirstOrDefault();

                data.Add(new
                {
                    maCoSo = cs.MaCoSo,
                    tenCoSo = cs.TenCoSo,
                    diaChi = cs.DiaChi,
                    status = string.IsNullOrWhiteSpace(cs.TrangThai) ? "Hoạt động" : cs.TrangThai,
                    tongPhong = phongs.Count,
                    phongTrong = phongs.Count(p => p.TrangThai == "Trống"),
                    dangThue = phongs.Count(p => p.TrangThai == "Đang thuê"),
                    baoTri = phongs.Count(p => p.TrangThai == "Bảo trì"),
                    tongDoanhThu = phongs.Where(p => p.TrangThai == "Đang thuê").Sum(p => (decimal?)p.GiaThue) ?? 0,
                    hinhAnhCoSo = hinhAnhChinh,
                    tienIches = cs.TienIches.OrderBy(t => t.TenTienIch).Select(t => t.TenTienIch).ToList()
                });
            }

            return Ok(data);
        }

        [HttpPost]
        public async Task<IActionResult> Create(CoSoUpsertDto model)
        {
            if (string.IsNullOrWhiteSpace(model.TenCoSo))
                return BadRequest("Tên cơ sở không được trống");

            if (string.IsNullOrWhiteSpace(model.DiaChi))
                return BadRequest("Địa chỉ không được trống");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var maCoSo = await _counterRepo.GetNextSequenceValueAsync("coso_id");

            var coSo = new CoSo
            {
                MaCoSo = maCoSo,
                TenCoSo = model.TenCoSo.Trim(),
                DiaChi = model.DiaChi.Trim(),
                LoaiHinh = model.LoaiHinh,
                MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim(),
                MaQuanLy = maQuanLy,
                Latitude = model.Latitude,
                Longitude = model.Longitude,
                TienIches = new List<TienIchItem>()
            };

            if (model.MaTienIchIds != null && model.MaTienIchIds.Any())
            {
                var allTienIch = await _tienIchRepo.GetAllAsync();
                var tienIchList = allTienIch.Where(x => model.MaTienIchIds.Contains(x.MaTienIch)).ToList();

                foreach (var item in tienIchList)
                {
                    coSo.TienIches.Add(new TienIchItem { MaTienIch = item.MaTienIch, TenTienIch = item.TenTienIch });
                }
            }

            await _coSoRepo.CreateAsync(coSo);

            return Ok(new { coSo.MaCoSo, coSo.TenCoSo });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, CoSoUpsertDto model)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var coSo = await _coSoRepo.GetByIdAsync(id);
            if (coSo == null) return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy) return Forbid();

            coSo.TenCoSo = model.TenCoSo.Trim();
            coSo.DiaChi = model.DiaChi.Trim();
            coSo.LoaiHinh = model.LoaiHinh;
            coSo.MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim();
            coSo.Latitude = model.Latitude;
            coSo.Longitude = model.Longitude;

            coSo.TienIches.Clear();

            if (model.MaTienIchIds != null && model.MaTienIchIds.Any())
            {
                var allTienIch = await _tienIchRepo.GetAllAsync();
                var tienIchList = allTienIch.Where(x => model.MaTienIchIds.Contains(x.MaTienIch)).ToList();

                foreach (var item in tienIchList)
                {
                    coSo.TienIches.Add(new TienIchItem { MaTienIch = item.MaTienIch, TenTienIch = item.TenTienIch });
                }
            }

            await _coSoRepo.UpdateAsync(id, coSo);

            return Ok(new
            {
                maCoSo = coSo.MaCoSo,
                tenCoSo = coSo.TenCoSo,
                diaChi = coSo.DiaChi,
                loaiHinh = coSo.LoaiHinh,
                moTa = coSo.MoTa,
                maQuanLy = coSo.MaQuanLy,
                latitude = coSo.Latitude,
                longitude = coSo.Longitude,
                maTienIchIds = coSo.TienIches.Select(x => x.MaTienIch).ToList()
            });
        }

        [HttpGet("{id}/images")]
        [AllowAnonymous]
        public async Task<IActionResult> GetImages(int id)
        {
            var coSo = await _coSoRepo.GetByIdAsync(id);
            if (coSo == null) return NotFound("Không tìm thấy cơ sở");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                if (coSo.MaQuanLy != maQuanLy) return Forbid();
            }

            var data = coSo.HinhAnhCoSos
                .OrderByDescending(x => x.IsMain)
                .ThenBy(x => x.MaAnh)
                .Select(x => new
                {
                    x.MaAnh,
                    MaCoSo = id,
                    x.UrlAnh,
                    x.IsMain
                })
                .ToList();

            return Ok(data);
        }

        [HttpPost("{id}/images")]
        public async Task<IActionResult> UploadImage(int id, IFormFile file)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coSo = await _coSoRepo.GetByIdAsync(id);
            if (coSo == null) return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy) return Forbid();

            if (file == null || file.Length == 0) return BadRequest("File ảnh không hợp lệ");

            var folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "co_so");
            Directory.CreateDirectory(folder);

            var extension = Path.GetExtension(file.FileName);
            var fileName = $"{Guid.NewGuid():N}{extension}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var hasMain = coSo.HinhAnhCoSos.Any(x => x.IsMain);
            var imageUrl = $"{Request.Scheme}://{Request.Host}/uploads/co_so/{fileName}";
            var newMaAnh = await _counterRepo.GetNextSequenceValueAsync("hinhanhcoso_id");

            var image = new HinhAnhItem
            {
                MaAnh = newMaAnh,
                UrlAnh = imageUrl,
                IsMain = !hasMain
            };

            coSo.HinhAnhCoSos.Add(image);
            await _coSoRepo.UpdateAsync(id, coSo);

            return Ok(new
            {
                image.MaAnh,
                MaCoSo = id,
                image.UrlAnh,
                image.IsMain
            });
        }

        [HttpPost("{id}/images/url")]
        public async Task<IActionResult> UploadImageUrl(int id, [FromBody] CoSoImageUrlDto dto)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coSo = await _coSoRepo.GetByIdAsync(id);
            if (coSo == null) return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy) return Forbid();

            if (dto == null || string.IsNullOrWhiteSpace(dto.Url)) return BadRequest("URL ảnh không hợp lệ");

            var hasMain = coSo.HinhAnhCoSos.Any(x => x.IsMain);
            var newMaAnh = await _counterRepo.GetNextSequenceValueAsync("hinhanhcoso_id");

            var image = new HinhAnhItem
            {
                MaAnh = newMaAnh,
                UrlAnh = dto.Url.Trim(),
                IsMain = !hasMain
            };

            coSo.HinhAnhCoSos.Add(image);
            await _coSoRepo.UpdateAsync(id, coSo);

            return Ok(new
            {
                image.MaAnh,
                MaCoSo = id,
                image.UrlAnh,
                image.IsMain
            });
        }

        [HttpPut("images/{maAnh}/set-main")]
        public async Task<IActionResult> SetMainImage(int maAnh)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var allCoSo = await _coSoRepo.GetAllAsync();
            var coSo = allCoSo.FirstOrDefault(cs => cs.HinhAnhCoSos.Any(img => img.MaAnh == maAnh));

            if (coSo == null) return NotFound("Không tìm thấy ảnh");
            if (coSo.MaQuanLy != maQuanLy) return Forbid();

            foreach (var img in coSo.HinhAnhCoSos)
            {
                img.IsMain = img.MaAnh == maAnh;
            }

            await _coSoRepo.UpdateAsync(coSo.MaCoSo, coSo);
            return Ok("Đã cập nhật ảnh hiển thị chính");
        }

        [HttpDelete("images/{maAnh}")]
        public async Task<IActionResult> DeleteImage(int maAnh)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var allCoSo = await _coSoRepo.GetAllAsync();
            var coSo = allCoSo.FirstOrDefault(cs => cs.HinhAnhCoSos.Any(img => img.MaAnh == maAnh));

            if (coSo == null) return NotFound("Không tìm thấy ảnh");
            if (coSo.MaQuanLy != maQuanLy) return Forbid();

            var image = coSo.HinhAnhCoSos.First(img => img.MaAnh == maAnh);
            var wasMain = image.IsMain;
            var imageUrl = image.UrlAnh;

            coSo.HinhAnhCoSos.Remove(image);

            if (wasMain)
            {
                var nextImage = coSo.HinhAnhCoSos.OrderBy(x => x.MaAnh).FirstOrDefault();
                if (nextImage != null)
                {
                    nextImage.IsMain = true;
                }
            }

            await _coSoRepo.UpdateAsync(coSo.MaCoSo, coSo);

            if (!string.IsNullOrWhiteSpace(imageUrl))
            {
                try
                {
                    var uri = new Uri(imageUrl);
                    var relativePath = uri.AbsolutePath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    var actualPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "co_so", Path.GetFileName(relativePath));

                    if (System.IO.File.Exists(actualPath))
                    {
                        System.IO.File.Delete(actualPath);
                    }
                }
                catch { }
            }

            return Ok("Đã xóa ảnh");
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coSo = await _coSoRepo.GetByIdAsync(id);
            if (coSo == null) return NotFound("Không tìm thấy cơ sở");
            if (coSo.MaQuanLy != maQuanLy) return Forbid();

            var tatCaPhong = await _phongRepo.GetAllAsync();
            var phongs = tatCaPhong.Where(p => p.MaCoSo == id).ToList();

            foreach (var p in phongs)
            {
                await _phongRepo.DeleteAsync(p.MaPhong);
            }

            await _coSoRepo.DeleteAsync(id);

            return Ok("Đã xóa cơ sở");
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
            if (string.IsNullOrWhiteSpace(model.TenTienIch))
                return BadRequest("Tên tiện ích không được trống");

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

        [HttpPatch("{id}/utility-prices")]
        public async Task<IActionResult> UpdateUtilityPrices(int id, [FromBody] PhongTroAPI.DTOs.UpdateUtilityPricesDto dto)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coso = await _coSoRepo.GetByIdAsync(id);
            if (coso == null) return NotFound("Không tìm thấy cơ sở");
            if (coso.MaQuanLy != maQuanLy) return Forbid();

            coso.DonGiaDien = dto.DonGiaDien;
            coso.DonGiaNuoc = dto.DonGiaNuoc;
            await _coSoRepo.UpdateAsync(id, coso);

            return Ok(new { message = "Cập nhật đơn giá thành công", donGiaDien = coso.DonGiaDien, donGiaNuoc = coso.DonGiaNuoc });
        }
    }

    public class CoSoImageUrlDto
    {
        public string Url { get; set; } = string.Empty;
    }
}