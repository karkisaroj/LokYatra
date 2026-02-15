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
//    public class SitesController(AppDbContext db, ICloudImageService images, IConfiguration config) : ControllerBase
//    {
//        private readonly AppDbContext _db = db;
//        private readonly ICloudImageService _images = images;
//        private readonly IConfiguration _config = config;

//        [HttpGet]
//        public async Task<ActionResult<IEnumerable<CulturalSiteDto>>> GetSites()
//        {
//            var sites = await _db.CulturalSites
//                .Include(s => s.Images)
//                .Include(s => s.Stories)
//                .Select(s => new CulturalSiteDto
//                {
//                    Id = s.Id,
//                    Name = s.Name,
//                    Category = s.Category,
//                    District = s.District,
//                    Address = s.Address,
//                    ShortDescription = s.ShortDescription,
//                    HistoricalSignificance = s.HistoricalSignificance,
//                    CulturalImportance = s.CulturalImportance,
//                    EntryFeeNPR = s.EntryFeeNPR,
//                    EntryFeeSAARC = s.EntryFeeSAARC,
//                    OpeningTime = s.OpeningTime,
//                    ClosingTime = s.ClosingTime,
//                    BestTimeToVisit = s.BestTimeToVisit,
//                    IsUNESCO = s.IsUNESCO,
//                    ImageUrls = s.Images.OrderBy(i => i.Position).Select(i => i.Url).ToList(),
//                    StoryIds = s.Stories.Select(st => st.Id).ToList()
//                })
//                .ToListAsync();

//            return Ok(sites);
//        }

//        [HttpGet("{id:int}")]
//        public async Task<ActionResult<CulturalSiteDto>> GetSite(int id)
//        {
//            var s = await _db.CulturalSites
//                .Include(x => x.Images)
//                .Include(x => x.Stories)
//                .FirstOrDefaultAsync(x => x.Id == id);

//            if (s == null) return NotFound();

//            var dto = new CulturalSiteDto
//            {
//                Id = s.Id,
//                Name = s.Name,
//                Category = s.Category,
//                District = s.District,
//                Address = s.Address,
//                ShortDescription = s.ShortDescription,
//                HistoricalSignificance = s.HistoricalSignificance,
//                CulturalImportance = s.CulturalImportance,
//                EntryFeeNPR = s.EntryFeeNPR,
//                EntryFeeSAARC = s.EntryFeeSAARC,
//                OpeningTime = s.OpeningTime,
//                ClosingTime = s.ClosingTime,
//                BestTimeToVisit = s.BestTimeToVisit,
//                IsUNESCO = s.IsUNESCO,
//                ImageUrls = s.Images.OrderBy(i => i.Position).Select(i => i.Url).ToList(),
//                StoryIds = s.Stories.Select(st => st.Id).ToList()
//            };
//            return Ok(dto);
//        }

//        [HttpPost]
//        [Authorize(Roles = "admin")]
//        [RequestSizeLimit(25_000_000)]
//        [Consumes("multipart/form-data")]
//        public async Task<ActionResult<CulturalSiteDto>> CreateSite([FromForm] CreateCulturalSiteDto dto, [FromForm] List<IFormFile>? images)
//        {
//            Console.WriteLine($"=== CreateSite called ===");
//            Console.WriteLine($"Images parameter is null: {images == null}");
//            Console.WriteLine($"Images count: {images?.Count ?? 0}");
            
//            if (images != null)
//            {
//                foreach (var img in images)
//                {
//                    Console.WriteLine($"Image received - Name: {img.FileName}, Size: {img.Length}, ContentType: {img.ContentType}");
//                }
//            }
            
//            var site = new CulturalSite
//            {
//                Name = dto.Name,
//                Category = dto.Category,
//                District = dto.District,
//                Address = dto.Address,
//                ShortDescription = dto.ShortDescription,
//                HistoricalSignificance = dto.HistoricalSignificance,
//                CulturalImportance = dto.CulturalImportance,
//                EntryFeeNPR = dto.EntryFeeNPR,
//                EntryFeeSAARC = dto.EntryFeeSAARC,
//                OpeningTime = dto.OpeningTime,
//                ClosingTime = dto.ClosingTime,
//                BestTimeToVisit = dto.BestTimeToVisit,
//                IsUNESCO = dto.IsUNESCO
//            };

//            _db.CulturalSites.Add(site);
//            await _db.SaveChangesAsync();
//            Console.WriteLine($"Site created with ID: {site.Id}");

//            // Upload to Cloudinary (max 5 files, 5MB each)
//            var folder = _config["Cloudinary:SitesFolder"] ?? "lokyatra/sites";
            
//            Console.WriteLine($"Attempting to upload {images?.Count ?? 0} images to Cloudinary folder: {folder}");
            
//            var uploads = await _images.UploadImagesAsync(images ?? [], folder, maxFiles: 5, maxBytesPerFile: 5 * 1024 * 1024);
            
//            Console.WriteLine($"Successfully uploaded {uploads.Count} images to Cloudinary");

//            var pos = 0;
//            foreach (var u in uploads)
//            {
//                Console.WriteLine($"Adding image to DB - URL: {u.Url}, PublicId: {u.PublicId}");
//                _db.CulturalSiteImages.Add(new CulturalSiteImage
//                {
//                    CulturalSiteId = site.Id,
//                    Url = u.Url,
//                    PublicId = u.PublicId,
//                    Position = pos++
//                });
//            }
            
//            if (uploads.Count > 0)
//            {
//                await _db.SaveChangesAsync();
//                Console.WriteLine($"Saved {uploads.Count} images to database");
//            }

//            var dtoOut = new CulturalSiteDto
//            {
//                Id = site.Id,
//                Name = site.Name,
//                Category = site.Category,
//                District = site.District,
//                Address = site.Address,
//                ShortDescription = site.ShortDescription,
//                HistoricalSignificance = site.HistoricalSignificance,
//                CulturalImportance = site.CulturalImportance,
//                EntryFeeNPR = site.EntryFeeNPR,
//                EntryFeeSAARC = site.EntryFeeSAARC,
//                OpeningTime = site.OpeningTime,
//                ClosingTime = site.ClosingTime,
//                BestTimeToVisit = site.BestTimeToVisit,
//                IsUNESCO = site.IsUNESCO,
//                ImageUrls = uploads.Select(x => x.Url).ToList(),
//                StoryIds = new List<int>()
//            };

//            Console.WriteLine($"Returning DTO with {dtoOut.ImageUrls.Count} image URLs");
//            return CreatedAtAction(nameof(GetSite), new { id = site.Id }, dtoOut);
//        }
//    }
//}