using backend.Database;
using backend.Entities;
using backend.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Net;
using System.Net.Mail;
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

            var user = await db.Users
                .FirstOrDefaultAsync(u => u.Email.Equals(dto.Email.ToLower(), StringComparison.CurrentCultureIgnoreCase));

            if (user == null)
                return Ok(new { message = "If that email exists, a reset link has been sent." });

            var oldTokens = await db.PasswordResetTokens
                .Where(t => t.UserId == user.UserId && !t.IsUsed)
                .ToListAsync();
            db.PasswordResetTokens.RemoveRange(oldTokens);

            // Generate secure 6-digit OTP token
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

            // Send email
            try
            {
                await SendResetEmailAsync(user.Email, user.Name, token);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SMTP ERROR] {ex.Message}");
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
            var host = smtp["Host"] ?? "smtp.gmail.com";
            var port = int.Parse(smtp["Port"] ?? "587");
            var sender = smtp["SenderEmail"] ?? "";
            var senderNm = smtp["SenderName"] ?? "Lokyatra";
            var password = smtp["AppPassword"] ?? "";

            var message = new MailMessage
            {
                From = new MailAddress(sender, senderNm),
                Subject = "Your Lokyatra Password Reset Code",
                IsBodyHtml = true,
                Body = $"""
                    <!DOCTYPE html>
                    <html>
                    <body style="font-family: Arial, sans-serif; background: #FAF7F2; padding: 40px 0;">
                      <div style="max-width: 480px; margin: 0 auto; background: white;
                                  border-radius: 16px; overflow: hidden;
                                  box-shadow: 0 4px 20px rgba(0,0,0,0.08);">

                        <div style="background: linear-gradient(135deg, #8B5E3C, #CD6E4E);
                                    padding: 32px; text-align: center;">
                          <h1 style="color: white; margin: 0; font-size: 24px;">Lokyatra</h1>
                          <p style="color: rgba(255,255,255,0.8); margin: 6px 0 0;">
                            Nepal Homestay Experience
                          </p>
                        </div>

                        <div style="padding: 36px 32px;">
                          <p style="color: #2D1B10; font-size: 16px; margin: 0 0 8px;">
                            Hi {name},
                          </p>
                          <p style="color: #666; font-size: 14px; margin: 0 0 28px;">
                            We received a request to reset your password.
                            Use the code below — it expires in <strong>15 minutes</strong>.
                          </p>

                          <div style="background: #FAF7F2; border: 2px dashed #8B5E3C;
                                      border-radius: 12px; padding: 24px; text-align: center;
                                      margin: 0 0 28px;">
                            <p style="color: #8B5E3C; font-size: 13px; margin: 0 0 8px;
                                      letter-spacing: 1px; text-transform: uppercase;">
                              Your reset code
                            </p>
                            <h2 style="color: #2D1B10; font-size: 42px; margin: 0;
                                       letter-spacing: 10px; font-weight: 900;">
                              {token}
                            </h2>
                          </div>

                          <p style="color: #999; font-size: 12px; margin: 0;">
                            If you didn't request this, you can safely ignore this email.
                            Your password will not change.
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
                    """,
            };

            message.To.Add(new MailAddress(toEmail));

            using var client = new SmtpClient(host, port)
            {
                Credentials = new NetworkCredential(sender, password),
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
            };

            await client.SendMailAsync(message);
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