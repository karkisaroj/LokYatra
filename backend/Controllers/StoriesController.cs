//using backend.Database;
//using backend.DTOs;
//using backend.Models;
//using backend.Services;
//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.EntityFrameworkCore;

//namespace backend.Controllers
//{
//    [ApiController]
//    [Route("api/[controller]")]
//    public class StoriesController : ControllerBase
//    {
//        private readonly AppDbContext _db;
//        private readonly ICloudImageService _images;
//        private readonly IConfiguration _config;

//        public StoriesController(AppDbContext db, ICloudImageService images, IConfiguration config)
//        {
//            _db = db;
//            _images = images;
//            _config = config;
//        }

//        [HttpGet]
//        public async Task<ActionResult<IEnumerable<StoryDto>>> GetStories([FromQuery] int? siteId)
//        {
//            var q = _db.Stories.Include(s => s.Images).AsQueryable();
//            if (siteId.HasValue) q = q.Where(s => s.CulturalSiteId == siteId.Value);

//            var list = await q.Select(s => new StoryDto
//            {
//                Id = s.Id,
//                CulturalSiteId = s.CulturalSiteId,
//                Title = s.Title,
//                StoryType = s.StoryType,
//                EstimatedReadTimeMinutes = s.EstimatedReadTimeMinutes,
//                FullContent = s.FullContent,
//                HistoricalContext = s.HistoricalContext,
//                CulturalSignificance = s.CulturalSignificance,
//                ImageUrls = s.Images.OrderBy(i => i.Position).Select(i => i.Url).ToList(),
//            }).ToListAsync();

//            return Ok(list);
//        }

//        [HttpPost]
//        [Authorize(Roles = "admin")]
//        [RequestSizeLimit(20_000_000)]
//        public async Task<ActionResult<StoryDto>> CreateStory([FromForm] CreateStoryDto dto, [FromForm] List<IFormFile>? images)
//        {
//            var existsSite = await _db.CulturalSites.AnyAsync(s => s.Id == dto.CulturalSiteId);
//            if (!existsSite) return BadRequest("Related site not found.");

//            var story = new Story
//            {
//                CulturalSiteId = dto.CulturalSiteId,
//                Title = dto.Title,
//                StoryType = dto.StoryType,
//                EstimatedReadTimeMinutes = dto.EstimatedReadTimeMinutes,
//                FullContent = dto.FullContent,
//                HistoricalContext = dto.HistoricalContext,
//                CulturalSignificance = dto.CulturalSignificance
//            };

//            _db.Stories.Add(story);
//            await _db.SaveChangesAsync();

//            // Upload to Cloudinary (max 3 files, 5MB each)
//            var folder = _config["Cloudinary:StoriesFolder"] ?? "lokyatra/stories";
//            var uploads = await _images.UploadImagesAsync(images ?? new List<IFormFile>(), folder, maxFiles: 3, maxBytesPerFile: 5 * 1024 * 1024);

//            var pos = 0;
//            foreach (var u in uploads)
//            {
//                _db.StoryImages.Add(new StoryImage
//                {
//                    StoryId = story.Id,
//                    Url = u.Url,
//                    PublicId = u.PublicId,
//                    Position = pos++
//                });
//            }
//            await _db.SaveChangesAsync();

//            var dtoOut = new StoryDto
//            {
//                Id = story.Id,
//                CulturalSiteId = story.CulturalSiteId,
//                Title = story.Title,
//                StoryType = story.StoryType,
//                EstimatedReadTimeMinutes = story.EstimatedReadTimeMinutes,
//                FullContent = story.FullContent,
//                HistoricalContext = story.HistoricalContext,
//                CulturalSignificance = story.CulturalSignificance,
//                ImageUrls = uploads.Select(x => x.Url).ToList()
//            };

//            return CreatedAtAction(nameof(GetStories), new { siteId = story.CulturalSiteId }, dtoOut);
//        }
//    }
//}