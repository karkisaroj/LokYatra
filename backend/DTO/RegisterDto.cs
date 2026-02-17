namespace backend.DTO
{
    public class RegisterDto
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;

        public string? Role { get; set; } = "tourist";
        public string? PhoneNumber { get; set; }
        public string? ProfileImage { get; set; }
    }
}
