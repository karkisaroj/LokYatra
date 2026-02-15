using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class CulturalSite
    {
        public int Id { get; set; }

        [Required, MaxLength(120)]
        public string Name { get; set; } = default!;

        [Required, MaxLength(60)]
        public string Category { get; set; } = default!;

        [Required, MaxLength(80)]
        public string District { get; set; } = default!;

        [Required, MaxLength(160)]
        public string Address { get; set; } = default!;

        [Required, MaxLength(500)]
        public string ShortDescription { get; set; } = default!;

        [MaxLength(300)]
        public string? HistoricalSignificance { get; set; }

        [MaxLength(300)]
        public string? CulturalImportance { get; set; }

        public decimal? EntryFeeNPR { get; set; }
        public decimal? EntryFeeSAARC { get; set; }

        [MaxLength(5)]
        public string? OpeningTime { get; set; }

        [MaxLength(5)]
        public string? ClosingTime { get; set; }

        [MaxLength(120)]
        public string? BestTimeToVisit { get; set; }

        public bool IsUNESCO { get; set; }

        public ICollection<CulturalSiteImage> Images { get; set; } = new List<CulturalSiteImage>();
        public ICollection<Story> Stories { get; set; } = new List<Story>();
    }

    public class CulturalSiteImage
    {
        public int Id { get; set; }
        public int CulturalSiteId { get; set; }

        [Required, MaxLength(300)]
        public string Url { get; set; } = default!;

        [Required, MaxLength(300)]
        public string PublicId { get; set; } = default!;

        public int Position { get; set; } = 0; // optional ordering
        public CulturalSite? CulturalSite { get; set; }
    }
}