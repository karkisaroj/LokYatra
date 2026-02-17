using backend.Database;
using backend.DTO;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController(IAuthService authService) : ControllerBase
    {
        [HttpPost("register")]
        public async Task<ActionResult<User>> Register(RegisterDto request)
        {
            var user = await authService.RegisterAsync(request);
            if (user == null) return BadRequest("Invalid registration data values.");
            return Ok(user);
        }

        [HttpPost("login")]
        public async Task<ActionResult<TokenResponseDto>> Login(LoginDto request)
        {
            var result = await authService.LoginAsync(request);
            if (result is null) return BadRequest("Invalid Username or password");
            return Ok(result);
        }

        [HttpPost("refresh-token")]
        public async Task<ActionResult<TokenResponseDto>> RefreshToken(RefreshTokenRequestDto request)
        {
            var result = await authService.RefreshTokenAsync(request);
            if (result is null || result.AccessToken is null || result.RefreshToken is null)
                return Unauthorized("Invalid refresh token");
            return Ok(result);
        }

        [Authorize(Roles = "admin")]
        [HttpGet("admin")]
        public IActionResult AdminOnlyEndpoint() => Ok("You are admin!");

        [Authorize(Roles = "tourist")]
        [HttpGet("tourist")]
        public IActionResult TouristOnlyEndpoint() => Ok("You are tourist!");

        [Authorize(Roles = "owner")]
        [HttpGet("owner")]
        public IActionResult OwnerOnlyEndpoint() => Ok("You are owner");

        [Authorize]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            // Try both NameIdentifier and sub
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                              ?? User.FindFirst("sub")?.Value;

            if (userIdClaim is null || !int.TryParse(userIdClaim, out var userId))
            {
                // Token valid but missing user id -> treat as already logged out
                return Ok("Logged out");
            }

            var result = await authService.LogoutAsync(userId);

            // Idempotent: if user not found, still return OK
            if (!result)
            {
                return Ok("Logged out");
            }

            return Ok("Logged out successfully");
        }
    }
}