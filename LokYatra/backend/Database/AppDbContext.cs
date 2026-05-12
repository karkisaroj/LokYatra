using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Database
{
    public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
    {
        public DbSet<User> Users => Set<User>();
        public DbSet<CulturalSite> CulturalSites => Set<CulturalSite>();
        public DbSet<Story> Stories => Set<Story>();
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<Homestay> Homestays => Set<Homestay>();
        public DbSet<SavedHomestay> SavedHomestays { get; set; }
        public DbSet<SavedSite> SavedSites { get; set; }
        public DbSet<QuizQuestion> QuizQuestions { get; set; }
        public DbSet<QuizAttempt> QuizAttempts { get; set; }
        public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<AppNotification> Notifications { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<SavedHomestay>()
                .HasIndex(s => new { s.UserId, s.HomestayId })
                .IsUnique();

            modelBuilder.Entity<SavedSite>()
                .HasIndex(s => new { s.UserId, s.SiteId })
                .IsUnique();

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(u => u.UserId);
                entity.HasIndex(u => u.Email).IsUnique();
            });

            modelBuilder.Entity<CulturalSite>(entity =>
            {
                entity.Property(e => e.EntryFeeNPR).HasColumnType("decimal(18,2)");
                entity.Property(e => e.EntryFeeSAARC).HasColumnType("decimal(18,2)");
            });
           
            modelBuilder.Entity<Homestay>(entity =>
            {
                entity.Property(e => e.PricePerNight).HasColumnType("decimal(18,2)");
            });
            modelBuilder.Entity<Booking>(entity => {
                entity.Property(b => b.SubTotal).HasColumnType("numeric(18,2)");
                entity.Property(b => b.PointsDiscount).HasColumnType("numeric(18,2)");
                entity.Property(b => b.TotalPrice).HasColumnType("numeric(18,2)");
                entity.Property(b => b.PricePerNight).HasColumnType("numeric(18,2)");
            });
            modelBuilder.Entity<CulturalSite>()
            .Property(e => e.ImageUrls)
            .HasColumnType("text[]");
            // One review per booking
            modelBuilder.Entity<Review>()
                .HasIndex(r => r.BookingId)
                .IsUnique()
                .HasFilter("\"BookingId\" IS NOT NULL");

            // One review per tourist per site
            modelBuilder.Entity<Review>()
                .HasIndex(r => new { r.TouristId, r.SiteId })
                .IsUnique()
                .HasFilter("\"SiteId\" IS NOT NULL");
        }
    }
}