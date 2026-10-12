using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class TaiKhoanRepository
    {
        private readonly IMongoCollection<TaiKhoan> _collection;

        public TaiKhoanRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<TaiKhoan>("TaiKhoan");
        }

        public async Task<TaiKhoan> GetByUsernameAsync(string username) => 
            await _collection.Find(x => x.TenDangNhap == username).FirstOrDefaultAsync();
        
        public async Task<List<TaiKhoan>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        public async Task<TaiKhoan> GetByIdAsync(int id) => 
            await _collection.Find(x => x.MaTaiKhoan == id).FirstOrDefaultAsync();
            
        public async Task CreateAsync(TaiKhoan entity) => await _collection.InsertOneAsync(entity);
        
        public async Task UpdateAsync(int id, TaiKhoan entity) => await _collection.ReplaceOneAsync(x => x.MaTaiKhoan == id, entity);
    }
}
