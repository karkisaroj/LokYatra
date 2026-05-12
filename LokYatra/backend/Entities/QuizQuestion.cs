// Models/QuizQuestion.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    [Table("QuizQuestions")]
    public class QuizQuestion
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string Question { get; set; } = string.Empty;
        [Required]
        public string OptionsJson { get; set; } = "[]";
        public int CorrectIndex { get; set; }
        public string Category { get; set; } = "General";
        public bool IsActive { get; set; } = true;
        public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
        public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}