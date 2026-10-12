using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.DTOs;
using PhongTroAPI.Repositories.Mongo;
using System.Linq;
using System.Threading.Tasks;

namespace PhongTroAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ForgotPasswordController : ControllerBase
    {
        private readonly TaiKhoanRepository _taiKhoanRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly NguoiQuanLyRepository _nguoiQuanLyRepo;

        public ForgotPasswordController(
            TaiKhoanRepository taiKhoanRepo,
            KhachThueRepository khachThueRepo,
            NguoiQuanLyRepository nguoiQuanLyRepo)
        {
            _taiKhoanRepo = taiKhoanRepo;
            _khachThueRepo = khachThueRepo;
            _nguoiQuanLyRepo = nguoiQuanLyRepo;
        }

        [HttpPost("xac-minh")]
        public async Task<IActionResult> XacMinhTaiKhoan([FromBody] XacMinhTaiKhoanRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var tatCaTaiKhoan = await _taiKhoanRepo.GetAllAsync();
            var taiKhoan = tatCaTaiKhoan.FirstOrDefault(tk => tk.TenDangNhap == request.TenDangNhap.Trim() && tk.TrangThai == "Hoạt động");

            if (taiKhoan == null)
                return BadRequest(new { message = "Tên đăng nhập không tồn tại hoặc tài khoản đã bị khóa" });

            string sdtDb = null;
            if (taiKhoan.MaKhach.HasValue)
            {
                var khach = await _khachThueRepo.GetByIdAsync(taiKhoan.MaKhach.Value);
                if (khach != null) sdtDb = khach.Sdt;
            }
            else if (taiKhoan.MaQuanLy.HasValue)
            {
                var quanLy = await _nguoiQuanLyRepo.GetByIdAsync(taiKhoan.MaQuanLy.Value);
                if (quanLy != null) sdtDb = quanLy.Sdt;
            }

            if (sdtDb == null || sdtDb.Trim() != request.SDT.Trim())
                return BadRequest(new { message = "Số điện thoại không khớp với tài khoản" });

            return Ok(new { message = "Xác minh thành công" });
        }

        [HttpPost("dat-lai")]
        public async Task<IActionResult> DatLaiMatKhau([FromBody] DatLaiMatKhauRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var tatCaTaiKhoan = await _taiKhoanRepo.GetAllAsync();
            var taiKhoan = tatCaTaiKhoan.FirstOrDefault(tk => tk.TenDangNhap == request.TenDangNhap.Trim() && tk.TrangThai == "Hoạt động");

            if (taiKhoan == null)
                return BadRequest(new { message = "Tài khoản không hợp lệ" });

            taiKhoan.MatKhau = request.MatKhauMoi;
            await _taiKhoanRepo.UpdateAsync(taiKhoan.MaTaiKhoan, taiKhoan);

            return Ok(new { message = "Đặt lại mật khẩu thành công" });
        }
    }
}
