using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class OGhepRepository
    {
        private readonly IMongoCollection<OGhep> _collection;

        public OGhepRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<OGhep>("OGhep");
        }

        public async Task<List<OGhep>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<OGhep> GetByIdAsync(int id) => await _collection.Find(x => x.MaBaiDang == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(OGhep entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, OGhep entity) => await _collection.ReplaceOneAsync(x => x.MaBaiDang == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaBaiDang == id);
    }
}
