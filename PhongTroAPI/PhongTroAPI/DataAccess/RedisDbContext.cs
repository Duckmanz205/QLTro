using Microsoft.Extensions.Configuration;
using StackExchange.Redis;

namespace PhongTroAPI.DataAccess
{
    public class RedisDbContext
    {
        private readonly ConnectionMultiplexer _redis;

        public RedisDbContext(IConfiguration configuration)
        {
            var connectionString = configuration.GetConnectionString("Redis");
            _redis = ConnectionMultiplexer.Connect(connectionString);
        }

        public IDatabase Database => _redis.GetDatabase();
    }
}
