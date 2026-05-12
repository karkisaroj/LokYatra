using Microsoft.AspNetCore.Http;

namespace backend.DTO
{
    public class UpdateProfileDto
    {
        public string? Name { get; set; }
        public string? PhoneNumber { get; set; }
        public IFormFile? ProfileImageFile { get; set; }
    }
}