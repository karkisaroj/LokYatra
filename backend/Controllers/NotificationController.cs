using backend.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NotificationController(AppDbContext db) : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);


        [HttpGet]
        public async Task<IActionResult> GetMyNotifications()
        {
            var notifications = await db.Notifications
                .Where(n => n.UserId == CurrentUserId)
                .OrderByDescending(n => n.CreatedAt)
                .Select(n => new
                {
                    id = n.Id,
                    title = n.Title,
                    message = n.Message,
                    type = n.Type,
                    referenceId = n.ReferenceId,
                    isRead = n.IsRead,
                    createdAt = n.CreatedAt,
                })
                .ToListAsync();

            var unreadCount = notifications.Count(n => !n.isRead);

            return Ok(new { notifications, unreadCount });
        }


        [HttpPatch("{id:int}/read")]
        public async Task<IActionResult> MarkRead(int id)
        {
            var notification = await db.Notifications
                .FirstOrDefaultAsync(n => n.Id == id && n.UserId == CurrentUserId);

            if (notification is null) return NotFound();

            notification.IsRead = true;
            await db.SaveChangesAsync();
            return Ok(new { message = "Marked as read" });
        }


        [HttpPatch("read-all")]
        public async Task<IActionResult> MarkAllRead()
        {
            var unread = await db.Notifications
                .Where(n => n.UserId == CurrentUserId && !n.IsRead)
                .ToListAsync();

            foreach (var n in unread) n.IsRead = true;
            await db.SaveChangesAsync();

            return Ok(new { message = $"{unread.Count} notifications marked as read" });
        }


        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var notification = await db.Notifications
                .FirstOrDefaultAsync(n => n.Id == id && n.UserId == CurrentUserId);

            if (notification is null) return NotFound();

            db.Notifications.Remove(notification);
            await db.SaveChangesAsync();
            return Ok(new { message = "Deleted" });
        }


        [HttpDelete("clear-all")]
        public async Task<IActionResult> ClearAll()
        {
            var all = await db.Notifications
                .Where(n => n.UserId == CurrentUserId)
                .ToListAsync();

            db.Notifications.RemoveRange(all);
            await db.SaveChangesAsync();
            return Ok(new { message = "All notifications cleared" });
        }
    }
}