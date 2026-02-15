using System.ComponentModel.DataAnnotations;

namespace backend.DTOs
{
    public class CreateStoryDto
    {
        [Required] public int CulturalSiteId { get; set; }
        [Required, MaxLength(160)] public string Title { get; set; } = default!;
        [Required, MaxLength(40)] public string StoryType { get; set; } = default!;
        [Range(1, 1000)] public int EstimatedReadTimeMinutes { get; set; }
        [Required, MaxLength(5000)] public string FullContent { get; set; } = default!;
        [MaxLength(500)] public string? HistoricalContext { get; set; }
        [MaxLength(500)] public string? CulturalSignificance { get; set; }
    }

    public class StoryDto
    {
        public int Id { get; set; }
        public int CulturalSiteId { get; set; }
        public string Title { get; set; } = default!;
        public string StoryType { get; set; } = default!;
        public int EstimatedReadTimeMinutes { get; set; }
        public string FullContent { get; set; } = default!;
        public string? HistoricalContext { get; set; }
        public string? CulturalSignificance { get; set; }
        public List<string> ImageUrls { get; set; } = new();
    }
}