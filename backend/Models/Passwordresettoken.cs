using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    [Table("PasswordResetTokens")]
    public class PasswordResetToken
    {
        [Key]
        public int Id { get; set; }

        public int UserId { get; set; }

        [Required]
        public string Token { get; set; } = string.Empty;

        public DateTimeOffset ExpiresAt { get; set; }

        public bool IsUsed { get; set; } = false;

        public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}