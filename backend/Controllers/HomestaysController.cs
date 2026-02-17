using backend.Database;
using backend.DTO;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HomestaysController(AppDbContext db, ICloudImageService imageService) : ControllerBase
    {
        
        private int? GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (claim != null && int.TryParse(claim, out int userId)) return userId;
            return null;
        }

        // GET /api/Homestays — Owner sees only their own homestays
        [Authorize(Roles = "owner")]
        [HttpGet("OwnerStay")]
        public async Task<ActionResult<IEnumerable<object>>> GetMyHomestays()
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var list = await db.Homestays
             .Where(h => h.OwnerId == ownerId.Value)
             .Include(h => h.NearCulturalSite)   
             .OrderByDescending(h => h.CreatedAt)
             .Select(h => new
     {
                    id = h.Id,
                    name = h.Name,
                    location = h.Location,
                    description = h.Description,
                    category = h.Category,
                    pricePerNight = h.PricePerNight,
                     nearCulturalSite = h.NearCulturalSite == null ? null : new
                     {
                         id = h.NearCulturalSite.Id,
                         name = h.NearCulturalSite.Name
                     },
                 buildingHistory = h.BuildingHistory,
                    culturalSignificance = h.CulturalSignificance,
                    traditionalFeatures = h.TraditionalFeatures,
                    culturalExperiences = h.CulturalExperiences,
                    numberOfRooms = h.NumberOfRooms,
                    maxGuests = h.MaxGuests,
                    bathrooms = h.Bathrooms,
                    amenities = h.Amenities,
                    imageUrls = h.ImageUrls,
                    isVisible = h.IsVisible,
                    createdAt = h.CreatedAt,
                    updatedAt = h.UpdatedAt,
                })
                .ToListAsync();

            return Ok(list);
        }

        // GET /api/Homestays/{id} — Get single homestay details
        [Authorize(Roles = "owner")]
        [HttpGet("{id:int}")]
        public async Task<ActionResult<object>> GetHomestay(int id)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var h = await db.Homestays.FindAsync(id);
            if (h == null) return NotFound("Homestay not found");
            if (h.OwnerId != ownerId.Value) return Forbid();

            return Ok(new
            {
                id = h.Id,
                name = h.Name,
                location = h.Location,
                description = h.Description,
                category = h.Category,
                pricePerNight = h.PricePerNight,
                nearCulturalSiteId = h.NearCulturalSiteId,
                buildingHistory = h.BuildingHistory,
                culturalSignificance = h.CulturalSignificance,
                traditionalFeatures = h.TraditionalFeatures,
                culturalExperiences = h.CulturalExperiences,
                numberOfRooms = h.NumberOfRooms,
                maxGuests = h.MaxGuests,
                bathrooms = h.Bathrooms,
                amenities = h.Amenities,
                imageUrls = h.ImageUrls,
                isVisible = h.IsVisible,
                createdAt = h.CreatedAt,
                updatedAt = h.UpdatedAt,
            });
        }

        // POST /api/Homestays — Create new homestay
        [Authorize(Roles = "owner")]
        [HttpPost]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Create([FromForm] HomestayCreateFormDto form)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Validate near cultural site if provided
            if (form.NearCulturalSiteId.HasValue)
            {
                var site = await db.CulturalSites.FindAsync(form.NearCulturalSiteId.Value);
                if (site == null) return NotFound("Near cultural site not found");
            }

            // Upload images to Cloudinary
            var files = Request.Form.Files;
            var urls = files is { Count: > 0 }
                ? await imageService.UploadFilesAsync("lokyatra/homestays", files)
                : new List<string>();

            // Parse amenities from comma-separated string
            var amenitiesList = string.IsNullOrWhiteSpace(form.Amenities)
                ? Array.Empty<string>()
                : form.Amenities.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

            var entity = new Homestay
            {
                OwnerId = ownerId.Value,
                NearCulturalSiteId = form.NearCulturalSiteId,
                Name = form.Name,
                Location = form.Location,
                Description = form.Description,
                Category = form.Category,
                PricePerNight = form.PricePerNight,
                BuildingHistory = form.BuildingHistory,
                CulturalSignificance = form.CulturalSignificance,
                TraditionalFeatures = form.TraditionalFeatures,
                CulturalExperiences = form.CulturalExperiences,
                NumberOfRooms = form.NumberOfRooms,
                MaxGuests = form.MaxGuests,
                Bathrooms = form.Bathrooms,
                Amenities = amenitiesList,
                ImageUrls = urls.ToArray(),
                IsVisible = true,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };

            db.Homestays.Add(entity);
            await db.SaveChangesAsync();

            return Ok(new
            {
                id = entity.Id,
                name = entity.Name,
                location = entity.Location,
                category = entity.Category,
                imageUrls = entity.ImageUrls,
            });
        }

        // PUT /api/Homestays/{id} — Update homestay
        [Authorize(Roles = "owner")]
        [HttpPut("{id:int}")]
        [RequestSizeLimit(25_000_000)]
        public async Task<ActionResult<object>> Update(int id, [FromForm] HomestayCreateFormDto form)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var entity = await db.Homestays.FindAsync(id);
            if (entity == null) return NotFound("Homestay not found");
            if (entity.OwnerId != ownerId.Value) return Forbid();

            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Validate near cultural site if provided
            if (form.NearCulturalSiteId.HasValue)
            {
                var site = await db.CulturalSites.FindAsync(form.NearCulturalSiteId.Value);
                if (site == null) return NotFound("Near cultural site not found");
            }

            // Upload new images if provided
            var files = Request.Form.Files;
            if (files.Count > 0)
            {
                var urls = await imageService.UploadFilesAsync("lokyatra/homestays", files);
                entity.ImageUrls = [.. entity.ImageUrls, .. urls];
            }

            if (!string.IsNullOrWhiteSpace(form.Amenities))
            {
                entity.Amenities = form.Amenities.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            }

            entity.NearCulturalSiteId = form.NearCulturalSiteId;
            entity.Name = form.Name;
            entity.Location = form.Location;
            entity.Description = form.Description;
            entity.Category = form.Category;
            entity.PricePerNight = form.PricePerNight;
            entity.BuildingHistory = form.BuildingHistory;
            entity.CulturalSignificance = form.CulturalSignificance;
            entity.TraditionalFeatures = form.TraditionalFeatures;
            entity.CulturalExperiences = form.CulturalExperiences;
            entity.NumberOfRooms = form.NumberOfRooms;
            entity.MaxGuests = form.MaxGuests;
            entity.Bathrooms = form.Bathrooms;
            entity.UpdatedAt = DateTimeOffset.UtcNow;

            await db.SaveChangesAsync();

            return Ok(new
            {
                id = entity.Id,
                name = entity.Name,
                location = entity.Location,
                imageUrls = entity.ImageUrls,
            });
        }

        // PATCH /api/Homestays/{id}/visibility — Toggle visibility
        [Authorize(Roles = "owner")]
        [HttpPatch("{id:int}/visibility")]
        public async Task<ActionResult> ToggleVisibility(int id, [FromBody] VisibilityDto dto)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var entity = await db.Homestays.FindAsync(id);
            if (entity == null) return NotFound("Homestay not found");
            if (entity.OwnerId != ownerId.Value) return Forbid();

            entity.IsVisible = dto.IsVisible;
            entity.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();

            return Ok(new { id = entity.Id, isVisible = entity.IsVisible });
        }

        // DELETE /api/Homestays/{id}
        [Authorize(Roles = "owner")]
        [HttpDelete("{id:int}")]
        public async Task<ActionResult> Delete(int id)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var entity = await db.Homestays.FindAsync(id);
            if (entity == null) return NotFound("Homestay not found");
            if (entity.OwnerId != ownerId.Value) return Forbid();

            db.Homestays.Remove(entity);
            await db.SaveChangesAsync();

            return Ok(new { message = "Homestay deleted successfully" });
        }
    }

    // Simple DTO for the visibility toggle
    public class VisibilityDto
    {
        public bool IsVisible { get; set; }
    }
}