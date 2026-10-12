using System.Linq;
using PhongTroAPI.Entities;
using PhongTroAPI.Entities.Search;
using PhongTroAPI.Repositories.Elastic;
using System.Threading.Tasks;

namespace PhongTroAPI.Services
{
    public class SyncService
    {
        private readonly SearchRepository _searchRepo;

        public SyncService(SearchRepository searchRepo)
        {
            _searchRepo = searchRepo;
        }

        public async Task SyncPhongToElasticAsync(Phong phong, CoSo coso)
        {
            var doc = new PhongSearchDoc
            {
                Id = phong.MaPhong,
                TenPhong = phong.SoPhong,
                GiaThue = phong.GiaThue,
                DienTich = (decimal)(phong.DienTich ?? 0),
                SoNguoiToiDa = phong.SoNguoiToiDa ?? 0,
                MoTa = phong.MoTa,
                TrangThai = phong.TrangThai == "Trống" ? 1 : 0,
                MaCoSo = coso.MaCoSo,
                TienIch = phong.TienIches.Select(t => t.MaTienIch).ToList()
            };
            await _searchRepo.IndexPhongAsync(doc);
        }
    }
}
