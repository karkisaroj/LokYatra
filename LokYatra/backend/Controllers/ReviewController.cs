using backend.Database;
using backend.DTO;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ReviewController(AppDbContext db) : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        private static object MapReview(Review r) => new
        {
            id = r.Id,
            touristId = r.TouristId,
            touristName = r.Tourist?.Name ?? "Deleted User",
            touristImage = r.Tourist?.ProfileImage ?? "",
            homestayId = r.HomestayId,
            bookingId = r.BookingId,
            siteId = r.SiteId,
            rating = r.Rating,
            comment = r.Comment,
            createdAt = r.CreatedAt,
            updatedAt = r.UpdatedAt,
        };


        [HttpPost("homestay")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> CreateHomestayReview([FromBody] CreateHomestayReviewDto dto)
        {
            var booking = await db.Bookings.FindAsync(dto.BookingId);
            if (booking is null) return NotFound("Booking not found");
            if (booking.TouristId != CurrentUserId) return Forbid();
            if (booking.HomestayId != dto.HomestayId)
                return BadRequest("Booking does not match the specified homestay");
            if (booking.Status != BookingStatus.Completed)
                return BadRequest("You can only review a homestay after your stay is completed");

            // One review per booking
            var exists = await db.Reviews.AnyAsync(r => r.BookingId == dto.BookingId);
            if (exists) return Conflict("You have already reviewed this booking");

            var review = new Review
            {
                TouristId = CurrentUserId,
                HomestayId = dto.HomestayId,
                BookingId = dto.BookingId,
                Rating = dto.Rating,
                Comment = dto.Comment,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };

            db.Reviews.Add(review);
            await db.SaveChangesAsync();

            // Load tourist for response
            await db.Entry(review).Reference(r => r.Tourist).LoadAsync();
            return Ok(MapReview(review));
        }


        [HttpPost("site")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> CreateSiteReview([FromBody] CreateSiteReviewDto dto)
        {
            var siteExists = await db.CulturalSites.AnyAsync(s => s.Id == dto.SiteId);
            if (!siteExists) return NotFound("Cultural site not found");

            // One review per tourist per site
            var exists = await db.Reviews.AnyAsync(
                r => r.SiteId == dto.SiteId && r.TouristId == CurrentUserId);
            if (exists) return Conflict("You have already reviewed this site");

            var review = new Review
            {
                TouristId = CurrentUserId,
                SiteId = dto.SiteId,
                Rating = dto.Rating,
                Comment = dto.Comment,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };

            db.Reviews.Add(review);
            await db.SaveChangesAsync();

            await db.Entry(review).Reference(r => r.Tourist).LoadAsync();
            return Ok(MapReview(review));
        }


        [AllowAnonymous]
        [HttpGet("homestay/{homestayId:int}")]
        public async Task<IActionResult> GetHomestayReviews(int homestayId)
        {
            var reviews = await db.Reviews
                .Include(r => r.Tourist)
                .Where(r => r.HomestayId == homestayId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(reviews.Select(MapReview));
        }


        [AllowAnonymous]
        [HttpGet("site/{siteId:int}")]
        public async Task<IActionResult> GetSiteReviews(int siteId)
        {
            var reviews = await db.Reviews
                .Include(r => r.Tourist)
                .Where(r => r.SiteId == siteId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(reviews.Select(MapReview));
        }


        [HttpGet("my/booking/{bookingId:int}")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> GetMyBookingReview(int bookingId)
        {
            var review = await db.Reviews
                .Include(r => r.Tourist)
                .FirstOrDefaultAsync(r => r.BookingId == bookingId && r.TouristId == CurrentUserId);

            if (review is null) return Ok(null);
            return Ok(MapReview(review));
        }


        [HttpGet("my/site/{siteId:int}")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> GetMySiteReview(int siteId)
        {
            var review = await db.Reviews
                .Include(r => r.Tourist)
                .FirstOrDefaultAsync(r => r.SiteId == siteId && r.TouristId == CurrentUserId);

            if (review is null) return Ok(null);
            return Ok(MapReview(review));
        }


        [HttpPut("{id:int}")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> UpdateReview(int id, [FromBody] UpdateReviewDto dto)
        {
            var review = await db.Reviews
                .Include(r => r.Tourist)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (review is null) return NotFound();
            if (review.TouristId != CurrentUserId) return Forbid();

            review.Rating = dto.Rating;
            review.Comment = dto.Comment;
            review.UpdatedAt = DateTimeOffset.UtcNow;

            await db.SaveChangesAsync();
            return Ok(MapReview(review));
        }


        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteReview(int id)
        {
            var review = await db.Reviews.FindAsync(id);
            if (review is null) return NotFound();

            var isAdmin = User.IsInRole("admin");
            if (!isAdmin && review.TouristId != CurrentUserId) return Forbid();

            db.Reviews.Remove(review);
            await db.SaveChangesAsync();
            return Ok(new { message = "Review deleted" });
        }

        [HttpGet("my-reviews")]
        [Authorize]
        public async Task<IActionResult> GetMyReviews()
        {
            var touristId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var reviews = await db.Reviews
                .Where(r => r.TouristId == touristId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new
                {
                    id = r.Id,
                    touristId = r.TouristId,
                    homestayId = r.HomestayId,
                    siteId = r.SiteId,
                    bookingId = r.BookingId,
                    homestayName = r.HomestayId != null
                        ? db.Homestays.Where(h => h.Id == r.HomestayId).Select(h => h.Name).FirstOrDefault()
                        : null,
                    siteName = r.SiteId != null
                        ? db.CulturalSites.Where(s => s.Id == r.SiteId).Select(s => s.Name).FirstOrDefault()
                        : null,
                    rating = r.Rating,
                    comment = r.Comment,
                    createdAt = r.CreatedAt,
                    updatedAt = r.UpdatedAt,
                })
                .ToListAsync();

            return Ok(reviews);
        }

        [HttpGet("all")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> GetAllReviews(
            [FromQuery] string? type = null,   // "homestay" | "site"
            [FromQuery] int? rating = null)
        {
            var q = db.Reviews
                .Include(r => r.Tourist)
                .Include(r => r.Homestay)
                .Include(r => r.Site)
                .AsQueryable();

            if (type == "homestay") q = q.Where(r => r.HomestayId != null);
            if (type == "site") q = q.Where(r => r.SiteId != null);
            if (rating.HasValue) q = q.Where(r => r.Rating == rating.Value);

            var reviews = await q.OrderByDescending(r => r.CreatedAt).ToListAsync();

            return Ok(reviews.Select(r => new
            {
                id = r.Id,
                touristId = r.TouristId,
                touristName = r.Tourist?.Name ?? "Deleted User",
                touristImage = r.Tourist?.ProfileImage ?? "",
                homestayId = r.HomestayId,
                homestayName = r.Homestay?.Name,
                bookingId = r.BookingId,
                siteId = r.SiteId,
                siteName = r.Site?.Name,
                rating = r.Rating,
                comment = r.Comment,
                createdAt = r.CreatedAt,
                updatedAt = r.UpdatedAt,
            }));
        }
    }
}