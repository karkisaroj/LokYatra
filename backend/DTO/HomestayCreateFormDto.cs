using System.ComponentModel.DataAnnotations;

namespace backend.DTO
{
    public class HomestayCreateFormDto
    {
        [Required] public string Name { get; set; } = string.Empty;
        [Required] public string Location { get; set; } = string.Empty;
        [Required, MaxLength(500)] public string Description { get; set; } = string.Empty;
        [Required] public string Category { get; set; } = string.Empty;
        [Required] public decimal PricePerNight { get; set; }

        public int? NearCulturalSiteId { get; set; }

        [Required, MaxLength(800)] public string BuildingHistory { get; set; } = string.Empty;
        [MaxLength(600)] public string? CulturalSignificance { get; set; }
        [Required, MaxLength(500)] public string TraditionalFeatures { get; set; } = string.Empty;
        [Required, MaxLength(500)] public string CulturalExperiences { get; set; } = string.Empty;

        [Required] public int NumberOfRooms { get; set; }
        [Required] public int MaxGuests { get; set; }
        [Required] public int Bathrooms { get; set; }

        // Amenities come as comma-separated string from the form and are like these: "Free WiFi,Parking,Hot Water"
        public string? Amenities { get; set; }

        // Images come from Request.Form.Files
    }
}