using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using Microsoft.AspNetCore.Authorization;


namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CoSoController : ControllerBase
    {
        private readonly QuanLyPhongTroContext _context;

        public CoSoController(QuanLyPhongTroContext context)
        {
            _context = context;
        }


        // GET: danh sách cơ sở
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var query = _context.CoSos.AsNoTracking().AsQueryable();

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                query = query.Where(cs => cs.MaQuanLy == maQuanLy);
            }

            var data = await query.ToListAsync();
            return Ok(data);
        }


        // GET: chi tiết cơ sở + phòng + ảnh + quản lý + bản đồ
        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDetail(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.CoSos.AnyAsync(cs => cs.MaCoSo == id && cs.MaQuanLy == maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid("Bạn không có quyền truy cập cơ sở này.");
                }
            }

            var data = await _context.CoSos
                .AsNoTracking()
                .Where(cs => cs.MaCoSo == id)
                .Select(cs => new
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

                    tenQuanLy = cs.MaQuanLyNavigation != null ? cs.MaQuanLyNavigation.HoTen : null,
                    soDienThoaiQuanLy = cs.MaQuanLyNavigation != null ? cs.MaQuanLyNavigation.Sdt : null,
                    emailQuanLy = cs.MaQuanLyNavigation != null ? cs.MaQuanLyNavigation.Email : null,

                    hinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == cs.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),

                    tongPhong = cs.Phongs.Count(),
                    phongTrong = cs.Phongs.Count(p => p.TrangThai == "Trống"),
                    daThue = cs.Phongs.Count(p => p.TrangThai == "Đang thuê"),

                    tienIches = cs.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => new
                        {
                            maTienIch = t.MaTienIch,
                            tenTienIch = t.TenTienIch
                        })
                        .ToList(),

                    phongs = cs.Phongs
                        .OrderBy(p => p.SoPhong)
                        .Select(p => new
                        {
                            maPhong = p.MaPhong,
                            soPhong = p.SoPhong,
                            trangThai = p.TrangThai
                        })
                        .ToList()
                })
                .FirstOrDefaultAsync();

            if (data == null)
                return NotFound("Không tìm thấy cơ sở");

            return Ok(data);
        }

        // GET: phòng theo cơ sở
        [HttpGet("{id}/phong")]
        [AllowAnonymous]
        public async Task<IActionResult> GetPhongByCoSo(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongsToAdmin = await _context.CoSos.AnyAsync(cs => cs.MaCoSo == id && cs.MaQuanLy == maQuanLy);
                if (!belongsToAdmin)
                {
                    return Forbid();
                }
            }

            var data = await _context.Phongs
                .Where(p => p.MaCoSo == id)
                .ToListAsync();

            return Ok(data);
        }


        // GET: thống kê cơ sở_DASHBOARD
        //quản lý

        [HttpGet("managers")]
        public async Task<IActionResult> GetManagers()
        {
            var data = await _context.Set<NguoiQuanLy>()
                .AsNoTracking()
                .Where(ql => ql.CoSos.Any())
                .Select(ql => new
                {
                    ql.MaQuanLy,
                    TenQuanLy = ql.HoTen,
                    SoDienThoai = ql.Sdt,
                    ql.Email,
                    SoCoSo = ql.CoSos.Count
                })
                .OrderBy(x => x.MaQuanLy)
                .ToListAsync();

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

            var query = _context.CoSos.AsQueryable().Where(cs => cs.MaQuanLy == maQuanLy);

            var data = await query
                .AsNoTracking()
                .Select(cs => new
                {
                    maCoSo = cs.MaCoSo,
                    tenCoSo = cs.TenCoSo,
                    diaChi = cs.DiaChi,

                    status = string.IsNullOrWhiteSpace(cs.TrangThai)
                        ? "Hoạt động"
                        : cs.TrangThai,

                    tongPhong = cs.Phongs.Count(),
                    phongTrong = cs.Phongs.Count(p => p.TrangThai == "Trống"),
                    dangThue = cs.Phongs.Count(p => p.TrangThai == "Đang thuê"),
                    baoTri = cs.Phongs.Count(p => p.TrangThai == "Bảo trì"),

                    tongDoanhThu = cs.Phongs
                        .Where(p => p.TrangThai == "Đang thuê")
                        .Sum(p => (decimal?)p.GiaThue) ?? 0,

                    hinhAnhCoSo = _context.HinhAnhCoSos
                        .Where(x => x.MaCoSo == cs.MaCoSo)
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.MaAnh)
                        .Select(x => x.UrlAnh)
                        .FirstOrDefault(),

                    tienIches = cs.MaTienIches
                        .OrderBy(t => t.TenTienIch)
                        .Select(t => t.TenTienIch)
                        .ToList()
                })
                .ToListAsync();

            return Ok(data);
        }

        // POST: tạo cơ sở

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

            var coSo = new CoSo
            {
                TenCoSo = model.TenCoSo.Trim(),
                DiaChi = model.DiaChi.Trim(),
                LoaiHinh = model.LoaiHinh,
                MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim(),
                MaQuanLy = maQuanLy,
                Latitude = model.Latitude,
                Longitude = model.Longitude
            };

            if (model.MaTienIchIds.Any())
            {
                var tienIchList = await _context.TienIches
                    .Where(x => model.MaTienIchIds.Contains(x.MaTienIch))
                    .ToListAsync();

                foreach (var item in tienIchList)
                {
                    coSo.MaTienIches.Add(item);
                }
            }

            _context.CoSos.Add(coSo);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                coSo.MaCoSo,
                coSo.TenCoSo
            });
        }

        // PUT: cập nhật cơ sở

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, CoSoUpsertDto model)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized("Không tìm thấy mã người quản lý hợp lệ trong token.");
            }

            var coSo = await _context.CoSos
                .Include(x => x.MaTienIches)
                .FirstOrDefaultAsync(x => x.MaCoSo == id);

            if (coSo == null)
                return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            coSo.TenCoSo = model.TenCoSo.Trim();
            coSo.DiaChi = model.DiaChi.Trim();
            coSo.LoaiHinh = model.LoaiHinh;
            coSo.MoTa = string.IsNullOrWhiteSpace(model.MoTa) ? null : model.MoTa.Trim();
            coSo.Latitude = model.Latitude;
            coSo.Longitude = model.Longitude;

            coSo.MaTienIches.Clear();

            if (model.MaTienIchIds.Any())
            {
                var tienIchList = await _context.TienIches
                    .Where(x => model.MaTienIchIds.Contains(x.MaTienIch))
                    .ToListAsync();

                foreach (var item in tienIchList)
                {
                    coSo.MaTienIches.Add(item);
                }
            }

            await _context.SaveChangesAsync();

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
                maTienIchIds = coSo.MaTienIches
                    .Select(x => x.MaTienIch)
                    .ToList()
            });
        }
        //lấy danh sách hình ảnh của 1 cơ sở theo id
        [HttpGet("{id}/images")]
        [AllowAnonymous]
        public async Task<IActionResult> GetImages(int id)
        {
            var exists = await _context.CoSos.AnyAsync(x => x.MaCoSo == id);
            if (!exists)
                return NotFound("Không tìm thấy cơ sở");

            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                var belongs = await _context.CoSos.AnyAsync(x => x.MaCoSo == id && x.MaQuanLy == maQuanLy);
                if (!belongs) return Forbid();
            }

            var data = await _context.Set<HinhAnhCoSo>()
                .Where(x => x.MaCoSo == id)
                .OrderByDescending(x => x.IsMain)
                .ThenBy(x => x.MaAnh)
                .Select(x => new
                {
                    x.MaAnh,
                    x.MaCoSo,
                    x.UrlAnh,
                    x.IsMain
                })
                .ToListAsync();

            return Ok(data);
        }
        //upload/thêm ảnh cho 1 cơ sở
        [HttpPost("{id}/images")]
        public async Task<IActionResult> UploadImage(int id, IFormFile file)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coSo = await _context.CoSos.FindAsync(id);
            if (coSo == null)
                return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            if (file == null || file.Length == 0)
                return BadRequest("File ảnh không hợp lệ");

            var folder = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "uploads",
                "co_so"
            );

            Directory.CreateDirectory(folder);

            var extension = Path.GetExtension(file.FileName);
            var fileName = $"{Guid.NewGuid():N}{extension}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var hasMain = await _context.Set<HinhAnhCoSo>()
                .AnyAsync(x => x.MaCoSo == id && x.IsMain);

            var imageUrl = $"{Request.Scheme}://{Request.Host}/uploads/co_so/{fileName}";

            var image = new HinhAnhCoSo
            {
                MaCoSo = id,
                UrlAnh = imageUrl,
                IsMain = !hasMain
            };

            _context.Set<HinhAnhCoSo>().Add(image);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                image.MaAnh,
                image.MaCoSo,
                image.UrlAnh,
                image.IsMain
            });
        }

        //upload/thêm ảnh cho 1 cơ sở qua URL
        [HttpPost("{id}/images/url")]
        public async Task<IActionResult> UploadImageUrl(int id, [FromBody] CoSoImageUrlDto dto)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coSo = await _context.CoSos.FindAsync(id);
            if (coSo == null)
                return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            if (dto == null || string.IsNullOrWhiteSpace(dto.Url))
                return BadRequest("URL ảnh không hợp lệ");

            var hasMain = await _context.Set<HinhAnhCoSo>()
                .AnyAsync(x => x.MaCoSo == id && x.IsMain);

            var image = new HinhAnhCoSo
            {
                MaCoSo = id,
                UrlAnh = dto.Url.Trim(),
                IsMain = !hasMain
            };

            _context.Set<HinhAnhCoSo>().Add(image);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                image.MaAnh,
                image.MaCoSo,
                image.UrlAnh,
                image.IsMain
            });
        }
        //đặt một ảnh thành ảnh đại diện của cơ sở.
        [HttpPut("images/{maAnh}/set-main")]
        public async Task<IActionResult> SetMainImage(int maAnh)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var image = await _context.Set<HinhAnhCoSo>().Include(x => x.MaCoSoNavigation).FirstOrDefaultAsync(x => x.MaAnh == maAnh);
            if (image == null)
                return NotFound("Không tìm thấy ảnh");

            if (image.MaCoSoNavigation == null || image.MaCoSoNavigation.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            var images = await _context.Set<HinhAnhCoSo>()
                .Where(x => x.MaCoSo == image.MaCoSo)
                .ToListAsync();

            foreach (var item in images)
            {
                item.IsMain = item.MaAnh == maAnh;
            }

            await _context.SaveChangesAsync();
            return Ok("Đã cập nhật ảnh hiển thị chính");
        }
        //xóa 1 ảnh của cơ sở.
        [HttpDelete("images/{maAnh}")]
        public async Task<IActionResult> DeleteImage(int maAnh)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var image = await _context.Set<HinhAnhCoSo>().Include(x => x.MaCoSoNavigation).FirstOrDefaultAsync(x => x.MaAnh == maAnh);
            if (image == null)
                return NotFound("Không tìm thấy ảnh");

            if (image.MaCoSoNavigation == null || image.MaCoSoNavigation.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            var maCoSo = image.MaCoSo;
            var wasMain = image.IsMain;
            var imageUrl = image.UrlAnh;

            _context.Set<HinhAnhCoSo>().Remove(image);
            await _context.SaveChangesAsync();

            if (wasMain)
            {
                var nextImage = await _context.Set<HinhAnhCoSo>()
                    .Where(x => x.MaCoSo == maCoSo)
                    .OrderBy(x => x.MaAnh)
                    .FirstOrDefaultAsync();

                if (nextImage != null)
                {
                    nextImage.IsMain = true;
                    await _context.SaveChangesAsync();
                }
            }

            if (!string.IsNullOrWhiteSpace(imageUrl))
            {
                try
                {
                    var uri = new Uri(imageUrl);
                    var relativePath = uri.AbsolutePath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", relativePath.Replace($"uploads{Path.DirectorySeparatorChar}", ""));

                    var actualPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "co_so", Path.GetFileName(relativePath));

                    if (System.IO.File.Exists(actualPath))
                    {
                        System.IO.File.Delete(actualPath);
                    }
                }
                catch
                {
                }
            }

            return Ok("Đã xóa ảnh");
        }

        // DELETE: xóa cơ sở

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coSo = await _context.CoSos
                .Include(x => x.MaTienIches)
                .FirstOrDefaultAsync(x => x.MaCoSo == id);

            if (coSo == null)
                return NotFound("Không tìm thấy cơ sở");

            if (coSo.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            var phongs = await _context.Phongs
                .Include(p => p.MaTienIches)
                .Where(p => p.MaCoSo == id)
                .ToListAsync();

            var phongIds = phongs.Select(p => p.MaPhong).ToList();

            var hinhAnhPhong = await _context.HinhAnhPhongs
                .Where(h => phongIds.Contains(h.MaPhong))
                .ToListAsync();

            var hinhAnhCoSo = await _context.HinhAnhCoSos
                .Where(h => h.MaCoSo == id)
                .ToListAsync();

            foreach (var phong in phongs)
            {
                phong.MaTienIches.Clear();
            }

            coSo.MaTienIches.Clear();

            _context.HinhAnhPhongs.RemoveRange(hinhAnhPhong);
            _context.Phongs.RemoveRange(phongs);
            _context.HinhAnhCoSos.RemoveRange(hinhAnhCoSo);
            _context.CoSos.Remove(coSo);

            await _context.SaveChangesAsync();

            return Ok("Đã xóa cơ sở");
        }
        //lấy danh sách tất cả tiện ích
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

        //thêm tiện ích mới vào

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

        // PATCH: cập nhật giá điện nước của cơ sở
        [HttpPatch("{id}/utility-prices")]
        public async Task<IActionResult> UpdateUtilityPrices(int id, [FromBody] PhongTroAPI.DTOs.UpdateUtilityPricesDto dto)
        {
            var maQuanLyClaim = User.FindFirst("MaQuanLy")?.Value;
            if (string.IsNullOrEmpty(maQuanLyClaim) || !int.TryParse(maQuanLyClaim, out int maQuanLy))
            {
                return Unauthorized();
            }

            var coso = await _context.CoSos.FindAsync(id);
            if (coso == null)
                return NotFound("Không tìm thấy cơ sở");

            if (coso.MaQuanLy != maQuanLy)
            {
                return Forbid();
            }

            coso.DonGiaDien = dto.DonGiaDien;
            coso.DonGiaNuoc = dto.DonGiaNuoc;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật đơn giá thành công", donGiaDien = coso.DonGiaDien, donGiaNuoc = coso.DonGiaNuoc });
        }
    }

    public class CoSoImageUrlDto
    {
        public string Url { get; set; } = string.Empty;
    }
}