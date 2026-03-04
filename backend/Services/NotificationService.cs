using backend.Database;
using backend.Models;

namespace backend.Services
{
    public class NotificationService(AppDbContext db)
    {
        public async Task CreateAsync(
            int userId,
            string title,
            string message,
            string type,
            int? referenceId = null)
        {
            db.Notifications.Add(new AppNotification
            {
                UserId = userId,
                Title = title,
                Message = message,
                Type = type,
                ReferenceId = referenceId,
                IsRead = false,
                CreatedAt = DateTimeOffset.UtcNow,
            });
            await db.SaveChangesAsync();
        }
    }
}