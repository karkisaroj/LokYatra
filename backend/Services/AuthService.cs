using backend.Database;
using backend.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace backend.Services
{
    public class AuthService(AppDbContext context,IConfiguration configuration) : IAuthService
    {
        public async Task<TokenResponseDto?> LoginAsync(LoginDto request)
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
            {
                return null;
            }

            if (new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
            {
                return null;
            }
            
            return await CreateTokenResponse(user);

        }

        private async Task<TokenResponseDto> CreateTokenResponse(User user)
        {
            return new TokenResponseDto { AccessToken = CreateToken(user), RefreshToken = await GenerateAndSaveRefreshTokenAsync(user) };
        }

        public async Task<User?> RegisterAsync(RegisterDto request)
        {
            if (await context.Users.AnyAsync(u => u.Email == request.Email))
            {
                return null;
            }
            else if (string.IsNullOrWhiteSpace(request.Role))
                return null;
            else if (request.Role != "tourist" && request.Role != "owner")
                return null;

            var user = new User
            {
                Email = request.Email,
                Name = request.Name,
                Role = request.Role,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };
            user.PasswordHash = new PasswordHasher<User>().HashPassword(user, request.Password);
            context.Users.Add(user);
            await context.SaveChangesAsync();

            return user;
        }
        public async Task<TokenResponseDto?> RefreshTokenAsync(RefreshTokenRequestDto request)
        {
            var user = await ValidateRefreshTokenAsync(request.RefreshToken);
            if (user is null)
            {
                return null;
            }
            return await CreateTokenResponse(user);

        }
        private async Task<User?> ValidateRefreshTokenAsync(string refreshToken)
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.RefreshToken == refreshToken);
            if(user is null|| user.RefreshToken!=refreshToken|| user.RefreshTokenExpiryTime<=DateTime.UtcNow
                )
            {
                return null;
            }
            return user;
        }

        private static string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng=RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);    
        }

        

        private async Task<string> GenerateAndSaveRefreshTokenAsync(User user)
        {
            var refreshToken= GenerateRefreshToken();
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
            await context.SaveChangesAsync();
            return refreshToken;
        }

        private string CreateToken(User user)
        {
            var claims = new List<Claim> {
                new(ClaimTypes.NameIdentifier,user.UserId.ToString()),
                new(ClaimTypes.Email,user.Email),
                new("role",user.Role)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration.GetValue<string>("AppSettings:Token")!));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512);
            
            var token = new JwtSecurityToken(
                issuer: configuration.GetValue<string>("AppSettings:Issuer"),
                audience: configuration.GetValue<string>("AppSettings:Audience"),
                claims: claims,
                expires: DateTime.UtcNow.AddDays(7),
                signingCredentials: creds
                );
            return new JwtSecurityTokenHandler().WriteToken(token);

        }

        public async Task<IEnumerable<User>> getUserAsync()
        {
            return await context.Users.ToListAsync();
        }
    }
}
