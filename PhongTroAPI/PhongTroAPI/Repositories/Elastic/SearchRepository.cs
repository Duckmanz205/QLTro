using Nest;
using PhongTroAPI.DataAccess;
using PhongTroAPI.Entities.Search;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Elastic
{
    public class SearchRepository
    {
        private readonly ElasticClient _client;

        public SearchRepository(ElasticDbContext context)
        {
            _client = context.Client;
        }

        public async Task IndexPhongAsync(PhongSearchDoc phong)
        {
            await _client.IndexAsync(phong, i => i.Index("phong_search"));
        }

        public async Task<List<PhongSearchDoc>> SearchPhongAsync(string keyword)
        {
            var response = await _client.SearchAsync<PhongSearchDoc>(s => s
                .Index("phong_search")
                .Query(q => q
                    .MultiMatch(m => m
                        .Fields(f => f.Field(p => p.TenPhong).Field(p => p.MoTa))
                        .Query(keyword)
                    )
                )
            );
            return response.Documents.ToList();
        }
    }
}
