// Controllers/QuizController.cs
using backend.Database;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class QuizController(AppDbContext db) : ControllerBase
    {
        private int CurrentUserId => int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        private const int PointsPerCorrect = 10;
        private const int QuestionsPerQuiz = 10;
        private const int MaxAttemptsPerDay = 3;

        private static object MapQuestion(QuizQuestion q, bool includeAnswer = false) => new
        {
            id = q.Id,
            question = q.Question,
            options = JsonSerializer.Deserialize<string[]>(q.OptionsJson) ?? Array.Empty<string>(),
            correctIndex = includeAnswer ? (int?)q.CorrectIndex : null,
            category = q.Category,
            isActive = q.IsActive,
            createdAt = q.CreatedAt,
        };

        // ── ADMIN: Get all questions (with answers) ────────────────────────────
        [HttpGet("admin/questions")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> AdminGetQuestions()
        {
            var list = await db.QuizQuestions
                .OrderByDescending(q => q.CreatedAt)
                .ToListAsync();
            return Ok(list.Select(q => MapQuestion(q, includeAnswer: true)));
        }

        // ── ADMIN: Add question ────────────────────────────────────────────────
        [HttpPost("admin/questions")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> AdminAdd([FromBody] QuizQuestionDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Question))
                return BadRequest(new { message = "Question text is required" });
            if (dto.Options == null || dto.Options.Length < 2)
                return BadRequest(new { message = "At least 2 options required" });
            if (dto.CorrectIndex < 0 || dto.CorrectIndex >= dto.Options.Length)
                return BadRequest(new { message = "CorrectIndex out of range" });

            var q = new QuizQuestion
            {
                Question = dto.Question.Trim(),
                OptionsJson = JsonSerializer.Serialize(dto.Options),
                CorrectIndex = dto.CorrectIndex,
                Category = (dto.Category ?? "General").Trim(),
                IsActive = true,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };
            db.QuizQuestions.Add(q);
            await db.SaveChangesAsync();
            return Ok(MapQuestion(q, includeAnswer: true));
        }

        // ── ADMIN: Update question ─────────────────────────────────────────────
        [HttpPut("admin/questions/{id:int}")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> AdminUpdate(int id, [FromBody] QuizQuestionDto dto)
        {
            var q = await db.QuizQuestions.FindAsync(id);
            if (q == null) return NotFound(new { message = "Question not found" });
            if (dto.Options == null || dto.Options.Length < 2)
                return BadRequest(new { message = "At least 2 options required" });
            if (dto.CorrectIndex < 0 || dto.CorrectIndex >= dto.Options.Length)
                return BadRequest(new { message = "CorrectIndex out of range" });

            q.Question = dto.Question.Trim();
            q.OptionsJson = JsonSerializer.Serialize(dto.Options);
            q.CorrectIndex = dto.CorrectIndex;
            q.Category = (dto.Category ?? q.Category).Trim();
            q.IsActive = dto.IsActive;
            q.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();
            return Ok(MapQuestion(q, includeAnswer: true));
        }

        // ── ADMIN: Delete question ─────────────────────────────────────────────
        [HttpDelete("admin/questions/{id:int}")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> AdminDelete(int id)
        {
            var q = await db.QuizQuestions.FindAsync(id);
            if (q == null) return NotFound(new { message = "Question not found" });
            db.QuizQuestions.Remove(q);
            await db.SaveChangesAsync();
            return Ok(new { message = "Question deleted" });
        }

        // ── ADMIN: Toggle active/inactive ─────────────────────────────────────
        [HttpPatch("admin/questions/{id:int}/toggle")]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> AdminToggle(int id)
        {
            var q = await db.QuizQuestions.FindAsync(id);
            if (q == null) return NotFound(new { message = "Question not found" });
            q.IsActive = !q.IsActive;
            q.UpdatedAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();
            return Ok(new { id = q.Id, isActive = q.IsActive });
        }

        // ── TOURIST: Get quiz session (10 random Qs, no answers) ──────────────
        [HttpGet("play")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> Play()
        {
            var todayUtc = DateTimeOffset.UtcNow.Date;
            var attemptsToday = await db.QuizAttempts
                .CountAsync(a => a.UserId == CurrentUserId && a.AttemptedAt.Date == todayUtc);

            if (attemptsToday >= MaxAttemptsPerDay)
                return BadRequest(new
                {
                    message = $"You've used all {MaxAttemptsPerDay} daily attempts. Come back tomorrow!",
                    attemptsUsed = attemptsToday,
                    attemptsLimit = MaxAttemptsPerDay,
                });

            var active = await db.QuizQuestions.Where(q => q.IsActive).ToListAsync();
            if (active.Count < QuestionsPerQuiz)
                return BadRequest(new
                {
                    message = $"Not enough questions yet. Need {QuestionsPerQuiz}, only {active.Count} active.",
                    available = active.Count,
                });

            var selected = active
                .OrderBy(_ => Guid.NewGuid())
                .Take(QuestionsPerQuiz)
                .Select(q => MapQuestion(q, includeAnswer: false))
                .ToList();

            return Ok(new
            {
                questions = selected,
                attemptsUsed = attemptsToday,
                attemptsLeft = MaxAttemptsPerDay - attemptsToday,
                attemptsLimit = MaxAttemptsPerDay,
            });
        }

        // ── TOURIST: Submit answers ────────────────────────────────────────────
        [HttpPost("submit")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> Submit([FromBody] QuizSubmitDto dto)
        {
            if (dto.Answers == null || dto.Answers.Length == 0)
                return BadRequest(new { message = "No answers provided" });

            var todayUtc = DateTimeOffset.UtcNow.Date;
            var attemptsToday = await db.QuizAttempts
                .CountAsync(a => a.UserId == CurrentUserId && a.AttemptedAt.Date == todayUtc);

            if (attemptsToday >= MaxAttemptsPerDay)
                return BadRequest(new { message = "No attempts remaining for today." });

            var ids = dto.Answers.Select(a => a.QuestionId).ToList();
            var questions = await db.QuizQuestions
                .Where(q => ids.Contains(q.Id))
                .ToDictionaryAsync(q => q.Id);

            int correct = 0;
            var results = new List<object>();

            foreach (var ans in dto.Answers)
            {
                if (!questions.TryGetValue(ans.QuestionId, out var q)) continue;
                var isCorrect = ans.SelectedIndex == q.CorrectIndex;
                if (isCorrect) correct++;
                results.Add(new
                {
                    questionId = ans.QuestionId,
                    question = q.Question,
                    options = JsonSerializer.Deserialize<string[]>(q.OptionsJson) ?? Array.Empty<string>(),
                    selectedIndex = ans.SelectedIndex,
                    correctIndex = q.CorrectIndex,
                    isCorrect,
                });
            }

            int pointsEarned = correct * PointsPerCorrect;

            var user = await db.Users.FindAsync(CurrentUserId);
            if (user != null)
            {
                user.QuizPoints += pointsEarned;
                user.UpdatedAt = DateTimeOffset.UtcNow;
            }

            db.QuizAttempts.Add(new QuizAttempt
            {
                UserId = CurrentUserId,
                Score = correct,
                TotalQuestions = dto.Answers.Length,
                PointsEarned = pointsEarned,
                AttemptedAt = DateTimeOffset.UtcNow,
            });
            await db.SaveChangesAsync();

            return Ok(new
            {
                score = correct,
                total = dto.Answers.Length,
                pointsEarned,
                totalPoints = user?.QuizPoints ?? 0,
                attemptsUsed = attemptsToday + 1,
                attemptsLeft = MaxAttemptsPerDay - (attemptsToday + 1),
                results,
            });
        }

        // ── TOURIST: Quiz history 
        [HttpGet("history")]
        [Authorize(Roles = "tourist")]
        public async Task<IActionResult> History()
        {
            var todayUtc = DateTimeOffset.UtcNow.Date;
            var attempts = await db.QuizAttempts
                .Where(a => a.UserId == CurrentUserId)
                .OrderByDescending(a => a.AttemptedAt)
                .Take(20)
                .ToListAsync();

            var user = await db.Users.FindAsync(CurrentUserId);
            var attemptsToday = attempts.Count(a => a.AttemptedAt.Date == todayUtc);

            return Ok(new
            {
                totalPoints = user?.QuizPoints ?? 0,
                attemptsToday,
                attemptsLeft = Math.Max(0, MaxAttemptsPerDay - attemptsToday),
                history = attempts.Select(a => new
                {
                    id = a.Id,
                    score = a.Score,
                    totalQuestions = a.TotalQuestions,
                    pointsEarned = a.PointsEarned,
                    attemptedAt = a.AttemptedAt,
                }),
            });
        }
    }

    
    public class QuizQuestionDto
    {
        public string Question { get; set; } = string.Empty;
        public string[] Options { get; set; } = Array.Empty<string>();
        public int CorrectIndex { get; set; }
        public string? Category { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class QuizSubmitDto
    {
        public QuizAnswer[] Answers { get; set; } = Array.Empty<QuizAnswer>();
    }

    public class QuizAnswer
    {
        public int QuestionId { get; set; }
        public int SelectedIndex { get; set; }
    }
}