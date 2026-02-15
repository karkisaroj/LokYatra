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
    public class SitesController : ControllerBase
    {
        private readonly AppDbContext db;
        public SitesController(AppDbContext db) { this.db = db; }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetSites([FromQuery] string? q = null)
        {
            var query = db.CulturalSites.AsQueryable();

            if (!string.IsNullOrWhiteSpace(q))
            {
                var qq = q.ToLower();
                query = query.Where(s =>
                    (s.Name ?? "").ToLower().Contains(qq) ||
                    (s.Category ?? "").ToLower().Contains(qq) ||
                    (s.District ?? "").ToLower().Contains(qq));
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
                    imageUrls = s.ImageUrls
                })
                .ToListAsync();

            return Ok(list);
        }

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
                imageUrls = s.ImageUrls
            });
        }

        [Authorize(Roles = "admin")]
        [HttpPost]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Create(
    [FromServices] ICloudImageService imageService,
    [FromForm] SiteCreateFormDto form)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var files = Request.Form.Files;
            var urls = files is { Count: > 0 }
                ? await imageService.UploadFilesAsync("lokyatra/sites", files)
                : new List<string>();

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
                category = entity.Category,
                district = entity.District,
                imageUrls = entity.ImageUrls
            });
        }

        [Authorize(Roles = "admin")]
        [HttpPut("{id:int}")]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Update(int id, [FromServices] ICloudImageService imageService, [FromForm] SiteCreateFormDto form)
        {
            var entity = await db.CulturalSites.FindAsync(id);
            if (entity is null) return NotFound("Site not found");

            if (!ModelState.IsValid) return BadRequest(ModelState);

            var files = Request.Form.Files;
            if (files.Count > 0)
            {
                var urls = await imageService.UploadFilesAsync("lokyatra/sites", files);
                entity.ImageUrls = urls.ToArray();
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
                category = entity.Category,
                district = entity.District,
                imageUrls = entity.ImageUrls
            });
        }

        [Authorize(Roles = "admin")]
        [HttpDelete("{id:int}")]
        public async Task<ActionResult> Delete(int id)
        {
            var entity = await db.CulturalSites.FindAsync(id);
            if (entity is null) return NotFound("Site not found");

            db.CulturalSites.Remove(entity);
            await db.SaveChangesAsync();

            return Ok(new { message = "Site deleted successfully" });
        }
    }
}