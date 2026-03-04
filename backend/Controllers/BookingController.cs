using backend.Database;
using backend.DTO;
using backend.Entities;
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
    [Authorize]
    public class BookingController(AppDbContext db, NotificationService notificationService) : ControllerBase
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

        [HttpPost]
        [Authorize(Roles = "tourist")]
        public async Task<ActionResult<object>> Create([FromBody] CreateBookingDto dto)
        {
            var homestay = await db.Homestays.FindAsync(dto.HomestayId);
            if (homestay is null) return NotFound("Homestay not found");
            if (!homestay.IsVisible) return BadRequest("Homestay is not available");
            if (dto.Rooms < 1) return BadRequest("At least 1 room required");
            if (dto.Rooms > homestay.NumberOfRooms)
                return BadRequest($"Only {homestay.NumberOfRooms} rooms available");
            if (dto.CheckOut <= dto.CheckIn)
                return BadRequest("Check-out must be after check-in");

            var nights = dto.CheckOut.DayNumber - dto.CheckIn.DayNumber;
            if (nights < 1) return BadRequest("Minimum 1 night stay");

            var overlappingBookings = await db.Bookings
                .Where(b => b.HomestayId == dto.HomestayId
                    && (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed)
                    && b.CheckIn < dto.CheckOut
                    && b.CheckOut > dto.CheckIn)
                .ToListAsync();

            int alreadyBookedRooms = overlappingBookings.Sum(b => b.Rooms);

            if (alreadyBookedRooms + dto.Rooms > homestay.NumberOfRooms)
            {
                Console.WriteLine($"[AVAILABILITY] Homestay {dto.HomestayId} | " +
                                  $"Already booked: {alreadyBookedRooms} | Requested: {dto.Rooms} | " +
                                  $"Total rooms: {homestay.NumberOfRooms}");
                return Conflict("Selected dates are not available");
            }

            var subTotal = homestay.PricePerNight * dto.Rooms * nights;
            decimal pointsDiscount = 0;
            int pointsRedeemed = 0;
            if (dto.PointsToRedeem > 0)
            {
                var tourist = await db.Users.FindAsync(CurrentUserId);
                if (tourist != null && tourist.QuizPoints >= dto.PointsToRedeem)
                {
                    var requestedDiscount = dto.PointsToRedeem / 2m;
                    var maxDiscount = subTotal * 0.20m;
                    pointsDiscount = Math.Min(requestedDiscount, maxDiscount);
                    pointsRedeemed = (int)(pointsDiscount * 2);
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
                Status = BookingStatus.Pending
            };

            db.Bookings.Add(booking);
            await db.SaveChangesAsync();
            var owner = await db.Users.FindAsync(homestay.OwnerId);
            if (owner != null)
            {
                await notificationService.CreateAsync(
                    userId: owner.UserId,
                    title: "New Booking Request",
                    message: $"You have a new booking request for {homestay.Name}.",
                    type: "booking_created",
                    referenceId: booking.Id
                );
            }
            return Ok(MapBooking(booking));
        }

        [HttpGet("my-bookings")]
        [Authorize(Roles = "tourist")]
        public async Task<ActionResult<IEnumerable<object>>> MyBookings()
        {
            var bookings = await db.Bookings
                .Where(b => b.TouristId == CurrentUserId)
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();

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
            //below is for notification so it wont be confusing for future
            var cancelledHomestay = await db.Homestays.FindAsync(booking.HomestayId);
            if (cancelledHomestay?.OwnerId != null)
            {
                await notificationService.CreateAsync(
                    userId: cancelledHomestay.OwnerId.Value,
                    title: "Booking Cancelled",
                    message: $"A tourist has cancelled their booking at {cancelledHomestay.Name}.",
                    type: "booking_cancelled",
                    referenceId: booking.Id
                );
            }
            return Ok(new { message = "Booking cancelled" });
        }

        [HttpPatch("{id:int}/payment")]
        [Authorize(Roles = "owner")]
        public async Task<IActionResult> MarkPaymentReceived(int id)
        {
            var booking = await db.Bookings.FindAsync(id);
            if (booking is null) return NotFound("Booking not found");

            var homestay = await db.Homestays.FindAsync(booking.HomestayId);
            if (homestay?.OwnerId != CurrentUserId) return Forbid();

            if (booking.Status != BookingStatus.Confirmed && booking.Status != BookingStatus.Completed)
                return BadRequest("Only confirmed or completed bookings can be marked as paid");

            if (booking.PaymentStatus == PaymentStatus.Paid)
                return BadRequest("Payment already recorded");

            booking.PaymentStatus = PaymentStatus.Paid;
            booking.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();
            var paidHomestay = await db.Homestays.FindAsync(booking.HomestayId);
            await notificationService.CreateAsync(
                userId: booking.TouristId,
                title: "Payment Confirmed",
                message: $"Your payment for {paidHomestay?.Name} has been received. Enjoy your stay!",
                type: "payment_received",
                referenceId: booking.Id
            );
            return Ok(new
            {
                bookingId = booking.Id,
                paymentStatus = booking.PaymentStatus.ToString(),
                totalPrice = booking.TotalPrice,
                paymentMethod = booking.PaymentMethod.ToString(),
                message = "Payment marked as received",
            });
        }

        [HttpGet("owner-revenue")]
        [Authorize(Roles = "owner")]
        public async Task<IActionResult> GetOwnerRevenue()
        {
            var myHomestayIds = await db.Homestays
                .Where(h => h.OwnerId == CurrentUserId)
                .Select(h => h.Id)
                .ToListAsync();

            var bookings = await db.Bookings
                .Where(b => myHomestayIds.Contains(b.HomestayId))
                .ToListAsync();

            var paid = bookings.Where(b => b.PaymentStatus == PaymentStatus.Paid).ToList();

            var cashRevenue = paid
                .Where(b => b.PaymentMethod == PaymentMethod.PayAtArrival)
                .Sum(b => b.TotalPrice);

            var khaltiRevenue = paid
                .Where(b => b.PaymentMethod == PaymentMethod.Khalti)
                .Sum(b => b.TotalPrice);

            var pending = bookings
                .Where(b => b.PaymentStatus == PaymentStatus.Unpaid &&
                            (b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.Completed))
                .Sum(b => b.TotalPrice);

            return Ok(new
            {
                totalRevenue = cashRevenue + khaltiRevenue,
                cashRevenue,
                khaltiRevenue,
                pendingRevenue = pending,
                paidBookings = paid.Count,
                totalBookings = bookings.Count,
            });
        }

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

        [HttpPatch("{id:int}/status")]
        [Authorize(Roles = "owner")]
        public async Task<ActionResult> UpdateStatus(int id, [FromBody] UpdateBookingStatusDto dto)
        {
            var booking = await db.Bookings.FindAsync(id);
            if (booking is null) return NotFound();

            var homestay = await db.Homestays.FindAsync(booking.HomestayId);
            if (homestay?.OwnerId != CurrentUserId) return Forbid();

            if (!Enum.TryParse<BookingStatus>(dto.Status, out var newStatus))
                return BadRequest("Invalid status");

            booking.Status = newStatus;
            booking.RejectionReason = dto.RejectionReason;
            booking.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();

            var (title, message, type) = newStatus switch
            {
                BookingStatus.Confirmed => ("Booking Confirmed! ",
                    $"Your booking at {homestay?.Name} has been confirmed.",
                    "booking_confirmed"),
                BookingStatus.Rejected => ("Booking Rejected",
                    $"Your booking at {homestay?.Name} was not accepted.",
                    "booking_rejected"),
                BookingStatus.Completed => ("Stay Completed",
                    $"Your stay at {homestay?.Name} is complete. Please leave a review!",
                    "booking_completed"),
                _ => ("Booking Updated",
                    $"Your booking status has been updated to {newStatus}.",
                    "booking_updated"),
            };

            await notificationService.CreateAsync(
                userId: booking.TouristId,
                title: title,
                message: message,
                type: type,
                referenceId: booking.Id
            );

            return Ok(new { message = $"Booking {dto.Status.ToLower()}" });
        }

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

                User? owner = null;
                if (homestay != null)
                    owner = await db.Users.FindAsync(homestay.OwnerId);

                result.Add(new
                {
                    booking = MapBooking(b),
                    touristName = tourist?.Name ?? $"Deleted User (#{b.TouristId})",
                    touristPhone = tourist?.PhoneNumber ?? "",
                    homestayName = homestay?.Name ?? $"Deleted Homestay (#{b.HomestayId})",
                    ownerName = owner?.Name ?? $"Deleted Owner",
                });
            }
            return Ok(result);
        }
    }
}