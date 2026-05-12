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
    public class SavedController(AppDbContext db) : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        // ── Toggle save/unsave 
        [HttpPost("{homestayId:int}")]
        public async Task<ActionResult<object>> Toggle(int homestayId)
        {
            var homestay = await db.Homestays.FindAsync(homestayId);
            if (homestay is null) return NotFound("Homestay not found");

            var existing = await db.SavedHomestays
                .FirstOrDefaultAsync(s =>
                    s.UserId == CurrentUserId && s.HomestayId == homestayId);

            if (existing != null)
            {
                db.SavedHomestays.Remove(existing);
                await db.SaveChangesAsync();
                return Ok(new { saved = false, message = "Removed from saved" });
            }
            else
            {
                db.SavedHomestays.Add(new SavedHomestay
                {
                    UserId = CurrentUserId,
                    HomestayId = homestayId,
                    SavedAt = DateTimeOffset.UtcNow,
                });
                await db.SaveChangesAsync();
                return Ok(new { saved = true, message = "Added to saved" });
            }
        }

        // ── Get all saved homestays ────────────────────────────────────────
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetSaved()
        {
            var saved = await db.SavedHomestays
                .Where(s => s.UserId == CurrentUserId)
                .Include(s => s.Homestay)
                    .ThenInclude(h => h!.NearCulturalSite)
                .Include(s => s.Homestay)
                    .ThenInclude(h => h!.Owner)
                .OrderByDescending(s => s.SavedAt)
                .ToListAsync();

            var result = saved
                .Where(s => s.Homestay != null)
                .Select(s =>
                {
                    var h = s.Homestay!;
                    return new
                    {
                        savedId = s.Id,
                        savedAt = s.SavedAt,
                        homestay = new
                        {
                            id = h.Id,
                            name = h.Name,
                            location = h.Location,
                            description = h.Description,
                            category = h.Category,
                            pricePerNight = h.PricePerNight,
                            imageUrls = h.ImageUrls,
                            isVisible = h.IsVisible,
                            numberOfRooms = h.NumberOfRooms,
                            maxGuests = h.MaxGuests,
                            bathrooms = h.Bathrooms,
                            amenities = h.Amenities,
                            buildingHistory = h.BuildingHistory,
                            culturalSignificance = h.CulturalSignificance,
                            traditionalFeatures = h.TraditionalFeatures,
                            culturalExperiences = h.CulturalExperiences,
                            nearCulturalSite = h.NearCulturalSite == null ? null : new
                            {
                                id = h.NearCulturalSite.Id,
                                name = h.NearCulturalSite.Name,
                            },
                            owner = h.Owner == null ? null : new
                            {
                                userId = h.Owner.UserId,
                                name = h.Owner.Name,
                                phoneNumber = h.Owner.PhoneNumber,
                            },
                            createdAt = h.CreatedAt,
                            updatedAt = h.UpdatedAt,
                        }
                    };
                });

            return Ok(result);
        }

        // ── Check if a single homestay is saved ───────────────────────────
        [HttpGet("{homestayId:int}/check")]
        public async Task<ActionResult<object>> Check(int homestayId)
        {
            var saved = await db.SavedHomestays.AnyAsync(s =>
                s.UserId == CurrentUserId && s.HomestayId == homestayId);
            return Ok(new { saved });
        }
    }
}