using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class KhachThueRepository
    {
        private readonly IMongoCollection<KhachThue> _collection;

        public KhachThueRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<KhachThue>("KhachThue");
        }

        public async Task<List<KhachThue>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<KhachThue> GetByIdAsync(int id) => await _collection.Find(x => x.MaKhach == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(KhachThue entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, KhachThue entity) => await _collection.ReplaceOneAsync(x => x.MaKhach == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaKhach == id);
    }
}
