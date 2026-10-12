using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class PhongRepository
    {
        private readonly IMongoCollection<Phong> _collection;

        public PhongRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<Phong>("Phong");
        }

        public async Task<List<Phong>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<Phong> GetByIdAsync(int id) => await _collection.Find(x => x.MaPhong == id).FirstOrDefaultAsync();
        
        public async Task<List<Phong>> GetByMaCoSoAsync(int maCoSo) => await _collection.Find(x => x.MaCoSo == maCoSo).ToListAsync();
        
        public async Task CreateAsync(Phong entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, Phong entity) => await _collection.ReplaceOneAsync(x => x.MaPhong == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaPhong == id);
    }
}
