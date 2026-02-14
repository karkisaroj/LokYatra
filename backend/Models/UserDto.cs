namespace backend.Models
{
    public class UserDto
    {
        public int UserId { get; set; }    
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = "tourist";
        public string? PhoneNumber { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public string ProfileImage { get; set; } = string.Empty;
        public DateTimeOffset CreatedAt { get; set; }
    }
}
