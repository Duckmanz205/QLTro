using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class ThongBaoRepository
    {
        private readonly IMongoCollection<ThongBao> _collection;

        public ThongBaoRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<ThongBao>("ThongBao");
        }

        public async Task<List<ThongBao>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<ThongBao> GetByIdAsync(int id) => await _collection.Find(x => x.MaThongBao == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(ThongBao entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, ThongBao entity) => await _collection.ReplaceOneAsync(x => x.MaThongBao == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaThongBao == id);
    }
}
