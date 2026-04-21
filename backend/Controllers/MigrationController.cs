using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using backend.Database;
using backend.Models;
using System.Net.Http;

namespace backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MigrationController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly Cloudinary? _cloudinary;
        private static readonly HttpClient _httpClient = new HttpClient { Timeout = TimeSpan.FromMinutes(5) };

        public MigrationController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;

            var cloudName = configuration["Cloudinary:CloudName"];
            var apiKey = configuration["Cloudinary:ApiKey"];
            var apiSecret = configuration["Cloudinary:ApiSecret"];

            if (!string.IsNullOrWhiteSpace(cloudName) && !string.IsNullOrWhiteSpace(apiKey) && !string.IsNullOrWhiteSpace(apiSecret))
            {
                _cloudinary = new Cloudinary(new Account(cloudName, apiKey, apiSecret));
            }

            // Set a User-Agent to avoid being blocked by Wikipedia
            if (!_httpClient.DefaultRequestHeaders.Contains("User-Agent"))
            {
                _httpClient.DefaultRequestHeaders.Add("User-Agent", "LokYatraMigrationBot/1.0 (contact: support@lokyatra.com)");
            }
        }

        [HttpPost("start")]
        public async Task<IActionResult> StartMigration()
        {
            // Security Check
            if (!Request.Headers.TryGetValue("X-Migration-Secret", out var secret) || secret != "LokYatra-Migrate-2024")
            {
                return Unauthorized("Invalid migration secret.");
            }

            if (_cloudinary == null)
            {
                return BadRequest("Cloudinary is not configured.");
            }

            var results = new List<string>();
            var sites = await _context.CulturalSites.ToListAsync();
            var stories = await _context.Stories.ToListAsync();

            int siteCount = 0;
            int storyCount = 0;

            // Step 1: Migrate Cultural Sites
            foreach (var site in sites)
            {
                bool modified = false;
                var updatedUrls = new List<string>();

                foreach (var url in site.ImageUrls)
                {
                    if (url.Contains("wikipedia.org") || url.Contains("wikimedia.org"))
                    {
                        var newUrl = await MigrateImageAsync(url, $"sites/{site.Id}");
                        if (newUrl != null)
                        {
                            updatedUrls.Add(newUrl);
                            results.Add($"Site {site.Id}: {url} -> {newUrl}");
                            modified = true;
                        }
                        else
                        {
                            updatedUrls.Add(url); // Keep old if failed
                        }
                    }
                    else
                    {
                        updatedUrls.Add(url);
                    }
                }

                if (modified)
                {
                    site.ImageUrls = updatedUrls.ToArray();
                    site.UpdatedAt = DateTimeOffset.UtcNow;
                    siteCount++;
                }
            }

            // Step 2: Migrate Stories
            foreach (var story in stories)
            {
                bool modified = false;
                var updatedUrls = new List<string>();

                foreach (var url in story.ImageUrls)
                {
                    if (url.Contains("wikipedia.org") || url.Contains("wikimedia.org"))
                    {
                        var newUrl = await MigrateImageAsync(url, $"stories/{story.Id}");
                        if (newUrl != null)
                        {
                            updatedUrls.Add(newUrl);
                            results.Add($"Story {story.Id}: {url} -> {newUrl}");
                            modified = true;
                        }
                        else
                        {
                            updatedUrls.Add(url);
                        }
                    }
                    else
                    {
                        updatedUrls.Add(url);
                    }
                }

                if (modified)
                {
                    story.ImageUrls = updatedUrls.ToArray();
                    story.UpdatedAt = DateTimeOffset.UtcNow;
                    storyCount++;
                }
            }

            if (siteCount > 0 || storyCount > 0)
            {
                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                Message = "Migration completed",
                SitesUpdated = siteCount,
                StoriesUpdated = storyCount,
                Log = results
            });
        }

        private async Task<string?> MigrateImageAsync(string sourceUrl, string folder)
        {
            try
            {
                // 1. Download
                var response = await _httpClient.GetAsync(sourceUrl);
                if (!response.IsSuccessStatusCode) return null;

                var bytes = await response.Content.ReadAsByteArrayAsync();
                var fileName = Path.GetFileName(new Uri(sourceUrl).LocalPath);

                // 2. Upload to Cloudinary
                using var stream = new MemoryStream(bytes);
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileName, stream),
                    Folder = $"migration/{folder}",
                    UseFilename = true,
                    UniqueFilename = true,
                    Transformation = new Transformation().Quality("auto").FetchFormat("auto")
                };

                var uploadResult = await _cloudinary!.UploadAsync(uploadParams);
                return uploadResult.SecureUrl?.AbsoluteUri;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error migrating {sourceUrl}: {ex.Message}");
                return null;
            }
        }
    }
}
