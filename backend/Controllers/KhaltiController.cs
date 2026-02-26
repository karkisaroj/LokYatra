using backend.Database;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Json;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class KhaltiController(AppDbContext db, IConfiguration config, IHttpClientFactory http)
        : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        private string SecretKey => config["Khalti:SecretKey"] ?? "";
        private string ReturnUrl => config["Khalti:ReturnUrl"] ?? "lokyatra://khalti-return";

        // Live/Sandbox Khalti API endpoint
        private const string KhaltiBaseUrl = "https://a.khalti.com/api/v2/epayment/";

        // POST api/Khalti/initiate/{bookingId}
        [HttpPost("initiate/{bookingId:int}")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> Initiate(int bookingId)
        {
            var booking = await db.Bookings.FindAsync(bookingId);
            if (booking == null)
                return NotFound(new { message = "Booking not found" });
            if (booking.TouristId != CurrentUserId)
                return Forbid();
            if (booking.PaymentMethod != PaymentMethod.Khalti)
                return BadRequest(new { message = "This booking uses cash payment, not Khalti" });
            if (booking.Status != BookingStatus.Confirmed)
                return BadRequest(new { message = "Booking must be confirmed by owner before payment" });
            if (booking.PaymentStatus == PaymentStatus.Paid)
                return BadRequest(new { message = "This booking is already paid" });

            var homestay = await db.Homestays.FindAsync(booking.HomestayId);
            var tourist = await db.Users.FindAsync(CurrentUserId);

            // Khalti requires amount in PAISA (Rs 1 = 100 paisa)
            var amountPaisa = (long)(booking.TotalPrice * 100);

            var payload = new
            {
                return_url = ReturnUrl,
                website_url = "https://lokyatra.app",
                amount = amountPaisa,
                purchase_order_id = $"LY-{bookingId}-{DateTime.UtcNow.Ticks}",
                purchase_order_name = $"Booking at {homestay?.Name ?? "Homestay"}",
                customer_info = new
                {
                    name = tourist?.Name ?? "Tourist",
                    email = tourist?.Email ?? "",
                    phone = tourist?.PhoneNumber ?? "",
                },
                amount_breakdown = new[]
                {
                    new { label = "Room Charges", amount = amountPaisa }
                },
                product_details = new[]
                {
                    new
                    {
                        identity    = bookingId.ToString(),
                        name        = homestay?.Name ?? "Homestay Booking",
                        total_price = amountPaisa,
                        quantity    = 1,
                        unit_price  = amountPaisa,
                    }
                },
            };

            var client = http.CreateClient();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Key", SecretKey);

            var json = JsonSerializer.Serialize(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            HttpResponseMessage res;
            try
            {
                res = await client.PostAsync($"{KhaltiBaseUrl}initiate/", content);
            }
            catch (Exception ex)
            {
                return StatusCode(502, new { message = "Could not reach Khalti", error = ex.Message });
            }

            var body = await res.Content.ReadAsStringAsync();

            if (!res.IsSuccessStatusCode)
                return StatusCode((int)res.StatusCode, new { message = "Khalti initiation failed", detail = body });

            var result = JsonSerializer.Deserialize<JsonElement>(body);
            var pidx = result.GetProperty("pidx").GetString() ?? "";
            var paymentUrl = result.GetProperty("payment_url").GetString() ?? "";

            booking.KhaltiPidx = pidx;
            booking.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();

            return Ok(new { pidx, paymentUrl, bookingId, amount = booking.TotalPrice });
        }

        // POST api/Khalti/verify
        // Body: { "pidx": "abc123" }
        [HttpPost("verify")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> Verify([FromBody] KhaltiVerifyDto dto)
        {
            var booking = await db.Bookings
                .FirstOrDefaultAsync(b => b.KhaltiPidx == dto.Pidx);

            if (booking == null)
                return NotFound(new { message = "No booking found for this payment" });
            if (booking.TouristId != CurrentUserId)
                return Forbid();

            // Idempotent — already paid, return success
            if (booking.PaymentStatus == PaymentStatus.Paid)
                return Ok(new
                {
                    message = "Already paid",
                    alreadyPaid = true,
                    bookingId = booking.Id,
                    totalPaid = booking.TotalPrice,
                });

            var client = http.CreateClient();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Key", SecretKey);

            var lookupPayload = JsonSerializer.Serialize(new { pidx = dto.Pidx });
            var content = new StringContent(lookupPayload, Encoding.UTF8, "application/json");

            HttpResponseMessage res;
            try
            {
                res = await client.PostAsync($"{KhaltiBaseUrl}lookup/", content);
            }
            catch (Exception ex)
            {
                return StatusCode(502, new { message = "Could not reach Khalti", error = ex.Message });
            }

            var body = await res.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<JsonElement>(body);
            var status = result.GetProperty("status").GetString() ?? "";

            if (status != "Completed")
                return BadRequest(new { message = "Payment not completed", khaltiStatus = status });

            booking.PaymentStatus = PaymentStatus.Paid;
            booking.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();

            return Ok(new
            {
                message = "Payment verified successfully",
                bookingId = booking.Id,
                paymentStatus = booking.PaymentStatus.ToString(),
                totalPaid = booking.TotalPrice,
            });
        }
    }

    public class KhaltiVerifyDto
    {
        public string Pidx { get; set; } = string.Empty;
    }
}