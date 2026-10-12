using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class ChiSoRepository
    {
        private readonly IMongoCollection<ChiSoDienNuoc> _collection;

        public ChiSoRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<ChiSoDienNuoc>("ChiSoDienNuoc");
        }

        public async Task<List<ChiSoDienNuoc>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<ChiSoDienNuoc> GetByIdAsync(int id) => await _collection.Find(x => x.MaChiSo == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(ChiSoDienNuoc entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, ChiSoDienNuoc entity) => await _collection.ReplaceOneAsync(x => x.MaChiSo == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaChiSo == id);
    }
}
