using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;

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
            if (string.IsNullOrWhiteSpace(cloudName) || string.IsNullOrWhiteSpace(apiKey) || string.IsNullOrWhiteSpace(apiSecret))
            {
                Console.WriteLine("[CloudinaryImageService] Missing Cloudinary config. Service will act as no-op.");
                _cloudinary = null;
                return;
            }
            var account = new Account(cloudName, apiKey, apiSecret);
            _cloudinary = new Cloudinary(account) { Api = { Secure = true } };
        }

        public async Task<List<string>> UploadFilesAsync(string folder, IFormFileCollection files)
        {
            var urls = new List<string>();
            if (_cloudinary is null || files is null || files.Count == 0)
            {
                Console.WriteLine("[CloudinaryImageService] No cloudinary or no files.");
                return urls;
            }

            foreach (var file in files)
            {
                if (file.Length <= 0) continue;
                await using var stream = file.OpenReadStream();
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(file.FileName, stream),
                    Folder = folder,
                    UseFilename = true,
                    UniqueFilename = true,
                    Overwrite = false,
                    Transformation = new Transformation().Quality("auto").FetchFormat("auto"),
                };
                var result = await _cloudinary.UploadAsync(uploadParams);
                Console.WriteLine($"[CloudinaryImageService] Upload {file.FileName} -> {result.SecureUrl}");
                if (result.SecureUrl != null) urls.Add(result.SecureUrl.AbsoluteUri);
            }
            Console.WriteLine($"[CloudinaryImageService] Returning {urls.Count} URL(s)");
            return urls;
        }
    }
}