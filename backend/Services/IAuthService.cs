using backend.Models;

namespace backend.Services
{
    public interface IAuthService
    {
        Task<User?> RegisterAsync(RegisterDto request);

        Task<IEnumerable<User>> getUserAsync();
        Task<TokenResponseDto?> LoginAsync(LoginDto request);
        Task<TokenResponseDto?> RefreshTokenAsync(RefreshTokenRequestDto request);
    }
}
