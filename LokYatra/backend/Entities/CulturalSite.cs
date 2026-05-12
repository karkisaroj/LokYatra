using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    public class CulturalSite
    {
        [Key] public int Id { get; set; }
        public string? Name { get; set; }
        public string? Category { get; set; }
        public string? District { get; set; }
        public string? Address { get; set; }
        public string? ShortDescription { get; set; }
        public string? HistoricalSignificance { get; set; }
        public string? CulturalImportance { get; set; }
        public decimal? EntryFeeNPR { get; set; }
        public decimal? EntryFeeSAARC { get; set; }
        public string? OpeningTime { get; set; }
        public string? ClosingTime { get; set; }
        public string? BestTimeToVisit { get; set; }
        public bool IsUNESCO { get; set; }

        [Column(TypeName = "text[]")]
        public string[] ImageUrls { get; set; } = Array.Empty<string>();

        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}