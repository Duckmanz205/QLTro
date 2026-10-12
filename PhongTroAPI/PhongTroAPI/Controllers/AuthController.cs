using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using System.Collections.Generic;
using System;
using PhongTroAPI.Repositories.Redis;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly TaiKhoanRepository _taiKhoanRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly CounterRepository _counterRepo;
        private readonly SessionRepository _sessionRepo;

        public AuthController(
            IConfiguration config,
            TaiKhoanRepository taiKhoanRepo,
            KhachThueRepository khachThueRepo,
            NguoiQuanLyRepository quanLyRepo,
            CounterRepository counterRepo,
            SessionRepository sessionRepo)
        {
            _config = config;
            _taiKhoanRepo = taiKhoanRepo;
            _khachThueRepo = khachThueRepo;
            _quanLyRepo = quanLyRepo;
            _counterRepo = counterRepo;
            _sessionRepo = sessionRepo;
        }

        // ─────────────────────────────────────────────
        // POST /api/auth/register
        // ─────────────────────────────────────────────
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var allTaiKhoans = await _taiKhoanRepo.GetAllAsync();
            if (allTaiKhoans.Any(t => t.TenDangNhap == request.TenDangNhap.Trim()))
            {
                return BadRequest(new { message = "Tên đăng nhập đã được sử dụng" });
            }

            try
            {
                bool isManager = string.Equals(request.VaiTro, "QuanLy", StringComparison.OrdinalIgnoreCase);
                int? maKhach = null;
                int? maQuanLy = null;

                if (isManager)
                {
                    maQuanLy = await _counterRepo.GetNextSequenceValueAsync("nguoiquanly_id");
                    var newQuanLy = new NguoiQuanLy
                    {
                        MaQuanLy = maQuanLy.Value,
                        HoTen = request.HoTen.Trim(),
                        Sdt = string.IsNullOrWhiteSpace(request.SDT) ? null : request.SDT.Trim(),
                        TrangThai = "Đang hoạt động",
                        NgayTao = DateTime.Now
                    };
                    await _quanLyRepo.CreateAsync(newQuanLy);
                }
                else
                {
                    maKhach = await _counterRepo.GetNextSequenceValueAsync("khachthue_id");
                    var newKhach = new KhachThue
                    {
                        MaKhach = maKhach.Value,
                        HoTen = request.HoTen.Trim(),
                        Sdt = string.IsNullOrWhiteSpace(request.SDT) ? null : request.SDT.Trim()
                    };
                    await _khachThueRepo.CreateAsync(newKhach);
                }

                int maTaiKhoan = await _counterRepo.GetNextSequenceValueAsync("taikhoan_id");
                string finalizedRole = isManager ? "NguoiQuanLy" : "KhachThue";
                
                var newTaiKhoan = new TaiKhoan
                {
                    MaTaiKhoan = maTaiKhoan,
                    TenDangNhap = request.TenDangNhap.Trim(),
                    MatKhau = request.MatKhau, // plain text
                    VaiTro = finalizedRole,
                    MaKhach = maKhach,
                    MaQuanLy = maQuanLy,
                    TrangThai = "Hoạt động",
                    NgayTao = DateTime.Now
                };

                await _taiKhoanRepo.CreateAsync(newTaiKhoan);

                var token = GenerateJwtToken(maTaiKhoan, request.TenDangNhap.Trim(),
                    finalizedRole, maKhach, maQuanLy, request.HoTen.Trim());

                // Lưu session vào Redis
                await _sessionRepo.SaveSessionAsync(token, maTaiKhoan, TimeSpan.FromDays(7));

                return Ok(new AuthResponse
                {
                    Token = token,
                    MaTaiKhoan = maTaiKhoan,
                    TenDangNhap = request.TenDangNhap.Trim(),
                    HoTen = request.HoTen.Trim(),
                    VaiTro = finalizedRole,
                    MaKhach = maKhach,
                    MaQuanLy = maQuanLy
                });
            }
            catch (Exception ex)
            {
                string friendlyMessage = "Đăng ký thất bại. Vui lòng thử lại.";
                return StatusCode(500, new { message = friendlyMessage, detail = ex.Message });
            }
        }

        // ─────────────────────────────────────────────
        // POST /api/auth/login
        // ─────────────────────────────────────────────
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var allTaiKhoans = await _taiKhoanRepo.GetAllAsync();
            var taiKhoan = allTaiKhoans.FirstOrDefault(t => t.TenDangNhap == request.TenDangNhap.Trim());

            if (taiKhoan == null)
                return Unauthorized(new { message = "Tên đăng nhập hoặc mật khẩu không đúng" });

            if (request.MatKhau != taiKhoan.MatKhau)
                return Unauthorized(new { message = "Tên đăng nhập hoặc mật khẩu không đúng" });

            var trangThai = string.IsNullOrWhiteSpace(taiKhoan.TrangThai) ? "Hoạt động" : taiKhoan.TrangThai;
            if (trangThai != "Hoạt động")
                return StatusCode(403, new { message = "Tài khoản đã bị khóa" });

            string hoTen = taiKhoan.TenDangNhap;
            if (taiKhoan.MaKhach.HasValue)
            {
                var khach = await _khachThueRepo.GetByIdAsync(taiKhoan.MaKhach.Value);
                if (khach != null) hoTen = khach.HoTen;
            }
            else if (taiKhoan.MaQuanLy.HasValue)
            {
                var quanLy = await _quanLyRepo.GetByIdAsync(taiKhoan.MaQuanLy.Value);
                if (quanLy != null) hoTen = quanLy.HoTen;
            }

            var token = GenerateJwtToken(taiKhoan.MaTaiKhoan, taiKhoan.TenDangNhap, taiKhoan.VaiTro, taiKhoan.MaKhach, taiKhoan.MaQuanLy, hoTen);
            
            // Lưu Session vào Redis
            await _sessionRepo.SaveSessionAsync(token, taiKhoan.MaTaiKhoan, TimeSpan.FromDays(7));

            return Ok(new AuthResponse
            {
                Token = token,
                MaTaiKhoan = taiKhoan.MaTaiKhoan,
                TenDangNhap = taiKhoan.TenDangNhap,
                HoTen = hoTen,
                VaiTro = taiKhoan.VaiTro,
                MaKhach = taiKhoan.MaKhach,
                MaQuanLy = taiKhoan.MaQuanLy
            });
        }

        // ─────────────────────────────────────────────
        // Hàm tạo JWT token
        // ─────────────────────────────────────────────
        private string GenerateJwtToken(int maTaiKhoan, string tenDangNhap,
            string vaiTro, int? maKhach, int? maQuanLy, string hoTen)
        {
            var secretKey = _config["JwtSettings:SecretKey"]!;
            var issuer = _config["JwtSettings:Issuer"]!;
            var audience = _config["JwtSettings:Audience"]!;
            var expiryDays = int.TryParse(_config["JwtSettings:ExpiryDays"], out var d) ? d : 7;

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim("MaTaiKhoan", maTaiKhoan.ToString()),
                new Claim(ClaimTypes.Name, tenDangNhap),
                new Claim(ClaimTypes.Role, vaiTro ?? ""),
                new Claim("HoTen", hoTen ?? ""),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            if (maKhach.HasValue)
                claims.Add(new Claim("MaKhach", maKhach.Value.ToString()));

            if (maQuanLy.HasValue)
                claims.Add(new Claim("MaQuanLy", maQuanLy.Value.ToString()));

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddDays(expiryDays),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        // ─────────────────────────────────────────────
        // POST /api/auth/forgot-password
        // ─────────────────────────────────────────────
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var allTaiKhoans = await _taiKhoanRepo.GetAllAsync();
            var taiKhoan = allTaiKhoans.FirstOrDefault(t => t.TenDangNhap == request.TenDangNhap.Trim());

            if (taiKhoan == null)
                return BadRequest(new { message = "Tên đăng nhập không tồn tại trong hệ thống" });

            taiKhoan.MatKhau = request.NewPassword;
            await _taiKhoanRepo.UpdateAsync(taiKhoan.MaTaiKhoan, taiKhoan);

            return Ok(new { message = "Đặt lại mật khẩu thành công" });
        }
    }
}
