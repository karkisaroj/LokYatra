using backend.Database;
using backend.DTO;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
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

        // Helper: get current user's ID from JWT
        private int? GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }

        // GET api/User/me — get current logged-in user's profile
        [Authorize]
        [HttpGet("me")]
        public async Task<ActionResult<UserDto>> GetMe()
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null) return NotFound();

            return Ok(new UserDto
            {
                UserId = user.UserId,
                Name = user.Name,
                Email = user.Email,
                Role = user.Role,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive,
                ProfileImage = user.ProfileImage,
                CreatedAt = user.CreatedAt,
            });
        }

        // PATCH api/User/update-profile — update name, phone, profile image
        [Authorize]
        [HttpPatch("update-profile")]
        public async Task<ActionResult<UserDto>> UpdateProfile([FromForm] UpdateProfileDto dto)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null) return NotFound();

            // Update name if provided
            if (!string.IsNullOrWhiteSpace(dto.Name))
                user.Name = dto.Name;

            // Update phone if provided
            if (!string.IsNullOrWhiteSpace(dto.PhoneNumber))
                user.PhoneNumber = dto.PhoneNumber;

            // Upload new profile image if provided
            if (dto.ProfileImageFile != null && dto.ProfileImageFile.Length > 0)
            {
                var formFiles = new FormFileCollection { dto.ProfileImageFile };
                var urls = await _cloudImageService.UploadFilesAsync("profile_images", formFiles);
                if (urls.Count > 0)
                    user.ProfileImage = urls[0];
            }

            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new UserDto
            {
                UserId = user.UserId,
                Name = user.Name,
                Email = user.Email,
                Role = user.Role,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive,
                ProfileImage = user.ProfileImage,
                CreatedAt = user.CreatedAt,
            });
        }

        // GET api/User/getUsers — admin only
        [Authorize(Roles = "admin")]
        [HttpGet("getUsers")]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
        {
            var users = await _context.Users.ToListAsync();
            var dtoList = users.Select(u => new UserDto
            {
                UserId = u.UserId,
                Name = u.Name,
                Email = u.Email,
                Role = u.Role,
                PhoneNumber = u.PhoneNumber,
                IsActive = u.IsActive,
                ProfileImage = u.ProfileImage,
                CreatedAt = u.CreatedAt,
            }).ToList();
            return Ok(dtoList);
        }

        // DELETE api/User/deleteUser/{userId} — admin only
        [Authorize(Roles = "admin")]
        [HttpDelete("deleteUser/{userId}")]
        public async Task<ActionResult<UserDto>> DeleteUser(int userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null) return NotFound();

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new UserDto
            {
                UserId = user.UserId,
                Name = user.Name,
                Email = user.Email,
                Role = user.Role
            });
        }
    }
}