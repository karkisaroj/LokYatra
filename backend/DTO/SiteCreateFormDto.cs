using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class SiteCreateFormDto
    {
        [Required] public string Name { get; set; } = string.Empty;
        [Required] public string Category { get; set; } = string.Empty;
        [Required] public string District { get; set; } = string.Empty;
        [Required] public string Address { get; set; } = string.Empty;
        [Required] public string ShortDescription { get; set; } = string.Empty;

        public string? HistoricalSignificance { get; set; }
        public string? CulturalImportance { get; set; }
        public decimal? EntryFeeNPR { get; set; }
        public decimal? EntryFeeSAARC { get; set; }

        public string? OpeningTime { get; set; }
        public string? ClosingTime { get; set; }
        public string? BestTimeToVisit { get; set; }

        public bool IsUNESCO { get; set; } = false;
        // Images come from Request.Form.Files
    }
}