namespace backend.DTO
{
    public class QuizQuestionDto
    {
        public string Question { get; set; } = string.Empty;
        public string[] Options { get; set; } = Array.Empty<string>();
        public int CorrectIndex { get; set; }
        public string? Category { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
