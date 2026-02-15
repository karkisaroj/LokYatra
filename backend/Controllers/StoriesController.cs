using backend.Database;
using backend.DTO;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StoriesController(AppDbContext db, ICloudImageService imageService) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetStories([FromQuery] int? siteId = null)
        {
            var q = db.Stories.AsQueryable();
            if (siteId.HasValue) q = q.Where(s => s.CulturalSiteId == siteId.Value);

            var list = await q
                .OrderByDescending(s => s.CreatedAt)
                .Select(st => new
                {
                    id = st.Id,
                    culturalSiteId = st.CulturalSiteId,
                    title = st.Title,
                    storyType = st.StoryType,
                    estimatedReadTimeMinutes = st.EstimatedReadTimeMinutes,
                    fullContent = st.FullContent,
                    historicalContext = st.HistoricalContext,
                    culturalSignificance = st.CulturalSignificance,
                    imageUrls = st.ImageUrls
                })
                .ToListAsync();

            return Ok(list);
        }

        [Authorize(Roles = "admin")]
        [HttpPost]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Create([FromForm] StoryCreateFormDto form)
        {
            var files = Request.Form.Files;
            var urls = files is { Count: > 0 } ? await imageService.UploadFilesAsync("lokyatra/stories", files) : new List<string>();

            var site = await db.CulturalSites.FindAsync(form.CulturalSiteId);
            if (site is null) return NotFound("Related site not found");

            var entity = new Story
            {
                CulturalSiteId = form.CulturalSiteId,
                Title = form.Title,
                StoryType = form.StoryType,
                EstimatedReadTimeMinutes = form.EstimatedReadTimeMinutes,
                FullContent = form.FullContent,
                HistoricalContext = form.HistoricalContext,
                CulturalSignificance = form.CulturalSignificance,
                ImageUrls = [.. urls],
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };

            db.Stories.Add(entity);
            await db.SaveChangesAsync();

            return Ok(new
            {
                id = entity.Id,
                culturalSiteId = entity.CulturalSiteId,
                title = entity.Title,
                storyType = entity.StoryType,
                imageUrls = entity.ImageUrls
            });
        }

        [Authorize(Roles = "admin")]
        [HttpPut("{id:int}")]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Update(int id, [FromForm] StoryCreateFormDto form)
        {
            var entity = await db.Stories.FindAsync(id);
            if (entity is null) return NotFound("Story not found");

            var site = await db.CulturalSites.FindAsync(form.CulturalSiteId);
            if (site is null) return NotFound("Related site not found");

            var files = Request.Form.Files;
            if (files.Count > 0)
            {
                var urls = await imageService.UploadFilesAsync("lokyatra/stories", files);
                entity.ImageUrls = [.. urls];
            }

            entity.CulturalSiteId = form.CulturalSiteId;
            entity.Title = form.Title;
            entity.StoryType = form.StoryType;
            entity.EstimatedReadTimeMinutes = form.EstimatedReadTimeMinutes;
            entity.FullContent = form.FullContent;
            entity.HistoricalContext = form.HistoricalContext;
            entity.CulturalSignificance = form.CulturalSignificance;
            entity.UpdatedAt = DateTimeOffset.UtcNow;

            await db.SaveChangesAsync();

            return Ok(new
            {
                id = entity.Id,
                culturalSiteId = entity.CulturalSiteId,
                title = entity.Title,
                storyType = entity.StoryType,
                imageUrls = entity.ImageUrls
            });
        }

        [Authorize(Roles = "admin")]
        [HttpDelete("{id:int}")]
        public async Task<ActionResult> Delete(int id)
        {
            var entity = await db.Stories.FindAsync(id);
            if (entity is null) return NotFound("Story not found");

            db.Stories.Remove(entity);
            await db.SaveChangesAsync();

            return Ok(new { message = "Story deleted successfully" });
        }
    }
}