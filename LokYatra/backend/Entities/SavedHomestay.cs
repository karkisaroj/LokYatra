// backend/Models/SavedHomestay.cs
// Add to your Models folder.
// Then add DbSet<SavedHomestay> SavedHomestays in AppDbContext.
// Run: dotnet ef migrations add AddSavedHomestays && dotnet ef database update

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    public class SavedHomestay
    {
        [Key]
        public int Id { get; set; }

        public int UserId { get; set; }
        [ForeignKey(nameof(UserId))]
        public User? User { get; set; }

        public int HomestayId { get; set; }
        [ForeignKey(nameof(HomestayId))]
        public Homestay? Homestay { get; set; }

        public DateTimeOffset SavedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}