using System.ComponentModel.DataAnnotations;

namespace backend.DTOs
{
    public class CreateCulturalSiteDto
    {
        [Required, MaxLength(120)] public string Name { get; set; } = default!;
        [Required, MaxLength(60)] public string Category { get; set; } = default!;
        [Required, MaxLength(80)] public string District { get; set; } = default!;
        [Required, MaxLength(160)] public string Address { get; set; } = default!;
        [Required, MaxLength(500)] public string ShortDescription { get; set; } = default!;
        [MaxLength(300)] public string? HistoricalSignificance { get; set; }
        [MaxLength(300)] public string? CulturalImportance { get; set; }
        public decimal? EntryFeeNPR { get; set; }
        public decimal? EntryFeeSAARC { get; set; }
        [MaxLength(5)] public string? OpeningTime { get; set; }
        [MaxLength(5)] public string? ClosingTime { get; set; }
        [MaxLength(120)] public string? BestTimeToVisit { get; set; }
        public bool IsUNESCO { get; set; }
    }

    public class CulturalSiteDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string Category { get; set; } = default!;
        public string District { get; set; } = default!;
        public string Address { get; set; } = default!;
        public string ShortDescription { get; set; } = default!;
        public string? HistoricalSignificance { get; set; }
        public string? CulturalImportance { get; set; }
        public decimal? EntryFeeNPR { get; set; }
        public decimal? EntryFeeSAARC { get; set; }
        public string? OpeningTime { get; set; }
        public string? ClosingTime { get; set; }
        public string? BestTimeToVisit { get; set; }
        public bool IsUNESCO { get; set; }
        public List<string> ImageUrls { get; set; } = new();
        public List<int> StoryIds { get; set; } = new();
    }
}