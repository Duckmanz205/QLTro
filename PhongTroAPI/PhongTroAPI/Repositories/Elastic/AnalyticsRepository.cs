using Nest;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities.Search;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Elastic
{
    public class AnalyticsRepository
    {
        private readonly ElasticClient _client;

        public AnalyticsRepository(ElasticDbContext context)
        {
            _client = context.Client;
        }

        public async Task IndexHoaDonAsync(HoaDonAnalyticsDoc doc)
        {
            await _client.IndexAsync(doc, i => i.Index("hoa_don_analytics"));
        }
        
        // Example Aggregation: Total revenue by month
        public async Task<double> GetTotalRevenueAsync()
        {
            var response = await _client.SearchAsync<HoaDonAnalyticsDoc>(s => s
                .Index("hoa_don_analytics")
                .Aggregations(a => a
                    .Sum("total_revenue", sum => sum.Field(f => f.DaThanhToan))
                )
            );
            
            var total = response.Aggregations.Sum("total_revenue");
            return total?.Value ?? 0;
        }
    }
}
