using System.ComponentModel.DataAnnotations;

namespace backend.DTO
{
    public class CreateHomestayReviewDto
    {
        [Required]
        public int BookingId { get; set; }

        [Required]
        public int HomestayId { get; set; }

        [Required, Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }
    }

    public class CreateSiteReviewDto
    {
        [Required]
        public int SiteId { get; set; }

        [Required, Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }
    }

    public class UpdateReviewDto
    {
        [Required, Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }
    }
}