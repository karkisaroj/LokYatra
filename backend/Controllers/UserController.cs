using backend.Database;
using backend.DTO;
using backend.Entities;      
using backend.Models;      
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController(AppDbContext context, ICloudImageService cloudImageService) : ControllerBase
    {
        private readonly AppDbContext _context = context;
        private readonly ICloudImageService _cloudImageService = cloudImageService;

        private int? GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }
        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound();

            var hasher = new PasswordHasher<User>();
            var result = hasher.VerifyHashedPassword(user, user.PasswordHash, dto.CurrentPassword);
            if (result == PasswordVerificationResult.Failed)
                return BadRequest(new { message = "Current password is incorrect" });

            user.PasswordHash = hasher.HashPassword(user, dto.NewPassword);
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Password changed successfully" });
        }

        
        // ── GET api/User/current user
        [Authorize]
        [HttpGet("current-user")]
        public async Task<ActionResult<UserDto>> GetCurrentUser()
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null) return NotFound();

            return Ok(MapToDto(user));
        }

        // ── PATCH api/User/update-profile 
        [Authorize]
        [HttpPatch("update-profile")]
        public async Task<ActionResult<UserDto>> UpdateProfile([FromForm] UpdateProfileDto dto)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null) return NotFound();

            if (!string.IsNullOrWhiteSpace(dto.Name))
                user.Name = dto.Name;

            if (!string.IsNullOrWhiteSpace(dto.PhoneNumber))
                user.PhoneNumber = dto.PhoneNumber;

            if (dto.ProfileImageFile != null && dto.ProfileImageFile.Length > 0)
            {
                var formFiles = new FormFileCollection { dto.ProfileImageFile };
                var urls = await _cloudImageService.UploadFilesAsync("profile_images", formFiles);
                if (urls.Count > 0)
                    user.ProfileImage = urls[0];
            }

            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(MapToDto(user));
        }

        // ── GET api/User/getUsers ── admin only 
        [Authorize(Roles = "admin")]
        [HttpGet("getUsers")]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
        {
            var users = await _context.Users.ToListAsync();
            return Ok(users.Select(MapToDto));
        }

       
        [Authorize(Roles = "admin")]
        [HttpDelete("deleteUser/{userId}")]
        public async Task<ActionResult> DeleteUser(int userId)
        {
          
            var user = await _context.Users
                .Include(u => u.Homestays)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null)
                return NotFound(new { message = "User not found." });

            if (user.Role == "admin")
                return BadRequest(new { message = "Cannot delete an admin account." });

            var ownedHomestayIds = user.Homestays?
                .Select(h => h.Id)
                .ToList() ?? [];

            var hasPaidBookings = await _context.Bookings.AnyAsync(b =>
                (ownedHomestayIds.Contains(b.HomestayId) || b.TouristId == userId)
                && b.PaymentStatus == PaymentStatus.Paid || b.Status==BookingStatus.Confirmed );

            if (hasPaidBookings)
            {
                return BadRequest(new
                {
                    message =
                        $"Cannot delete '{user.Name}' — they have paid bookings on record. " +
                        "Financial records must be preserved. " +
                        "You can deactivate the account instead.",
                    suggestion = "deactivate",
                });
            }

            var activeBookings = await _context.Bookings
                .Where(b =>
                    (ownedHomestayIds.Contains(b.HomestayId) || b.TouristId == userId)
                    && (b.Status == BookingStatus.Pending ))
                .ToListAsync();

            foreach (var booking in activeBookings)
            {
                booking.Status = BookingStatus.Cancelled;
                booking.UpdatedAt = DateTimeOffset.UtcNow;
            }

            var homestayCount = user.Homestays?.Count ?? 0;
            var userName = user.Name;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"User '{userName}' has been deleted.",
                homestaysDeleted = homestayCount,
            });
        }

       
        [Authorize(Roles = "admin")]
        [HttpPatch("deactivate/{userId}")]
        public async Task<ActionResult> DeactivateUser(int userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null)
                return NotFound(new { message = "User not found." });
            if (user.Role == "admin")
                return BadRequest(new { message = "Cannot deactivate an admin." });

            user.IsActive = false;
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = $"'{user.Name}' has been deactivated. They can no longer log in." });
        }

     
        private static UserDto MapToDto(User u) => new()
        {
            UserId = u.UserId,
            Name = u.Name,
            Email = u.Email,
            Role = u.Role,
            PhoneNumber = u.PhoneNumber,
            IsActive = u.IsActive,
            ProfileImage = u.ProfileImage,
            CreatedAt = u.CreatedAt,
        };
    }
}