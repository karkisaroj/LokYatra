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
        public async Task<IActionResult> GetUsers()
        {
            var results = await _context.RegisterUser
                .Select(x => new {
                    x.UserId,
                    x.Name,
                    x.Email,
                    x.Password,
                    x.Role,
                    x.ProfileImage,
                    x.CreatedAt,
                    x.UpdatedAt
                })
                .ToListAsync();

            return Ok(results);
        }

        [HttpPost("createUser")]
        public async Task<IActionResult> CreateUser([FromBody] RegisterUser user)
        {
           
            _context.RegisterUser.Add(user);
            await _context.SaveChangesAsync();
            return Ok(user);
        }

    
        [HttpPut("editUser")]
        public async Task<IActionResult> EditUser([FromBody] RegisterUser user)
        {
            var rows = await _context.RegisterUser
                .Where(x => x.UserId == user.UserId)
                .ExecuteUpdateAsync(x => x.SetProperty(u => u.Name, user.Name));

            return Ok(user);
        }

      
        [HttpDelete("deleteUser/{userId}")]
        public async Task<IActionResult> DeleteUser(int userId)
        {
            var rows = await _context.RegisterUser
                .Where(x => x.UserId == userId)
                .ExecuteDeleteAsync();

            return Ok(true);
        }
    }
}