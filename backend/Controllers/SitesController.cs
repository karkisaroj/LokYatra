using System.Text.Json;
using backend.Database;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SitesController(AppDbContext db) : ControllerBase
    {
        private readonly AppDbContext db = db;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetSites([FromQuery] string? q = null)
        {
            var query = db.CulturalSites.AsQueryable();

            if (!string.IsNullOrWhiteSpace(q))
            {
                var qq = q.ToLower();
                query = query.Where(s =>
                    (s.Name ?? "").Contains(qq, StringComparison.CurrentCultureIgnoreCase) ||
                    (s.Category ?? "").Contains(qq, StringComparison.CurrentCultureIgnoreCase) ||
                    (s.District ?? "").Contains(qq, StringComparison.CurrentCultureIgnoreCase));
            }

            var list = await query
                .OrderByDescending(s => s.Id)
                .Select(s => new
                {
                    id = s.Id,
                    name = s.Name,
                    category = s.Category,
                    district = s.District,
                    address = s.Address,
                    shortDescription = s.ShortDescription,
                    historicalSignificance = s.HistoricalSignificance,
                    culturalImportance = s.CulturalImportance,
                    entryFeeNPR = s.EntryFeeNPR,
                    entryFeeSAARC = s.EntryFeeSAARC,
                    openingTime = s.OpeningTime,
                    closingTime = s.ClosingTime,
                    bestTimeToVisit = s.BestTimeToVisit,
                    isUNESCO = s.IsUNESCO,
                    imageUrls = s.ImageUrls,
                    createdAt = s.CreatedAt,
                    updatedAt = s.UpdatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // ✅ FIXED: now includes createdAt and updatedAt
        [HttpGet("{id:int}")]
        public async Task<ActionResult<object>> GetSite(int id)
        {
            var s = await db.CulturalSites.FindAsync(id);
            if (s is null) return NotFound("Site not found");

            return Ok(new
            {
                id = s.Id,
                name = s.Name,
                category = s.Category,
                district = s.District,
                address = s.Address,
                shortDescription = s.ShortDescription,
                historicalSignificance = s.HistoricalSignificance,
                culturalImportance = s.CulturalImportance,
                entryFeeNPR = s.EntryFeeNPR,
                entryFeeSAARC = s.EntryFeeSAARC,
                openingTime = s.OpeningTime,
                closingTime = s.ClosingTime,
                bestTimeToVisit = s.BestTimeToVisit,
                isUNESCO = s.IsUNESCO,
                imageUrls = s.ImageUrls,
                createdAt = s.CreatedAt,   // ✅ was missing
                updatedAt = s.UpdatedAt    // ✅ was missing
            });
        }

        [Authorize(Roles = "admin")]
        [HttpPost]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Create(
            [FromServices] ICloudImageService imageService,
            [FromForm] SiteCreateFormDto form)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var files = Request.Form.Files;
            var urls = files is { Count: > 0 }
                ? await imageService.UploadFilesAsync("lokyatra/sites", files)
                : [];

            var entity = new CulturalSite
            {
                Name = form.Name,
                Category = form.Category,
                District = form.District,
                Address = form.Address,
                ShortDescription = form.ShortDescription,
                HistoricalSignificance = form.HistoricalSignificance,
                CulturalImportance = form.CulturalImportance,
                EntryFeeNPR = form.EntryFeeNPR,
                EntryFeeSAARC = form.EntryFeeSAARC,
                OpeningTime = form.OpeningTime,
                ClosingTime = form.ClosingTime,
                BestTimeToVisit = form.BestTimeToVisit,
                IsUNESCO = form.IsUNESCO,
                ImageUrls = urls.ToArray(),
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };

            db.CulturalSites.Add(entity);
            await db.SaveChangesAsync();

            return CreatedAtAction(nameof(GetSite), new { id = entity.Id }, new
            {
                id = entity.Id,
                name = entity.Name,
                imageUrls = entity.ImageUrls,
                createdAt = entity.CreatedAt,
                updatedAt = entity.UpdatedAt
            });
        }

        [Authorize(Roles = "admin")]
        [HttpPut("{id:int}")]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Update(
            int id,
            [FromServices] ICloudImageService imageService,
            [FromForm] SiteCreateFormDto form)
        {
            var entity = await db.CulturalSites.FindAsync(id);
            if (entity is null) return NotFound("Site not found");
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Determine which existing images to keep
            var keepUrls = string.IsNullOrWhiteSpace(form.ExistingImagesJson)
                ? entity.ImageUrls.ToList()
                : JsonSerializer.Deserialize<List<string>>(form.ExistingImagesJson) ?? [];

            var files = Request.Form.Files;
            if (files.Count > 0)
            {
                var newUrls = await imageService.UploadFilesAsync("lokyatra/sites", files);
                entity.ImageUrls = [.. keepUrls, .. newUrls];
            }
            else
            {
                entity.ImageUrls = keepUrls.ToArray();
            }

            entity.Name = form.Name;
            entity.Category = form.Category;
            entity.District = form.District;
            entity.Address = form.Address;
            entity.ShortDescription = form.ShortDescription;
            entity.HistoricalSignificance = form.HistoricalSignificance;
            entity.CulturalImportance = form.CulturalImportance;
            entity.EntryFeeNPR = form.EntryFeeNPR;
            entity.EntryFeeSAARC = form.EntryFeeSAARC;
            entity.OpeningTime = form.OpeningTime;
            entity.ClosingTime = form.ClosingTime;
            entity.BestTimeToVisit = form.BestTimeToVisit;
            entity.IsUNESCO = form.IsUNESCO;
            entity.UpdatedAt = DateTimeOffset.UtcNow;

            await db.SaveChangesAsync();

            return Ok(new
            {
                id = entity.Id,
                name = entity.Name,
                imageUrls = entity.ImageUrls,
                createdAt = entity.CreatedAt,
                updatedAt = entity.UpdatedAt
            });
        }

        [HttpGet("proxy-image")]
        [ResponseCache(Duration = 86400)]
        public async Task<ActionResult> ProxyImage([FromQuery] string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return BadRequest("url required");
            try
            {
                using var http = new HttpClient();
                http.Timeout = TimeSpan.FromSeconds(30);
                // Browser UA so Wikimedia CDN (Fastly) serves the image instead of 429-ing.
                http.DefaultRequestHeaders.Add("User-Agent",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
                if (url.Contains("wikimedia.org"))
                    http.DefaultRequestHeaders.Add("Referer", "https://en.wikipedia.org/");

                var response = await http.GetAsync(url);
                if (!response.IsSuccessStatusCode)
                    return StatusCode((int)response.StatusCode, "Image fetch failed");

                var contentType = response.Content.Headers.ContentType?.ToString() ?? "image/jpeg";
                var bytes = await response.Content.ReadAsByteArrayAsync();
                return File(bytes, contentType);
            }
            catch (Exception ex)
            {
                return StatusCode(502, $"Proxy error: {ex.Message}");
            }
        }

        [Authorize(Roles = "admin")]
        [HttpDelete("{id:int}")]
        public async Task<ActionResult> Delete(int id)
        {
            var entity = await db.CulturalSites.FindAsync(id);
            if (entity is null) return NotFound("Site not found");

            // Delete all related records that reference this site (no cascade configured)
            db.Stories.RemoveRange(db.Stories.Where(s => s.CulturalSiteId == id));
            db.SavedSites.RemoveRange(db.SavedSites.Where(s => s.SiteId == id));
            db.Reviews.RemoveRange(db.Reviews.Where(r => r.SiteId == id));
            db.CulturalSites.Remove(entity);

            await db.SaveChangesAsync();
            return Ok(new { message = "Site deleted successfully" });
        }
    }
}