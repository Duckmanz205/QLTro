using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class TinNhanRepository
    {
        private readonly IMongoCollection<TinNhan> _collection;

        public TinNhanRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<TinNhan>("TinNhan");
        }

        public async Task<List<TinNhan>> GetAllAsync() => await _collection.Find(_ => true).ToListAsync();
        public async Task<List<TinNhan>> GetByConversationAsync(string conversationKey) => 
            await _collection.Find(x => x.ConversationKey == conversationKey).ToListAsync();
        
        public async Task CreateAsync(TinNhan entity) => await _collection.InsertOneAsync(entity);
    }
}
