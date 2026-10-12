using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class NganHangRepository
    {
        private readonly IMongoCollection<NganHang> _collection;

        public NganHangRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<NganHang>("NganHang");
        }

        public async Task<List<NganHang>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        
        public async Task<NganHang> GetByIdAsync(int id) => await _collection.Find(x => x.MaNganHang == id).FirstOrDefaultAsync();
        
        public async Task CreateAsync(NganHang entity) => await _collection.InsertOneAsync(entity);
    }
}
