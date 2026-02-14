using backend.Database;
using backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController(AppDbContext context) : ControllerBase
    {
        private readonly AppDbContext _context = context;

        [HttpGet("getUsers")]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
        {
            var users = await _context.Users.ToListAsync();
            var DtoList = users.Select(u => new UserDto
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
            return Ok(DtoList);
        }



        [HttpDelete("deleteUser/{userId}")]
        public async Task<ActionResult<UserDto>> DeleteUser(int userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user == null) return NotFound();

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new UserDto { UserId = user.UserId, Name = user.Name, Email = user.Email, Role = user.Role });
        }
    }
    }