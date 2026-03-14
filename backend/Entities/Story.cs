using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Story
    {
        [Key] public int Id { get; set; }
        public int CulturalSiteId { get; set; }
        public string? Title { get; set; }
        public string? StoryType { get; set; }
        public int EstimatedReadTimeMinutes { get; set; }
        public string? FullContent { get; set; }
        public string? HistoricalContext { get; set; }
        public string? CulturalSignificance { get; set; }
        public string[] ImageUrls { get; set; } = Array.Empty<string>();

        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}