using System.Threading.Tasks;
using System.Linq;
using PhongTroAPI.Repositories.Mongo;
using PhongTroAPI.Services;

namespace PhongTroAPI.SeedData
{
    public class ElasticSeeder
    {
        private readonly PhongRepository _phongRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly SyncService _syncService;

        public ElasticSeeder(PhongRepository phongRepo, CoSoRepository coSoRepo, SyncService syncService)
        {
            _phongRepo = phongRepo;
            _coSoRepo = coSoRepo;
            _syncService = syncService;
        }

        public async Task SeedAsync()
        {
            var phongs = await _phongRepo.GetAllAsync();
            if (phongs == null || !phongs.Any()) return;

            foreach (var phong in phongs)
            {
                var coso = await _coSoRepo.GetByIdAsync(phong.MaCoSo);
                if (coso != null)
                {
                    await _syncService.SyncPhongToElasticAsync(phong, coso);
                }
            }
        }
    }
}
