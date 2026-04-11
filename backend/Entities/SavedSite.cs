using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    public class SavedSite
    {
        [Key]
        public int Id { get; set; }

        public int UserId { get; set; }
        [ForeignKey(nameof(UserId))]
        public User? User { get; set; }

        public int SiteId { get; set; }
        [ForeignKey(nameof(SiteId))]
        public CulturalSite? Site { get; set; }

        public DateTimeOffset SavedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}
