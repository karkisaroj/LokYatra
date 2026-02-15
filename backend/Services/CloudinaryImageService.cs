//using CloudinaryDotNet;
//using CloudinaryDotNet.Actions;
//using Npgsql.BackendMessages;

//namespace backend.Services
//{
//    public record CloudinaryUploadResult(string PublicId, string Url);

//    public interface ICloudImageService
//    {
//        Task<List<CloudinaryUploadResult>> UploadImagesAsync(IEnumerable<IFormFile> files, string folder, int maxFiles, long maxBytesPerFile);
//    }

//    public class CloudinaryImageService : ICloudImageService
//    {
//        private readonly Cloudinary _cloudinary;

//        public CloudinaryImageService(IConfiguration config)
//        {
//            var cloudName = config["Cloudinary:CloudName"];
//            var apiKey = config["Cloudinary:ApiKey"];
//            var apiSecret = config["Cloudinary:ApiSecret"];

//            if (string.IsNullOrWhiteSpace(cloudName) || string.IsNullOrWhiteSpace(apiKey) || string.IsNullOrWhiteSpace(apiSecret))
//                throw new InvalidOperationException("Cloudinary credentials are missing in configuration.");

//            var account = new Account(cloudName, apiKey, apiSecret);
//            _cloudinary = new Cloudinary(account) { Api = { Secure = true } };
//        }

//        public async Task<List<CloudinaryUploadResult>> UploadImagesAsync(IEnumerable<IFormFile> files, string folder, int maxFiles, long maxBytesPerFile)
//        {
//            var list = files?.Where(f => f.Length > 0).ToList() ?? new List<IFormFile>();
//            Console.WriteLine($"CloudinaryImageService: Received {list.Count} files");
            
//            if (list.Count == 0) return new List<CloudinaryUploadResult>();
//            if (list.Count > maxFiles) throw new InvalidOperationException($"Too many files. Max {maxFiles}.");
//            foreach (var f in list)
//            {
//                Console.WriteLine($"File: {f.FileName}, Size: {f.Length} bytes");
//                if (f.Length > maxBytesPerFile)
//                    throw new InvalidOperationException($"File {f.FileName} too large. Max {maxBytesPerFile / (1024 * 1024)}MB.");
//            }

//            var results = new List<CloudinaryUploadResult>();

//            foreach (var file in list)
//            {
//                await using var stream = file.OpenReadStream();
//                var uploadParams = new ImageUploadParams
//                {
//                    File = new FileDescription(file.FileName, stream),
//                    Folder = folder, // e.g., lokyatra/sites or lokyatra/stories
//                    UseFilename = true,
//                    UniqueFilename = true,
//                    Overwrite = false,
//                    Transformation = new Transformation().Quality("auto").FetchFormat("auto")
//                };

//                var uploadResult = await _cloudinary.UploadAsync(uploadParams);
//                Console.WriteLine($"Upload result for {file.FileName}: StatusCode={uploadResult.StatusCode}, URL={uploadResult.SecureUrl?.AbsoluteUri}");
                
//                if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK && uploadResult.SecureUrl != null)
//                {
//                    results.Add(new CloudinaryUploadResult(uploadResult.PublicId, uploadResult.SecureUrl.AbsoluteUri));
//                }
//                else
//                {
//                    Console.WriteLine($"Upload failed: {uploadResult.Error?.Message}");
//                    throw new InvalidOperationException($"Upload failed for {file.FileName}: {uploadResult.Error?.Message}");
//                }
//            }

//            return results;
//        }
//    }
//}