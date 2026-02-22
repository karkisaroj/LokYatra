using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace backend.Services
{
    public class CloudinaryImageService : ICloudImageService
    {
        private readonly Cloudinary? _cloudinary;

        public CloudinaryImageService(IConfiguration configuration)
        {
            var cloudName = configuration["Cloudinary:CloudName"];
            var apiKey = configuration["Cloudinary:ApiKey"];
            var apiSecret = configuration["Cloudinary:ApiSecret"];

            if (string.IsNullOrWhiteSpace(cloudName) ||
                string.IsNullOrWhiteSpace(apiKey) ||
                string.IsNullOrWhiteSpace(apiSecret))
            {
                Console.WriteLine("[Cloudinary] Missing config — running as no-op.");
                _cloudinary = null;
                return;
            }

            _cloudinary = new Cloudinary(new Account(cloudName, apiKey, apiSecret))
            {
                Api = { Secure = true }
            };
        }

        public async Task<List<string>> UploadFilesAsync(string folder, IFormFileCollection files)
        {
            if (_cloudinary is null || files is null || files.Count == 0)
            {
                Console.WriteLine("[Cloudinary] No client or no files.");
                return [];
            }

            // Read all file bytes BEFORE launching parallel tasks.
            var fileData = new List<(string name, byte[] bytes)>();
            foreach (var file in files)
            {
                if (file.Length <= 0) continue;
                using var ms = new MemoryStream();
                await file.CopyToAsync(ms);
                fileData.Add((file.FileName, ms.ToArray()));
            }

            var uploadTasks = fileData.Select(async fd =>
            {
                await using var stream = new MemoryStream(fd.bytes);
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fd.name, stream),
                    Folder = folder,
                    UseFilename = true,
                    UniqueFilename = true,
                    Overwrite = false,
                    // Let Cloudinary auto-optimize quality and format
                    Transformation = new Transformation()
                        .Quality("auto")
                        .FetchFormat("auto"),
                };

                var result = await _cloudinary.UploadAsync(uploadParams);
                Console.WriteLine($"[Cloudinary] {fd.name} → {result.SecureUrl}");
                return result.SecureUrl?.AbsoluteUri;
            });

            // Wait for ALL uploads to finish simultaneously
            var results = await Task.WhenAll(uploadTasks);

            var urls = results.Where(u => u != null).Cast<string>().ToList();
            Console.WriteLine($"[Cloudinary] Done — {urls.Count} URL(s) returned.");
            return urls;
        }
    }
}