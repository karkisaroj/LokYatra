using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    [Table("QuizAttempts")]
    public class QuizAttempt
    {
        [Key]
        public int Id { get; set; }
        public int UserId { get; set; }
        public int Score { get; set; }
        public int TotalQuestions { get; set; }
        public int PointsEarned { get; set; }
        public DateTimeOffset AttemptedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}