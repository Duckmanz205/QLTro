using System;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace PhongTroAPI.SeedData
{
    public class DataSeeder
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<DataSeeder> _logger;

        public DataSeeder(IServiceProvider serviceProvider, ILogger<DataSeeder> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        public async Task SeedAllAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var provider = scope.ServiceProvider;

            _logger.LogInformation("🚀 Bắt đầu quá trình migration dữ liệu SQL -> NoSQL...");

            try
            {
                // 1. Seed MongoDB
                _logger.LogInformation("1. Đang seed dữ liệu vào MongoDB...");
                var mongoSeeder = provider.GetRequiredService<MongoSeeder>();
                await mongoSeeder.SeedAsync();
                _logger.LogInformation("✅ Seed MongoDB thành công!");

                // 2. Seed Elastic
                _logger.LogInformation("2. Đang đồng bộ dữ liệu sang Elasticsearch...");
                var elasticSeeder = provider.GetRequiredService<ElasticSeeder>();
                await elasticSeeder.SeedAsync();
                _logger.LogInformation("✅ Đồng bộ Elasticsearch thành công!");

                // 3. Seed Neo4j
                _logger.LogInformation("3. Đang tạo Graph Nodes & Relationships trong Neo4j...");
                var neo4jSeeder = provider.GetRequiredService<Neo4jSeeder>();
                await neo4jSeeder.SeedAsync();
                _logger.LogInformation("✅ Seed Neo4j thành công!");

                _logger.LogInformation("🎉 Migration hoàn tất!");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Lỗi trong quá trình migration dữ liệu!");
                throw;
            }
        }
    }
}
