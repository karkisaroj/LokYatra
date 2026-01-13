using backend.Database;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
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
            if (user == null) {
                return BadRequest("Invalid registration data values.");
            }

            return Ok(user);
        }
        [HttpPost("login")]
        public async Task<ActionResult<TokenResponseDto>> Login(LoginDto request)
        {
            var result = await authService.LoginAsync(request);
            if (result is null)
            {
                return BadRequest("Invalid Username or password");
            }
            return Ok(result);
        }

        [HttpPost("refresh-token")]
        public async Task<ActionResult<TokenResponseDto>> RefreshToken(RefreshTokenRequestDto request)
        {
            var result = await authService.RefreshTokenAsync(request);
            if (result is null || result.AccessToken is null || result.RefreshToken is null)
                {
                    return Unauthorized("Invalid refresh token");
                }
            return Ok(result);
        }


        [Authorize(Roles ="admin")]
        [HttpGet("admin")]
        public IActionResult AdminOnlyEndpoint()
        {
            return Ok("You are admin!");
        }

        [Authorize(Roles ="tourist")]
        [HttpGet("tourist")]
        public IActionResult TouristOnlyEndpoint()
        {
            return Ok("You are tourist!");
        }

        [Authorize(Roles ="owner")]
        [HttpGet("owner")]
        public IActionResult OwnerOnlyEndpoint()
        {
            return Ok("You are owner");
        }
    }
}
