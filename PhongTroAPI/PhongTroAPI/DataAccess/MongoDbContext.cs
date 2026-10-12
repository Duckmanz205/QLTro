using Microsoft.Extensions.Configuration;
using MongoDB.Driver;

namespace PhongTroAPI.DataAccess
{
    public class MongoDbContext
    {
        private readonly IMongoDatabase _database;

        public MongoDbContext(IConfiguration configuration)
        {
            var client = new MongoClient(configuration.GetConnectionString("MongoDb"));
            _database = client.GetDatabase(configuration.GetConnectionString("MongoDbDatabaseName"));
        }

        public IMongoDatabase Database => _database;
    }
}
