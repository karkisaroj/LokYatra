using backend.DTO;
using backend.Models;

namespace backend.Services
{
    public interface IAuthService
    {
        Task<User?> RegisterAsync(RegisterDto request);

        Task<IEnumerable<User>> GetUserAsync();
        Task<TokenResponseDto?> LoginAsync(LoginDto request);
        Task<TokenResponseDto?> RefreshTokenAsync(RefreshTokenRequestDto request);
        Task<bool> LogoutAsync(int userId);
    }
}
