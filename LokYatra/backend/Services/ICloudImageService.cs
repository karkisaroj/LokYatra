using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.Services
{
    public interface ICloudImageService
    {
        Task<List<string>> UploadFilesAsync(string folder, IFormFileCollection files);
    }
}