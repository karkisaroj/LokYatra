using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Database
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users => Set<User>();
        public DbSet<CulturalSite> CulturalSites => Set<CulturalSite>();
        public DbSet<Story> Stories => Set<Story>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Ensure EF knows UserId is the primary key and Email is unique
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(u => u.UserId);
                entity.HasIndex(u => u.Email).IsUnique();
            });

            // Configure CulturalSite entity
            modelBuilder.Entity<CulturalSite>(entity =>
            {
                entity.Property(e => e.EntryFeeNPR)
                    .HasColumnType("decimal(18,2)");
                
                entity.Property(e => e.EntryFeeSAARC)
                    .HasColumnType("decimal(18,2)");
            });

            modelBuilder.Entity<Story>(entity =>
            {
                // No explicit column type mapping here
            });
        }
    }
}