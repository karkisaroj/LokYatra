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
            return int.TryParse(claim, out int userId) ? userId : null;
        }

      
        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> GetAllHomestays()
        {
            var isAdmin = User.Identity?.IsAuthenticated == true && User.IsInRole("admin");

            var query = db.Homestays.Include(h => h.NearCulturalSite).AsQueryable();

           
            if (!isAdmin)
            {
                query = query.Where(h => h.IsVisible == true);
            }

            var list = await query
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
                    updatedAt = h.UpdatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        
        [Authorize(Roles = "owner")]
        [HttpGet("my-homestays")]
        public async Task<IActionResult> GetMyHomestays()
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var list = await db.Homestays
                .Where(h => h.OwnerId == ownerId)
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
                    updatedAt = h.UpdatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        [Authorize(Roles = "owner")]
        [HttpPost]
        [RequestSizeLimit(25_000_000)]
        public async Task<IActionResult> Create([FromForm] HomestayCreateFormDto form)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var files = Request.Form.Files;
            var urls = files.Count > 0
                ? await imageService.UploadFilesAsync("lokyatra/homestays", files)
                : [];

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
                Amenities = string.IsNullOrWhiteSpace(form.Amenities)
                    ? Array.Empty<string>()
                    : form.Amenities.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries),
                ImageUrls = urls.ToArray(),
                IsVisible = true,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            db.Homestays.Add(entity);
            await db.SaveChangesAsync();

            return Ok(entity);
        }

        [Authorize(Roles = "owner")]
        [HttpPut("{id}")]
        [RequestSizeLimit(25_000_000)]
        public async Task<IActionResult> Update(int id, [FromForm] HomestayUpdateFormDto form)
        {
            var ownerId = GetCurrentUserId();
            if (ownerId == null) return Unauthorized();

            var homestay = await db.Homestays
                .FirstOrDefaultAsync(h => h.Id == id && h.OwnerId == ownerId.Value);

            if (homestay == null) return NotFound("Homestay not found or you don't own it.");
            if (!ModelState.IsValid) return BadRequest(ModelState);

            homestay.Name = form.Name ?? homestay.Name;
            homestay.Location = form.Location ?? homestay.Location;
            homestay.Description = form.Description ?? homestay.Description;
            homestay.Category = form.Category ?? homestay.Category;
            homestay.PricePerNight = form.PricePerNight;
            homestay.BuildingHistory = form.BuildingHistory ?? homestay.BuildingHistory;
            homestay.CulturalSignificance = form.CulturalSignificance ?? homestay.CulturalSignificance;
            homestay.TraditionalFeatures = form.TraditionalFeatures ?? homestay.TraditionalFeatures;
            homestay.CulturalExperiences = form.CulturalExperiences ?? homestay.CulturalExperiences;
            homestay.NumberOfRooms = form.NumberOfRooms;
            homestay.MaxGuests = form.MaxGuests;
            homestay.Bathrooms = form.Bathrooms;
            homestay.NearCulturalSiteId = form.NearCulturalSiteId ?? homestay.NearCulturalSiteId;
            homestay.IsVisible = form.IsVisible ?? homestay.IsVisible;

            if (!string.IsNullOrWhiteSpace(form.Amenities))
            {
                homestay.Amenities = form.Amenities
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            }

            var newFiles = Request.Form.Files;
            if (newFiles.Count > 0)
            {
                var newUrls = await imageService.UploadFilesAsync("lokyatra/homestays", newFiles);
                homestay.ImageUrls = homestay.ImageUrls.Concat(newUrls).ToArray();
            }

            homestay.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();

            return Ok(new
            {
                id = homestay.Id,
                name = homestay.Name,
                location = homestay.Location,
                description = homestay.Description,
                category = homestay.Category,
                pricePerNight = homestay.PricePerNight,
                numberOfRooms = homestay.NumberOfRooms,
                maxGuests = homestay.MaxGuests,
                bathrooms = homestay.Bathrooms,
                amenities = homestay.Amenities,
                imageUrls = homestay.ImageUrls,
                isVisible = homestay.IsVisible,
                updatedAt = homestay.UpdatedAt
            });
        }


        [Authorize(Roles = "owner,admin")] 
        [HttpPatch("{id}/toggle-visibility")]
        public async Task<IActionResult> ToggleVisibility(int id, [FromBody] ToggleVisibilityDto dto)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var homestay = await db.Homestays.FindAsync(id);
            if (homestay == null) return NotFound("Homestay not found.");

            
            var isAdmin = User.IsInRole("admin");
            if (!isAdmin && homestay.OwnerId != userId.Value)
            {
                return Forbid();
            }

            homestay.IsVisible = dto.IsVisible;
            homestay.UpdatedAt = DateTimeOffset.UtcNow;

            await db.SaveChangesAsync();

            return Ok(new { id = homestay.Id, isVisible = homestay.IsVisible });
        }

        [Authorize(Roles = "admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var homestay = await db.Homestays.FindAsync(id);
            if (homestay == null) return NotFound("Homestay not found");

            db.Homestays.Remove(homestay);
            await db.SaveChangesAsync();

            return Ok(new { message = "Homestay deleted successfully" });
        }


    }
}