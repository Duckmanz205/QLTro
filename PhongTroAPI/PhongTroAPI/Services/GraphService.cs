using PhongTroAPI.Repositories.Neo4j;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Services
{
    public class GraphService
    {
        private readonly GraphRepository _graphRepo;

        public GraphService(GraphRepository graphRepo)
        {
            _graphRepo = graphRepo;
        }

        public async Task<List<string>> GetRecommendationsAsync(int maKhach)
        {
            return await _graphRepo.GetRecommendationsAsync(maKhach);
        }
    }
}
