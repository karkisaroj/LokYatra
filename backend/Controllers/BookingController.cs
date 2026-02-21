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
    public class BookingController(AppDbContext db) : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        private static object MapBooking(Booking b) => new
        {
            id = b.Id,
            homestayId = b.HomestayId,
            touristId = b.TouristId,
            checkIn = b.CheckIn,
            checkOut = b.CheckOut,
            rooms = b.Rooms,
            guests = b.Guests,
            pricePerNight = b.PricePerNight,
            nights = b.Nights,
            subTotal = b.SubTotal,
            pointsRedeemed = b.PointsRedeemed,
            pointsDiscount = b.PointsDiscount,
            totalPrice = b.TotalPrice,
            status = b.Status.ToString(),
            paymentMethod = b.PaymentMethod.ToString(),
            paymentStatus = b.PaymentStatus.ToString(),
            specialRequests = b.SpecialRequests,
            rejectionReason = b.RejectionReason,
            createdAt = b.CreatedAt,
            updatedAt = b.UpdatedAt,
        };

        // ── Tourist: create booking
        [HttpPost]
        [Authorize(Roles = "tourist")]
        public async Task<ActionResult<object>> Create([FromBody] CreateBookingDto dto)
        {
            var homestay = await db.Homestays.FindAsync(dto.HomestayId);
            if (homestay is null) return NotFound("Homestay not found");
            if (!homestay.IsVisible) return BadRequest("Homestay is not available");

            // Validate rooms
            if (dto.Rooms < 1) return BadRequest("At least 1 room required");
            if (dto.Rooms > homestay.NumberOfRooms)
                return BadRequest($"Only {homestay.NumberOfRooms} rooms available");

            // Validate dates
            if (dto.CheckOut <= dto.CheckIn)
                return BadRequest("Check-out must be after check-in");

            var nights = (dto.CheckOut.DayNumber - dto.CheckIn.DayNumber);
            if (nights < 1) return BadRequest("Minimum 1 night stay");

            // Check for conflicting confirmed bookings
            var conflict = await db.Bookings.AnyAsync(b =>
                b.HomestayId == dto.HomestayId &&
                b.Status == BookingStatus.Confirmed &&
                b.CheckIn < dto.CheckOut &&
                b.CheckOut > dto.CheckIn);
            if (conflict) return Conflict("Selected dates are not available");

            // Pricing
            var subTotal = homestay.PricePerNight * dto.Rooms * nights;

            // Points redemption (10 points = Rs. 1, max 20% off)
            decimal pointsDiscount = 0;
            int pointsRedeemed = 0;
            if (dto.PointsToRedeem > 0)
            {
                var tourist = await db.Users.FindAsync(CurrentUserId);
                if (tourist != null && tourist.QuizPoints >= dto.PointsToRedeem)
                {
                    var requestedDiscount = dto.PointsToRedeem / 10m;
                    var maxDiscount = subTotal * 0.20m; // max 20%
                    pointsDiscount = Math.Min(requestedDiscount, maxDiscount);
                    pointsRedeemed = (int)(pointsDiscount * 10);

                    tourist.QuizPoints -= pointsRedeemed;
                }
            }

            var totalPrice = subTotal - pointsDiscount;

            var booking = new Booking
            {
                HomestayId = dto.HomestayId,
                TouristId = CurrentUserId,
                CheckIn = dto.CheckIn,
                CheckOut = dto.CheckOut,
                Rooms = dto.Rooms,
                Guests = dto.Guests,
                PricePerNight = homestay.PricePerNight,
                Nights = nights,
                SubTotal = subTotal,
                PointsRedeemed = pointsRedeemed,
                PointsDiscount = pointsDiscount,
                TotalPrice = totalPrice,
                PaymentMethod = Enum.TryParse<PaymentMethod>(dto.PaymentMethod, out var pm)
                                    ? pm : PaymentMethod.PayAtArrival,
                SpecialRequests = dto.SpecialRequests,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };

            db.Bookings.Add(booking);
            await db.SaveChangesAsync();

            return Ok(MapBooking(booking));
        }

        // ── Tourist: my bookings 
        [HttpGet("my-bookings")]
        [Authorize(Roles = "tourist")]
        public async Task<ActionResult<IEnumerable<object>>> MyBookings()
        {
            var bookings = await db.Bookings
                .Where(b => b.TouristId == CurrentUserId)
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();

            // Attach homestay name for display
            var result = new List<object>();
            foreach (var b in bookings)
            {
                var homestay = await db.Homestays.FindAsync(b.HomestayId);
                result.Add(new
                {
                    booking = MapBooking(b),
                    homestayName = homestay?.Name ?? "",
                    homestayLocation = homestay?.Location ?? "",
                    homestayImage = homestay?.ImageUrls?.FirstOrDefault() ?? "",
                });
            }
            return Ok(result);
        }

        // ── Tourist: cancel booking
        [HttpPatch("{id:int}/cancel")]
        [Authorize(Roles = "tourist")]
        public async Task<ActionResult> Cancel(int id)
        {
            var booking = await db.Bookings.FindAsync(id);
            if (booking is null) return NotFound();
            if (booking.TouristId != CurrentUserId) return Forbid();
            if (booking.Status == BookingStatus.Completed)
                return BadRequest("Cannot cancel a completed booking");

            booking.Status = BookingStatus.Cancelled;
            booking.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();
            return Ok(new { message = "Booking cancelled" });
        }

        // ── Owner: see bookings for their homestays 
        [HttpGet("owner-bookings")]
        [Authorize(Roles = "owner")]
        public async Task<ActionResult<IEnumerable<object>>> OwnerBookings()
        {
            var myHomestayIds = await db.Homestays
                .Where(h => h.OwnerId == CurrentUserId)
                .Select(h => h.Id)
                .ToListAsync();

            var bookings = await db.Bookings
                .Where(b => myHomestayIds.Contains(b.HomestayId))
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();

            var result = new List<object>();
            foreach (var b in bookings)
            {
                var tourist = await db.Users.FindAsync(b.TouristId);
                var homestay = await db.Homestays.FindAsync(b.HomestayId);
                result.Add(new
                {
                    booking = MapBooking(b),
                    touristName = tourist?.Name ?? "",
                    touristPhone = tourist?.PhoneNumber ?? "",
                    homestayName = homestay?.Name ?? "",
                });
            }
            return Ok(result);
        }

        // ── Owner: confirm or reject 
        [HttpPatch("{id:int}/status")]
        [Authorize(Roles = "owner")]
        public async Task<ActionResult> UpdateStatus(int id, [FromBody] UpdateBookingStatusDto dto)
        {
            var booking = await db.Bookings.FindAsync(id);
            if (booking is null) return NotFound();

            // Verify this booking belongs to owner's homestay
            var homestay = await db.Homestays.FindAsync(booking.HomestayId);
            if (homestay?.OwnerId != CurrentUserId) return Forbid();

            if (!Enum.TryParse<BookingStatus>(dto.Status, out var newStatus))
                return BadRequest("Invalid status");

            booking.Status = newStatus;
            booking.RejectionReason = dto.RejectionReason;
            booking.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();

            return Ok(new { message = $"Booking {dto.Status.ToLower()}" });
        }

        // ── Admin: all bookings 
        [HttpGet("all")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<IEnumerable<object>>> AllBookings(
            [FromQuery] string? status = null)
        {
            var q = db.Bookings.AsQueryable();

            if (!string.IsNullOrEmpty(status) &&
                Enum.TryParse<BookingStatus>(status, out var statusFilter))
                q = q.Where(b => b.Status == statusFilter);

            var bookings = await q.OrderByDescending(b => b.CreatedAt).ToListAsync();

            var result = new List<object>();
            foreach (var b in bookings)
            {
                var tourist = await db.Users.FindAsync(b.TouristId);
                var homestay = await db.Homestays.FindAsync(b.HomestayId);
                result.Add(new
                {
                    booking = MapBooking(b),
                    touristName = tourist?.Name ?? "",
                    homestayName = homestay?.Name ?? "",
                });
            }
            return Ok(result);
        }
    }
}