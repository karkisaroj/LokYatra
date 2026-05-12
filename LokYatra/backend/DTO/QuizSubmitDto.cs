using backend.Controllers;

namespace backend.DTO
{
    public class QuizSubmitDto
    {
        public QuizAnswer[] Answers { get; set; } = [];
    }
}
