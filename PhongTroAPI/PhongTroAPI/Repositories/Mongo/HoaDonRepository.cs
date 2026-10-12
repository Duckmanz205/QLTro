using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class HoaDonRepository
    {
        private readonly IMongoCollection<HoaDon> _collection;

        public HoaDonRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<HoaDon>("HoaDon");
        }

        public async Task<List<HoaDon>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<HoaDon> GetByIdAsync(int id) => await _collection.Find(x => x.MaHoaDon == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(HoaDon entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, HoaDon entity) => await _collection.ReplaceOneAsync(x => x.MaHoaDon == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaHoaDon == id);
    }
}
