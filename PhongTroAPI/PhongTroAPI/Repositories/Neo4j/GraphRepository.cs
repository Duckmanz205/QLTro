using Neo4j.Driver;
using PhongTroAPI.DataAccess;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PhongTroAPI.Repositories.Neo4j
{
    public class GraphRepository
    {
        private readonly Neo4jDbContext _context;

        public GraphRepository(Neo4jDbContext context)
        {
            _context = context;
        }

        public async Task<List<string>> GetRecommendationsAsync(int maKhach)
        {
            await using var session = _context.GetAsyncSession();
            var query = @"
                MATCH (k:KhachThue {id: $maKhach})-[:XEM]->(p:Phong)<-[:XEM]-(other:KhachThue)
                MATCH (other)-[:XEM]->(rec:Phong)
                WHERE NOT (k)-[:XEM]->(rec)
                RETURN rec.id AS recommendedId
                LIMIT 5";
                
            var result = await session.RunAsync(query, new { maKhach });
            var recommendations = new List<string>();
            
            await foreach (var record in result)
            {
                recommendations.Add(record["recommendedId"].As<string>());
            }
            return recommendations;
        }
    }
}
