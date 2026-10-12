using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class LichHenRepository
    {
        private readonly IMongoCollection<LichHenXemPhong> _collection;

        public LichHenRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<LichHenXemPhong>("LichHenXemPhong");
        }

        public async Task<List<LichHenXemPhong>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<LichHenXemPhong> GetByIdAsync(int id) => await _collection.Find(x => x.MaLichHen == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(LichHenXemPhong entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, LichHenXemPhong entity) => await _collection.ReplaceOneAsync(x => x.MaLichHen == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaLichHen == id);
    }
}
