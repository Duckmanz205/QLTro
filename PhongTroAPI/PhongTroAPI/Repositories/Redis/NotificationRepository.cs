using PhongTroAPI.DataAccess;
using StackExchange.Redis;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text.Json;
using PhongTroAPI.Entities;

namespace PhongTroAPI.Repositories.Redis
{
    public class NotificationRepository
    {
        private readonly IDatabase _db;

        public NotificationRepository(RedisDbContext context)
        {
            _db = context.Database;
        }

        public async Task AddNotificationAsync(int userId, ThongBao thongBao)
        {
            var json = JsonSerializer.Serialize(thongBao);
            await _db.ListLeftPushAsync($"notifications:{userId}", json);
            // Optionally set expiry or cap size
        }

        public async Task<List<ThongBao>> GetNotificationsAsync(int userId)
        {
            var items = await _db.ListRangeAsync($"notifications:{userId}");
            var list = new List<ThongBao>();
            foreach (var item in items)
            {
                list.Add(JsonSerializer.Deserialize<ThongBao>(item!)!);
            }
            return list;
        }
    }
}
