using backend.Database;
using backend.Models;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MimeKit;
using System.Security.Cryptography;

namespace backend.Controllers
{
    [Route("api/Auth")]
    [ApiController]
    public class PasswordResetController(AppDbContext db, IConfiguration config) : ControllerBase
    {
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email))
                return BadRequest(new { message = "Email is required" });

            var normalizedEmail = dto.Email.ToLower().Trim();
            
            var user = await db.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == normalizedEmail);

            if (user == null)
                return Ok(new { message = "If that email exists, a reset link has been sent." });

            var oldTokens = await db.PasswordResetTokens
                .Where(t => t.UserId == user.UserId && !t.IsUsed)
                .ToListAsync();
            db.PasswordResetTokens.RemoveRange(oldTokens);

            var token = RandomNumberGenerator.GetInt32(100000, 999999).ToString();

            db.PasswordResetTokens.Add(new PasswordResetToken
            {
                UserId = user.UserId,
                Token = token,
                ExpiresAt = DateTimeOffset.UtcNow.AddMinutes(15),
                IsUsed = false,
                CreatedAt = DateTimeOffset.UtcNow,
            });

            await db.SaveChangesAsync();

            try
            {
                await SendResetEmailAsync(user.Email, user.Name, token);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SMTP ERROR] {ex.GetType().Name}: {ex.Message}");
                if (ex.InnerException != null)
                    Console.WriteLine($"[SMTP INNER] {ex.InnerException.Message}");
                return StatusCode(500, new { message = "Failed to send email. Please try again." });
            }

            return Ok(new { message = "If that email exists, a reset link has been sent." });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email) ||
                string.IsNullOrWhiteSpace(dto.Token) ||
                string.IsNullOrWhiteSpace(dto.NewPassword))
                return BadRequest(new { message = "Email, token and new password are required" });

            if (dto.NewPassword.Length < 6)
                return BadRequest(new { message = "Password must be at least 6 characters" });

            var user = await db.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == dto.Email.ToLower().Trim());

            if (user == null)
                return BadRequest(new { message = "Invalid request" });

            var resetToken = await db.PasswordResetTokens
                .Where(t => t.UserId == user.UserId
                    && t.Token == dto.Token.Trim()
                    && !t.IsUsed
                    && t.ExpiresAt > DateTimeOffset.UtcNow)
                .FirstOrDefaultAsync();

            if (resetToken == null)
                return BadRequest(new { message = "Invalid or expired code. Please request a new one." });

            // Update password
            user.PasswordHash = new PasswordHasher<User>().HashPassword(user, dto.NewPassword);
            user.UpdatedAt = DateTimeOffset.UtcNow;

            // Mark token used
            resetToken.IsUsed = true;

            await db.SaveChangesAsync();

            return Ok(new { message = "Password reset successfully. You can now log in." });
        }

        private async Task SendResetEmailAsync(string toEmail, string name, string token)
        {
            var smtp = config.GetSection("Smtp");
            var host     = smtp["Host"]        ?? "smtp.gmail.com";
            var port     = int.Parse(smtp["Port"] ?? "587");
            var sender   = smtp["SenderEmail"] ?? "";
            var senderNm = smtp["SenderName"]  ?? "Lokyatra";
            var password = (smtp["AppPassword"] ?? "").Trim();

            if (string.IsNullOrWhiteSpace(sender) || string.IsNullOrWhiteSpace(password))
                throw new InvalidOperationException("SMTP credentials not configured. Set Smtp__SenderEmail and Smtp__AppPassword in Railway variables.");

            var body = $"""
                <!DOCTYPE html>
                <html>
                <body style="font-family: Arial, sans-serif; background: #F2F2F2; padding: 40px 0;">
                  <div style="max-width: 480px; margin: 0 auto; background: white;
                              border-radius: 16px; overflow: hidden;
                              box-shadow: 0 4px 20px rgba(0,0,0,0.08);">
                    <div style="background: linear-gradient(135deg, #4A4A4A, #6E6E6E);
                                padding: 32px; text-align: center;">
                      <h1 style="color: white; margin: 0; font-size: 24px;">Lokyatra</h1>
                      <p style="color: rgba(255,255,255,0.8); margin: 6px 0 0;">Nepal Homestay Experience</p>
                    </div>
                    <div style="padding: 36px 32px;">
                      <p style="color: #2D2D2D; font-size: 16px; margin: 0 0 8px;">Hi {name},</p>
                      <p style="color: #666; font-size: 14px; margin: 0 0 28px;">
                        We received a request to reset your password.
                        Use the code below — it expires in <strong>15 minutes</strong>.
                      </p>
                      <div style="background: #F9F9F9; border: 2px dashed #4A4A4A;
                                  border-radius: 12px; padding: 24px; text-align: center; margin: 0 0 28px;">
                        <p style="color: #4A4A4A; font-size: 13px; margin: 0 0 8px;
                                  letter-spacing: 1px; text-transform: uppercase;">Your reset code</p>
                        <h2 style="color: #2D2D2D; font-size: 42px; margin: 0;
                                   letter-spacing: 10px; font-weight: 900;">{token}</h2>
                      </div>
                      <p style="color: #999; font-size: 12px; margin: 0;">
                        If you didn't request this, you can safely ignore this email.
                      </p>
                    </div>
                    <div style="background: #F5F5F5; padding: 16px 32px; text-align: center;">
                      <p style="color: #bbb; font-size: 11px; margin: 0;">
                        © {DateTime.UtcNow.Year} Lokyatra · Nepal Homestay Platform
                      </p>
                    </div>
                  </div>
                </body>
                </html>
                """;

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(senderNm, sender));
            message.To.Add(new MailboxAddress(name, toEmail));
            message.Subject = "Your Lokyatra Password Reset Code";
            message.Body = new TextPart("html") { Text = body };

            // MailKit properly supports async timeouts — 15 second limit
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(15));
            using var client = new MailKit.Net.Smtp.SmtpClient();

            await client.ConnectAsync(host, port, SecureSocketOptions.StartTls, cts.Token);
            await client.AuthenticateAsync(sender, password, cts.Token);
            await client.SendAsync(message, cts.Token);
            await client.DisconnectAsync(true, cts.Token);
        }
    }

    public class ForgotPasswordDto
    {
        public string Email { get; set; } = string.Empty;
    }

    public class ResetPasswordDto
    {
        public string Email { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}