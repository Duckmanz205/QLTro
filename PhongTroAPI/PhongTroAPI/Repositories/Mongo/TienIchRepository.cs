using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class TienIchRepository
    {
        private readonly IMongoCollection<TienIch> _collection;

        public TienIchRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<TienIch>("TienIch");
        }

        public async Task<List<TienIch>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<TienIch> GetByIdAsync(int id) => await _collection.Find(x => x.MaTienIch == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(TienIch entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, TienIch entity) => await _collection.ReplaceOneAsync(x => x.MaTienIch == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaTienIch == id);
    }
}
