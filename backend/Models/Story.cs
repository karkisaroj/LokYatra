using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Story
    {
        public int Id { get; set; }
        public int CulturalSiteId { get; set; }

        [Required, MaxLength(160)]
        public string Title { get; set; } = default!;

        [Required, MaxLength(40)]
        public string StoryType { get; set; } = default!;

        [Range(1, 1000)]
        public int EstimatedReadTimeMinutes { get; set; }

        [Required, MaxLength(5000)]
        public string FullContent { get; set; } = default!;

        [MaxLength(500)]
        public string? HistoricalContext { get; set; }

        [MaxLength(500)]
        public string? CulturalSignificance { get; set; }

        public CulturalSite? CulturalSite { get; set; }
        public ICollection<StoryImage> Images { get; set; } = new List<StoryImage>();
    }

    public class StoryImage
    {
        public int Id { get; set; }
        public int StoryId { get; set; }

        [Required, MaxLength(300)]
        public string Url { get; set; } = default!;

        [Required, MaxLength(300)]
        public string PublicId { get; set; } = default!;

        public int Position { get; set; } = 0;
        public Story? Story { get; set; }
    }
}