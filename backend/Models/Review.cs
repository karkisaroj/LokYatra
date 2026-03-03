using backend.Entities;
using backend.Models;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    public class Review
    {
        [Key]
        public int Id { get; set; }

        public int TouristId { get; set; }
        [ForeignKey(nameof(TouristId))]
        public User? Tourist { get; set; }

        public int? HomestayId { get; set; }
        [ForeignKey(nameof(HomestayId))]
        public Homestay? Homestay { get; set; }

        public int? BookingId { get; set; }

        public int? SiteId { get; set; }
        [ForeignKey(nameof(SiteId))]
        public CulturalSite? Site { get; set; }

        [Range(1, 5)]
        public int Rating { get; set; }

        public string? Comment { get; set; }

        public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
        public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}