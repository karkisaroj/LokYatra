using backend.Database;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "tourist")]
    public class SavedSitesController(AppDbContext db) : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        // Toggle save/unsave
        [HttpPost("{siteId:int}")]
        public async Task<ActionResult<object>> Toggle(int siteId)
        {
            var site = await db.CulturalSites.FindAsync(siteId);
            if (site is null) return NotFound("Site not found");

            var existing = await db.SavedSites
                .FirstOrDefaultAsync(s => s.UserId == CurrentUserId && s.SiteId == siteId);

            if (existing != null)
            {
                db.SavedSites.Remove(existing);
                await db.SaveChangesAsync();
                return Ok(new { saved = false, message = "Removed from saved" });
            }
            else
            {
                db.SavedSites.Add(new SavedSite
                {
                    UserId = CurrentUserId,
                    SiteId = siteId,
                    SavedAt = DateTimeOffset.UtcNow,
                });
                await db.SaveChangesAsync();
                return Ok(new { saved = true, message = "Added to saved" });
            }
        }

        // Get all saved sites
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetSaved()
        {
            var saved = await db.SavedSites
                .Where(s => s.UserId == CurrentUserId)
                .Include(s => s.Site)
                .OrderByDescending(s => s.SavedAt)
                .ToListAsync();

            var result = saved
                .Where(s => s.Site != null)
                .Select(s =>
                {
                    var site = s.Site!;
                    return new
                    {
                        savedId = s.Id,
                        savedAt = s.SavedAt,
                        site = new
                        {
                            id = site.Id,
                            name = site.Name,
                            category = site.Category,
                            district = site.District,
                            address = site.Address,
                            shortDescription = site.ShortDescription,
                            historicalSignificance = site.HistoricalSignificance,
                            culturalImportance = site.CulturalImportance,
                            entryFeeNPR = site.EntryFeeNPR,
                            entryFeeSAARC = site.EntryFeeSAARC,
                            openingTime = site.OpeningTime,
                            closingTime = site.ClosingTime,
                            bestTimeToVisit = site.BestTimeToVisit,
                            isUNESCO = site.IsUNESCO,
                            imageUrls = site.ImageUrls,
                            createdAt = site.CreatedAt,
                            updatedAt = site.UpdatedAt,
                        }
                    };
                });

            return Ok(result);
        }

        // Check if a site is saved
        [HttpGet("{siteId:int}/check")]
        public async Task<ActionResult<object>> Check(int siteId)
        {
            var saved = await db.SavedSites.AnyAsync(s =>
                s.UserId == CurrentUserId && s.SiteId == siteId);
            return Ok(new { saved });
        }
    }
}
