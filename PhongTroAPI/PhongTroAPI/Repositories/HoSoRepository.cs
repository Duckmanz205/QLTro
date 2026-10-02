using Microsoft.EntityFrameworkCore;
using PhongTroAPI.DTOs;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Repositories
{
    /// <summary>
    /// Implement <see cref="IHoSoRepository"/> sử dụng EF Core và <see cref="QuanLyPhongTroContext"/>.
    /// Tất cả thao tác đọc/ghi đều bất đồng bộ để không chặn thread pool.
    /// </summary>
    public class HoSoRepository : IHoSoRepository
    {
        private readonly QuanLyPhongTroContext _context;

        /// <summary>
        /// Khởi tạo repository với DbContext được inject từ DI container.
        /// </summary>
        /// <param name="context">DbContext của ứng dụng.</param>
        public HoSoRepository(QuanLyPhongTroContext context)
        {
            _context = context;
        }

        // ────────────────────────────────────────────────────────────────
        // KHÁCH THUÊ
        // ────────────────────────────────────────────────────────────────

        /// <inheritdoc/>
        public async Task<KhachThue?> LayHoSoKhachThueAsync(int maKhach, CancellationToken cancellationToken = default)
        {
            // AsNoTracking: không cần tracking vì đây là thao tác đọc thuần tuý
            return await _context.KhachThues
                .AsNoTracking()
                .FirstOrDefaultAsync(k => k.MaKhach == maKhach, cancellationToken);
        }

        /// <inheritdoc/>
        public async Task<bool> CapNhatHoSoKhachThueAsync(int maKhach, CapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            // FindAsync dùng primary key cache của EF Core, hiệu quả hơn FirstOrDefault
            var entity = await _context.KhachThues.FindAsync(new object[] { maKhach }, cancellationToken);
            if (entity is null) return false;

            // Ánh xạ từng trường — chỉ cập nhật trường được phép, bỏ qua TrangThai
            entity.HoTen          = request.HoTen;
            entity.Sdt            = request.Sdt;
            entity.Email          = request.Email;
            entity.Cccd           = request.Cccd;
            entity.NgaySinh       = request.NgaySinh;
            entity.GioiTinh       = request.GioiTinh;
            entity.DiaChiThuongTru = request.DiaChiThuongTru;
            entity.NgayCapCccd    = request.NgayCapCccd;
            entity.NoiCapCccd     = request.NoiCapCccd;

            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }

        /// <inheritdoc/>
        public async Task<bool> AdminCapNhatHoSoKhachThueAsync(int maKhach, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            var entity = await _context.KhachThues.FindAsync(new object[] { maKhach }, cancellationToken);
            if (entity is null) return false;

            entity.HoTen          = request.HoTen;
            entity.Sdt            = request.Sdt;
            entity.Email          = request.Email;
            entity.Cccd           = request.Cccd;
            entity.NgaySinh       = request.NgaySinh;
            entity.GioiTinh       = request.GioiTinh;
            entity.DiaChiThuongTru = request.DiaChiThuongTru;
            entity.NgayCapCccd    = request.NgayCapCccd;
            entity.NoiCapCccd     = request.NoiCapCccd;

            // Admin được phép đổi TrangThai; nếu null thì giữ nguyên
            if (request.TrangThai is not null)
                entity.TrangThai = request.TrangThai;

            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }

        // ────────────────────────────────────────────────────────────────
        // NGƯỜI QUẢN LÝ
        // ────────────────────────────────────────────────────────────────

        /// <inheritdoc/>
        public async Task<NguoiQuanLy?> LayHoSoNguoiQuanLyAsync(int maQuanLy, CancellationToken cancellationToken = default)
        {
            return await _context.NguoiQuanLies
                .AsNoTracking()
                .FirstOrDefaultAsync(q => q.MaQuanLy == maQuanLy, cancellationToken);
        }

        /// <inheritdoc/>
        public async Task<bool> AdminCapNhatHoSoNguoiQuanLyAsync(int maQuanLy, AdminCapNhatHoSoRequest request, CancellationToken cancellationToken = default)
        {
            var entity = await _context.NguoiQuanLies.FindAsync(new object[] { maQuanLy }, cancellationToken);
            if (entity is null) return false;

            entity.HoTen       = request.HoTen;
            entity.Sdt         = request.Sdt;
            entity.Email       = request.Email;
            entity.SoTaiKhoan  = request.SoTaiKhoan;
            entity.TenTaiKhoan = request.TenTaiKhoan;

            // MaNganHang: nếu null thì giữ nguyên, tránh vô tình xoá liên kết ngân hàng
            if (request.MaNganHang.HasValue)
                entity.MaNganHang = request.MaNganHang.Value;

            // TrangThai: Admin được phép thay đổi
            if (request.TrangThai is not null)
                entity.TrangThai = request.TrangThai;

            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }

        // ────────────────────────────────────────────────────────────────
        // TRA CỨU VAI TRÒ
        // ────────────────────────────────────────────────────────────────

        /// <inheritdoc/>
        public async Task<(string VaiTro, int? MaKhach, int? MaQuanLy)?> LayVaiTroTaiKhoanAsync(int maTaiKhoan, CancellationToken cancellationToken = default)
        {
            var tk = await _context.TaiKhoans
                .AsNoTracking()
                .Select(t => new { t.MaTaiKhoan, t.VaiTro, t.MaKhach, t.MaQuanLy })
                .FirstOrDefaultAsync(t => t.MaTaiKhoan == maTaiKhoan, cancellationToken);

            if (tk is null) return null;
            return (tk.VaiTro, tk.MaKhach, tk.MaQuanLy);
        }
    }
}
