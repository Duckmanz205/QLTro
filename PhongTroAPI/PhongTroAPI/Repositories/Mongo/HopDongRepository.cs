using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class HopDongRepository
    {
        private readonly IMongoCollection<HopDongThue> _collection;

        public HopDongRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<HopDongThue>("HopDongThue");
        }

        public async Task<List<HopDongThue>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<HopDongThue> GetByIdAsync(int id) => await _collection.Find(x => x.MaHopDong == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(HopDongThue entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, HopDongThue entity) => await _collection.ReplaceOneAsync(x => x.MaHopDong == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaHopDong == id);
    }
}
