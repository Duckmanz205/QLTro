using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class NguoiQuanLyRepository
    {
        private readonly IMongoCollection<NguoiQuanLy> _collection;

        public NguoiQuanLyRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<NguoiQuanLy>("NguoiQuanLy");
        }

        public async Task<List<NguoiQuanLy>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<NguoiQuanLy> GetByIdAsync(int id) => await _collection.Find(x => x.MaQuanLy == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(NguoiQuanLy entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, NguoiQuanLy entity) => await _collection.ReplaceOneAsync(x => x.MaQuanLy == id, entity);
        
        public async Task DeleteAsync(int id) => await _collection.DeleteOneAsync(x => x.MaQuanLy == id);
    }
}
