using Microsoft.Extensions.Configuration;
using Neo4j.Driver;
using System;

namespace PhongTroAPI.DataAccess
{
    public class Neo4jDbContext : IDisposable
    {
        private readonly IDriver _driver;

        public Neo4jDbContext(IConfiguration configuration)
        {
            var uri = configuration.GetConnectionString("Neo4j");
            var user = configuration.GetConnectionString("Neo4jUser");
            var password = configuration.GetConnectionString("Neo4jPassword");

            _driver = GraphDatabase.Driver(uri, AuthTokens.Basic(user, password));
        }

        public IAsyncSession GetAsyncSession()
        {
            return _driver.AsyncSession();
        }

        public void Dispose()
        {
            _driver?.Dispose();
        }
    }
}
