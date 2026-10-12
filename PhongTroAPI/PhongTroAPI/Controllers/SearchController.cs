using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PhongTroAPI.Entities.Search;
using PhongTroAPI.Repositories.Elastic;
using System.Collections.Generic;
using System.Threading.Tasks;
using PhongTroAPI.Services;

namespace PhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly SearchRepository _searchRepo;
        private readonly GraphService _graphService;

        public SearchController(SearchRepository searchRepo, GraphService graphService)
        {
            _searchRepo = searchRepo;
            _graphService = graphService;
        }

        [HttpGet("phong")]
        [AllowAnonymous]
        public async Task<IActionResult> SearchPhong([FromQuery] string? keyword, [FromQuery] decimal? minPrice, [FromQuery] decimal? maxPrice)
        {
            var results = await _searchRepo.SearchPhongAsync(keyword ?? "");
            return Ok(results);
        }

        [HttpGet("recommendations/{maKhach}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetRecommendations(int maKhach)
        {
            var results = await _graphService.GetRecommendationsAsync(maKhach);
            return Ok(results);
        }
    }
}
