using backend.Database;
using backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly AppDbContext _context;
        public UserController(AppDbContext context) => _context = context;


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
                ProfileImage = u.ProfileImage,
                CreatedAt = u.CreatedAt,
            }).ToList();
            return Ok(DtoList);
        }
    }
}