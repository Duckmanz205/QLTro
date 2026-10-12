using PhongTroAPI.DataAccess;
using StackExchange.Redis;
using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Redis
{
    public class CacheRepository
    {
        private readonly IDatabase _db;

        public CacheRepository(RedisDbContext context)
        {
            _db = context.Database;
        }

        public async Task SetCacheAsync<T>(string key, T data, TimeSpan expiry)
        {
            var json = JsonSerializer.Serialize(data);
            await _db.StringSetAsync(key, json, expiry);
        }

        public async Task<T?> GetCacheAsync<T>(string key)
        {
            var json = await _db.StringGetAsync(key);
            if (json.IsNullOrEmpty) return default;
            return JsonSerializer.Deserialize<T>(json!);
        }

        public async Task RemoveCacheAsync(string key)
        {
            await _db.KeyDeleteAsync(key);
        }
    }
}
