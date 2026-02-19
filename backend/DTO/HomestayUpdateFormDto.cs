using System.ComponentModel.DataAnnotations;

namespace backend.DTO
{
    public class HomestayUpdateFormDto
    {
        public string? Name { get; set; }
        public string? Location { get; set; }
        public string? Description { get; set; }
        public string? Category { get; set; }

        [Required]  // or make optional if you want
        public decimal PricePerNight { get; set; }

        public string? BuildingHistory { get; set; }
        public string? CulturalSignificance { get; set; }
        public string? TraditionalFeatures { get; set; }
        public string? CulturalExperiences { get; set; }

        [Required]
        public int NumberOfRooms { get; set; }

        [Required]
        public int MaxGuests { get; set; }

        [Required]
        public int Bathrooms { get; set; }

        public int? NearCulturalSiteId { get; set; }
        public bool? IsVisible { get; set; }  // optional toggle

        // Comma-separated string from frontend
        public string? Amenities { get; set; }
    }
}