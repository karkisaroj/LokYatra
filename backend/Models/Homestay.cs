using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    public class Homestay
    {
        [Key] public int Id { get; set; }

        // Links to the owner (User) who created this homestay
        public int OwnerId { get; set; }

        // Links to a nearby CulturalSite
        public int? NearCulturalSiteId { get; set; }
        [ForeignKey(nameof(NearCulturalSiteId))]
        public CulturalSite? NearCulturalSite { get; set; }

        // Basic Information
        public string Name { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;        
        public decimal PricePerNight { get; set; }

        // Cultural & Heritage Information
        public string BuildingHistory { get; set; } = string.Empty;
        public string? CulturalSignificance { get; set; }
        public string TraditionalFeatures { get; set; } = string.Empty;
        public string CulturalExperiences { get; set; } = string.Empty;

        // Details
        public int NumberOfRooms { get; set; }
        public int MaxGuests { get; set; }
        public int Bathrooms { get; set; }

        // Amenities stored as text[] in PostgreSQL (like ImageUrls)
        [Column(TypeName = "text[]")]
        public string[] Amenities { get; set; } = [];

        // Images stored as text[] in PostgreSQL
        [Column(TypeName = "text[]")]
        public string[] ImageUrls { get; set; } = [];

        // Visibility toggle - owner can pause/unpause
        public bool IsVisible { get; set; } = true;

        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}