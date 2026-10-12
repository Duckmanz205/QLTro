using PhongTroAPI.DataAccess;
using StackExchange.Redis;
using System;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Redis
{
    public class SessionRepository
    {
        private readonly IDatabase _db;

        public SessionRepository(RedisDbContext context)
        {
            _db = context.Database;
        }

        public async Task SaveSessionAsync(string token, int userId, TimeSpan expiry)
        {
            await _db.StringSetAsync($"session:{token}", userId.ToString(), expiry);
        }

        public async Task<string?> GetSessionAsync(string token)
        {
            return await _db.StringGetAsync($"session:{token}");
        }
        
        public async Task DeleteSessionAsync(string token)
        {
            await _db.KeyDeleteAsync($"session:{token}");
        }
    }
}
