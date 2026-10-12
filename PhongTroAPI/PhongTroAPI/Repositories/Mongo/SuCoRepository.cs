using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class SuCoRepository
    {
        private readonly IMongoCollection<SuCo> _collection;

        public SuCoRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<SuCo>("SuCo");
        }

        public async Task<List<SuCo>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<SuCo> GetByIdAsync(int id) => await _collection.Find(x => x.MaSuCo == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(SuCo entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, SuCo entity) => await _collection.ReplaceOneAsync(x => x.MaSuCo == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaSuCo == id);
    }
}
