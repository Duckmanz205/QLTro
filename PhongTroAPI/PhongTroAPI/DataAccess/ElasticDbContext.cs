using Microsoft.Extensions.Configuration;
using Nest;
using System;

namespace PhongTroAPI.DataAccess
{
    public class ElasticDbContext
    {
        private readonly ElasticClient _client;

        public ElasticDbContext(IConfiguration configuration)
        {
            var uri = new Uri(configuration.GetConnectionString("Elasticsearch"));
            var settings = new ConnectionSettings(uri)
                .DisableDirectStreaming();
            
            _client = new ElasticClient(settings);
        }

        public ElasticClient Client => _client;
    }
}
