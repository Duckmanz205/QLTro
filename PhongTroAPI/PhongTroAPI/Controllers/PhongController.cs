using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PhongController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public PhongController(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // GET ALL thông tin

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll([FromQuery] int? maQuanLy)
        {
            var query = _context.Phongs.AsNoTracking().AsQueryable();

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLyToken))
            {
                query = query.Where(p => p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLyToken);
            }
            else if (maQuanLy.HasValue)
            {
                query = query.Where(p => p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLy.Value);
            }

            var data = await query
                .OrderBy(p => p.SoPhong)
                .Select(p => new
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
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",
                    TenCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.TenCoSo)
                        .FirstOrDefault() ?? "",
                    HinhAnhPhong = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .Select(h => h.UrlAnh)
                        .FirstOrDefault(),

                    HinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == p.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),
                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .ToListAsync();

            return Ok(data);
        }

        //  GET DETAIL

        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDetail(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.Phongs.AnyAsync(p => p.MaPhong == id && p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var data = await _context.Phongs
                .AsNoTracking()
                .Where(p => p.MaPhong == id)
                .Select(p => new
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
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",
                    HinhAnhPhong = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .Select(h => h.UrlAnh)
                        .FirstOrDefault(),

                    HinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == p.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),
                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .FirstOrDefaultAsync();

            return data == null ? NotFound("Không tìm thấy phòng") : Ok(data);
        }

        //  GET ROOM LIST BY COSO + SEARCH 

        [HttpGet("coso/{maCoSo}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByCoSo(
            int maCoSo,
            [FromQuery] string? keyword,
            [FromQuery] string? status)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.CoSos.AnyAsync(cs => cs.MaCoSo == maCoSo && cs.MaQuanLy == maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var query = _context.Phongs
                .AsNoTracking()
                .Where(p => p.MaCoSo == maCoSo);

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                keyword = keyword.Trim();

                query = query.Where(p =>
                    p.SoPhong.Contains(keyword) ||
                    (p.MoTa != null && p.MoTa.Contains(keyword)) ||
                    p.TrangThai.Contains(keyword) ||
                    p.MaTienIches.Any(t => t.TenTienIch != null && t.TenTienIch.Contains(keyword)));
            }

            if (!string.IsNullOrWhiteSpace(status) && status != "Tất cả")
            {
                query = query.Where(p => p.TrangThai == status);
            }

            var data = await query
                .OrderBy(p => p.SoPhong)
                .Select(p => new
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
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",

                    TenCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.TenCoSo)
                        .FirstOrDefault(),

                    DiaChiCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.DiaChi)
                        .FirstOrDefault(),

                    HinhAnhPhong = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .Select(h => h.UrlAnh)
                        .FirstOrDefault(),

                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .ToListAsync();

            return Ok(data);
        }

        // GET PHONG TRONG 

        [HttpGet("trong")]
        [AllowAnonymous]
        public async Task<IActionResult> GetPhongTrong([FromQuery] int? maQuanLy)
        {
            var query = _context.Phongs.AsNoTracking().AsQueryable();

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLyToken))
            {
                query = query.Where(p => p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLyToken);
            }
            else if (maQuanLy.HasValue)
            {
                query = query.Where(p => p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLy.Value);
            }

            var data = await query
                .Where(x => x.TrangThai == "Trống")
                .OrderBy(p => p.SoPhong)
                .Select(p => new
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
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",
                    TenCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.TenCoSo)
                        .FirstOrDefault() ?? "",
                    HinhAnhPhong = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .Select(h => h.UrlAnh)
                        .FirstOrDefault(),

                    HinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == p.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),
                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .ToListAsync();

            return Ok(data);
        }

        //  GET DETAIL FULL 

        [HttpGet("detail/{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDetailFull(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.Phongs.AnyAsync(p => p.MaPhong == id && p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var data = await _context.Phongs
                .AsNoTracking()
                .Where(p => p.MaPhong == id)
                .Select(p => new
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
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",

                    TenCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.TenCoSo)
                        .FirstOrDefault(),

                    DiaChiCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.DiaChi)
                        .FirstOrDefault(),

                    HinhAnhPhongs = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .Select(h => h.UrlAnh)
                        .ToList(),

                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .FirstOrDefaultAsync();

            if (data == null)
                return NotFound("Không tìm thấy phòng");

            return Ok(data);
        }

        //  CREATE

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] PhongUpsertDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrWhiteSpace(model.SoPhong))
                return BadRequest("Số phòng không được trống");

            if (model.GiaThue <= 0)
                return BadRequest("Giá thuê phải > 0");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var coSo = await _context.CoSos.FindAsync(model.MaCoSo);
            if (coSo == null)
                return BadRequest("Mã cơ sở không tồn tại");

            if (coSo.MaQuanLy != maQuanLy)
            {
                return Forbid("Cơ sở không thuộc quyền quản lý của bạn.");
            }

            var soPhongTrim = model.SoPhong.Trim();

            var isExist = await _context.Phongs
                .AnyAsync(p => p.MaCoSo == model.MaCoSo && p.SoPhong == soPhongTrim);

            if (isExist)
                return BadRequest("Số phòng đã tồn tại trong cơ sở này");

            var phong = new Phong
            {
                MaCoSo = model.MaCoSo,
                SoPhong = soPhongTrim,
                Tang = model.Tang,
                DienTich = model.DienTich,
                GiaThue = model.GiaThue,
                SoNguoiToiDa = model.SoNguoiToiDa,
                TrangThai = model.TrangThai,
                MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim()
            };

            if (model.MaTienIchIds.Any())
            {
                var tienIchList = await _context.TienIches
                    .Where(x => model.MaTienIchIds.Contains(x.MaTienIch))
                    .ToListAsync();

                foreach (var item in tienIchList)
                {
                    phong.MaTienIches.Add(item);
                }
            }

            _context.Phongs.Add(phong);
            await _context.SaveChangesAsync();

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
                TienIches = phong.MaTienIches
                    .OrderBy(t => t.TenTienIch)
                    .Select(t => t.TenTienIch)
                    .ToList()
            });
        }

        //  UPDATE 

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] PhongUpsertDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var phong = await _context.Phongs
                .Include(p => p.MaTienIches)
                .Include(p => p.MaCoSoNavigation)
                .FirstOrDefaultAsync(p => p.MaPhong == id);

            if (phong == null)
                return NotFound("Không tìm thấy phòng");

            if (phong.MaCoSoNavigation == null || phong.MaCoSoNavigation.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            var targetCoSo = await _context.CoSos.FindAsync(model.MaCoSo);
            if (targetCoSo == null)
            {
                return BadRequest("Cơ sở đích không tồn tại");
            }

            if (targetCoSo.MaQuanLy != maQuanLy)
            {
                return Forbid("Cơ sở đích không thuộc quyền quản lý của bạn.");
            }

            if (model.GiaThue <= 0)
                return BadRequest("Giá thuê không hợp lệ");

            var soPhongTrim = model.SoPhong.Trim();

            var isDuplicate = await _context.Phongs
                .AnyAsync(p =>
                    p.MaPhong != id &&
                    p.MaCoSo == model.MaCoSo &&
                    p.SoPhong == soPhongTrim);

            if (isDuplicate)
                return BadRequest("Số phòng đã tồn tại trong cơ sở này");

            phong.MaCoSo = model.MaCoSo;
            phong.SoPhong = soPhongTrim;
            phong.Tang = model.Tang;
            phong.DienTich = model.DienTich;
            phong.GiaThue = model.GiaThue;
            phong.SoNguoiToiDa = model.SoNguoiToiDa;
            phong.TrangThai = model.TrangThai;
            phong.MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim();

            phong.MaTienIches.Clear();

            if (model.MaTienIchIds.Any())
            {
                var tienIchList = await _context.TienIches
                    .Where(x => model.MaTienIchIds.Contains(x.MaTienIch))
                    .ToListAsync();

                foreach (var item in tienIchList)
                {
                    phong.MaTienIches.Add(item);
                }
            }

            await _context.SaveChangesAsync();

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
                TienIches = phong.MaTienIches
                    .OrderBy(t => t.TenTienIch)
                    .Select(t => t.TenTienIch)
                    .ToList()
            });
        }

        //  UPLOAD / REPLACE ảnh phòng 

        [HttpPost("{id}/image")]
        public async Task<IActionResult> UploadOrReplaceImage(int id, IFormFile file)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var phong = await _context.Phongs.Include(p => p.MaCoSoNavigation).FirstOrDefaultAsync(p => p.MaPhong == id);
            if (phong == null)
                return NotFound("Không tìm thấy phòng");

            if (phong.MaCoSoNavigation == null || phong.MaCoSoNavigation.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            if (file == null || file.Length == 0)
                return BadRequest("File ảnh không hợp lệ");

            var folder = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "uploads",
                "phong"
            );

            Directory.CreateDirectory(folder);

            var oldImages = await _context.Set<HinhAnhPhong>()
                .Where(x => x.MaPhong == id)
                .ToListAsync();

            foreach (var old in oldImages)
            {
                if (string.IsNullOrWhiteSpace(old.UrlAnh)) continue;

                if (old.UrlAnh.Contains("/uploads/phong/"))
                {
                    string? fileName = null;

                    if (Uri.TryCreate(old.UrlAnh, UriKind.Absolute, out var uri))
                    {
                        fileName = Path.GetFileName(uri.LocalPath);
                    }
                    else
                    {
                        fileName = Path.GetFileName(old.UrlAnh);
                    }

                    if (!string.IsNullOrWhiteSpace(fileName))
                    {
                        var oldPath = Path.Combine(folder, fileName);

                        if (System.IO.File.Exists(oldPath))
                        {
                            System.IO.File.Delete(oldPath);
                        }
                    }
                }
            }

            _context.Set<HinhAnhPhong>().RemoveRange(oldImages);

            var extension = Path.GetExtension(file.FileName);
            var originalName = Path.GetFileNameWithoutExtension(file.FileName)
                .Replace(" ", "_");
            var fileNameNew = $"{originalName}_{Guid.NewGuid():N}{extension}";
            var filePath = Path.Combine(folder, fileNameNew);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var imageUrl = $"{Request.Scheme}://{Request.Host}/uploads/phong/{fileNameNew}";

            var image = new HinhAnhPhong
            {
                MaPhong = id,
                UrlAnh = imageUrl
            };

            _context.Set<HinhAnhPhong>().Add(image);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                image.MaAnh,
                image.MaPhong,
                image.UrlAnh
            });
        }

        //  DELETE  phòng

        //  DELETE 
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var data = await _context.Phongs
                .Include(p => p.MaTienIches)
                .Include(p => p.MaCoSoNavigation)
                .FirstOrDefaultAsync(p => p.MaPhong == id);

            if (data == null)
                return NotFound("Không tìm thấy phòng");

            if (data.MaCoSoNavigation == null || data.MaCoSoNavigation.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            var images = await _context.HinhAnhPhongs
                .Where(x => x.MaPhong == id)
                .ToListAsync();

            data.MaTienIches.Clear();

            _context.HinhAnhPhongs.RemoveRange(images);
            _context.Phongs.Remove(data);

            await _context.SaveChangesAsync();

            return Ok("Đã xóa phòng");
        }

        // lọc

        [HttpGet("filter")]
        [AllowAnonymous]
        public async Task<IActionResult> Filter(decimal? min, decimal? max, string? status)
        {
            var query = _context.Phongs.AsNoTracking().AsQueryable();

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                query = query.Where(p => p.MaCoSoNavigation != null && p.MaCoSoNavigation.MaQuanLy == maQuanLy);
            }

            if (min.HasValue)
                query = query.Where(x => x.GiaThue >= min.Value);

            if (max.HasValue)
                query = query.Where(x => x.GiaThue <= max.Value);

            if (!string.IsNullOrEmpty(status))
                query = query.Where(x => x.TrangThai == status);

            var data = await query
                .OrderBy(p => p.SoPhong)
                .Select(p => new
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
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",
                    HinhAnhPhong = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .Select(h => h.UrlAnh)
                        .FirstOrDefault(),

                    HinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == p.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),
                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .ToListAsync();

            return Ok(data);
        }

        //  TIEN ICH 
        [HttpGet("tien-ich")]
        [AllowAnonymous]
        public async Task<IActionResult> GetTienIch()
        {
            var data = await _context.TienIches
                .AsNoTracking()
                .OrderBy(x => x.TenTienIch)
                .Select(x => new
                {
                    x.MaTienIch,
                    x.TenTienIch
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpPost("tien-ich")]
        public async Task<IActionResult> CreateTienIch([FromBody] TienIchCreateDto model)
        {
            if (string.IsNullOrWhiteSpace(model.TenTienIch))
                return BadRequest("Tên tiện ích không được trống");

            var ten = model.TenTienIch.Trim();

            var existed = await _context.TienIches
                .FirstOrDefaultAsync(x => x.TenTienIch != null && x.TenTienIch.ToLower() == ten.ToLower());

            if (existed != null)
            {
                return Ok(new
                {
                    existed.MaTienIch,
                    existed.TenTienIch
                });
            }

            var tienIch = new TienIch
            {
                TenTienIch = ten
            };

            _context.TienIches.Add(tienIch);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                tienIch.MaTienIch,
                tienIch.TenTienIch
            });
        }
        //view cho trang tra cuu
        [HttpGet("view")]
        [AllowAnonymous]
        public async Task<IActionResult> GetView()
        {
            var data = await _context.Phongs
                .AsNoTracking()
                .Where(p => p.TrangThai == "Trống")
                .OrderBy(p => p.MaPhong)
                .Select(p => new
                {
                    p.MaPhong,
                    p.MaCoSo,
                    TenCoSo = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.TenCoSo)
                        .FirstOrDefault() ?? "",

                    DiaChi = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.DiaChi)
                        .FirstOrDefault() ?? "",

                    p.SoPhong,
                    p.Tang,
                    p.DienTich,
                    p.GiaThue,
                    p.SoNguoiToiDa,
                    p.TrangThai,
                    p.MoTa,
                    NguoiQuanLyId = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo).Select(cs => cs.MaQuanLy).FirstOrDefault() ?? 1,
                    TenNguoiQuanLy = _context.CoSos.Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => _context.NguoiQuanLies.Where(n => n.MaQuanLy == cs.MaQuanLy).Select(n => n.HoTen).FirstOrDefault())
                        .FirstOrDefault() ?? "Admin",

                    HinhAnhPhong = _context.Set<HinhAnhPhong>()
                        .Where(h => h.MaPhong == p.MaPhong)
                        .OrderBy(h => h.MaAnh)
                        .Select(h => h.UrlAnh)
                        .FirstOrDefault(),

                    HinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == p.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),

                    TienIches = p.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch!)
                        .ToList(),
                    Latitude = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.Latitude)
                        .FirstOrDefault(),

                    Longitude = _context.CoSos
                        .Where(cs => cs.MaCoSo == p.MaCoSo)
                        .Select(cs => cs.Longitude)
                        .FirstOrDefault(),

                })
                .ToListAsync();

            return Ok(data);
        }

        // POST: thêm ảnh cho 1 phòng qua URL (Supabase)
        [HttpPost("{id}/image/url")]
        public async Task<IActionResult> UploadImageUrl(int id, [FromBody] PhongImageUrlDto dto)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var phong = await _context.Phongs.Include(p => p.MaCoSoNavigation).FirstOrDefaultAsync(p => p.MaPhong == id);
            if (phong == null)
                return NotFound("Không tìm thấy phòng");

            if (phong.MaCoSoNavigation == null || phong.MaCoSoNavigation.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            if (dto == null || string.IsNullOrWhiteSpace(dto.Url))
                return BadRequest("URL ảnh không hợp lệ");

            // Xóa hết ảnh cũ của phòng
            var oldImages = await _context.Set<HinhAnhPhong>()
                .Where(x => x.MaPhong == id)
                .ToListAsync();
            _context.Set<HinhAnhPhong>().RemoveRange(oldImages);

            var image = new HinhAnhPhong
            {
                MaPhong = id,
                UrlAnh = dto.Url.Trim()
            };

            _context.Set<HinhAnhPhong>().Add(image);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                image.MaAnh,
                image.MaPhong,
                image.UrlAnh
            });
        }
    }

    public class PhongImageUrlDto
    {
        public string Url { get; set; } = string.Empty;
    }
}