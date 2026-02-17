using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Database
{
    public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
    {
        public DbSet<User> Users => Set<User>();
        public DbSet<CulturalSite> CulturalSites => Set<CulturalSite>();
        public DbSet<Story> Stories => Set<Story>();
        public DbSet<Homestay> Homestays => Set<Homestay>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

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
        }
    }
}