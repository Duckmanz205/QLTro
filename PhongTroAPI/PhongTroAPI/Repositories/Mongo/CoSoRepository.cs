using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class CoSoRepository
    {
        private readonly IMongoCollection<CoSo> _collection;

        public CoSoRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<CoSo>("CoSo");
        }

        public async Task<List<CoSo>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<CoSo> GetByIdAsync(int id) => await _collection.Find(x => x.MaCoSo == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(CoSo entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, CoSo entity) => await _collection.ReplaceOneAsync(x => x.MaCoSo == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaCoSo == id);
    }
}
