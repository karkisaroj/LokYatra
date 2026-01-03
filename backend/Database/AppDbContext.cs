using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Database
{
    public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
        {
            public DbSet<User> Users { get; set; }
        }

        
    }
