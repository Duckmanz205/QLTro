using System.Threading.Tasks;
using Neo4j.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Repositories.Mongo;

namespace PhongTroAPI.SeedData
{
    public class Neo4jSeeder
    {
        private readonly Neo4jDbContext _context;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly PhongRepository _phongRepo;
        private readonly LichHenRepository _lichHenRepo;
        private readonly HopDongRepository _hopDongRepo;

        public Neo4jSeeder(Neo4jDbContext context, KhachThueRepository khachThueRepo, 
            PhongRepository phongRepo, LichHenRepository lichHenRepo, HopDongRepository hopDongRepo)
        {
            _context = context;
            _khachThueRepo = khachThueRepo;
            _phongRepo = phongRepo;
            _lichHenRepo = lichHenRepo;
            _hopDongRepo = hopDongRepo;
        }

        public async Task SeedAsync()
        {
            await using var session = _context.GetAsyncSession();

            // Seed KhachThue nodes
            var khachs = await _khachThueRepo.GetAllAsync();
            if (khachs != null)
            {
                foreach (var k in khachs)
                {
                    var q = "MERGE (k:KhachThue {id: $id, hoTen: $name})";
                    await session.RunAsync(q, new { id = k.MaKhach, name = k.HoTen ?? "" });
                }
            }

            // Seed Phong nodes
            var phongs = await _phongRepo.GetAllAsync();
            if (phongs != null)
            {
                foreach (var p in phongs)
                {
                    var q = "MERGE (p:Phong {id: $id, giaThue: $gia, dienTich: $dienTich})";
                    await session.RunAsync(q, new { id = p.MaPhong, gia = (double)p.GiaThue, dienTich = p.DienTich ?? 0.0 });
                }
            }

            // Seed LichHen relations (XEM)
            var lichHens = await _lichHenRepo.GetAllAsync();
            if (lichHens != null)
            {
                foreach (var lh in lichHens)
                {
                    var q = @"
                        MATCH (k:KhachThue {id: $maKhach})
                        MATCH (p:Phong {id: $maPhong})
                        MERGE (k)-[:XEM]->(p)";
                    await session.RunAsync(q, new { maKhach = lh.MaKhach, maPhong = lh.MaPhong });
                }
            }

            // Seed HopDong relations (THUE)
            var hopDongs = await _hopDongRepo.GetAllAsync();
            if (hopDongs != null)
            {
                foreach (var hd in hopDongs)
                {
                    var q = @"
                        MATCH (k:KhachThue {id: $maKhach})
                        MATCH (p:Phong {id: $maPhong})
                        MERGE (k)-[:THUE]->(p)";
                    await session.RunAsync(q, new { maKhach = hd.MaKhach, maPhong = hd.MaPhong });
                }
            }
        }
    }
}
