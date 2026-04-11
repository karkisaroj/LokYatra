using backend.Database;
using backend.DTO;
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
            Console.WriteLine($"[LOGIN] Attempt for email: {request.Email}");

            var user = await context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
            {
                Console.WriteLine("[LOGIN] User not found");
                return null;
            }

            var verify = new PasswordHasher<User>()
                .VerifyHashedPassword(user, user.PasswordHash, request.Password);

            Console.WriteLine($"[LOGIN] Password verify result: {verify}");

            if (verify == PasswordVerificationResult.Failed)
            {
                Console.WriteLine("[LOGIN] Password failed");
                return null;
            }

            user.IsActive = true;
            await context.SaveChangesAsync();
            Console.WriteLine("[LOGIN] Success, token creating...");
            return await CreateTokenResponse(user);
        }

        private async Task<TokenResponseDto> CreateTokenResponse(User user)
        {
            return new TokenResponseDto { AccessToken = CreateToken(user), RefreshToken = await GenerateAndSaveRefreshTokenAsync(user) };
        }

        public async Task<(User? User, string? Error)> RegisterAsync(RegisterDto request)
        {
            if (await context.Users.AnyAsync(u => u.Email == request.Email))
                return (null, "An account with this email already exists.");

            if (string.IsNullOrWhiteSpace(request.Role) || (request.Role != "tourist" && request.Role != "owner"))
                return (null, "Invalid role. Must be 'tourist' or 'owner'.");

            if (string.IsNullOrEmpty(request.Password) || request.Password.Length < 8)
                return (null, "Password must be at least 8 characters.");
            if (!request.Password.Any(char.IsUpper))
                return (null, "Password must include at least one uppercase letter.");
            if (!request.Password.Any(char.IsLower))
                return (null, "Password must include at least one lowercase letter.");
            if (!request.Password.Any(char.IsDigit))
                return (null, "Password must include at least one number.");
            if (!request.Password.Any(c => "!@#$%^&*(),.?\":{}|<>_-".Contains(c)))
                return (null, "Password must include at least one special character.");

            var user = new User
            {
                Email = request.Email,
                Name = request.Name,
                Role = request.Role,
                PhoneNumber = request.PhoneNumber,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };
            user.PasswordHash = new PasswordHasher<User>().HashPassword(user, request.Password);
            context.Users.Add(user);
            await context.SaveChangesAsync();

            return (user, null);
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

        public async Task<IEnumerable<User>> GetUserAsync()
        {
            return await context.Users.ToListAsync();
        }

        public async Task<bool> LogoutAsync(int userId)
        {
            var user = await context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user is null)
            {
                return false;
            }

            user.IsActive = false;
            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null;
            await context.SaveChangesAsync();
            return true;
        }
    }
}
