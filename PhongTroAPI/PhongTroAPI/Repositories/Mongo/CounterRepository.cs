using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Driver;
using PhongTroAPI.DataAccess;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Mongo
{
    public class Counter
    {
        [BsonId]
        public string Id { get; set; } = null!;
        public int SequenceValue { get; set; }
    }

    public class CounterRepository
    {
        private readonly IMongoCollection<Counter> _collection;

        public CounterRepository(MongoDbContext context)
        {
            _collection = context.Database.GetCollection<Counter>("Counters");
        }

        public async Task<int> GetNextSequenceValueAsync(string sequenceName)
        {
            var filter = Builders<Counter>.Filter.Eq(c => c.Id, sequenceName);
            var update = Builders<Counter>.Update.Inc(c => c.SequenceValue, 1);
            var options = new FindOneAndUpdateOptions<Counter>
            {
                ReturnDocument = ReturnDocument.After,
                IsUpsert = true
            };

            var result = await _collection.FindOneAndUpdateAsync(filter, update, options);
            return result.SequenceValue;
        }

        public async Task InitializeSequenceValueAsync(string sequenceName, int initialValue)
        {
            var filter = Builders<Counter>.Filter.Eq(c => c.Id, sequenceName);
            var update = Builders<Counter>.Update.Set(c => c.SequenceValue, initialValue);
            var options = new UpdateOptions { IsUpsert = true };
            await _collection.UpdateOneAsync(filter, update, options);
        }
    }
}
