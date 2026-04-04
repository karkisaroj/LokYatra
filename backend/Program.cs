using backend.Database;
using backend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Security.Claims;
using System.Text;
using System.Text.Json.Serialization;
// Version: 1.0.1 (Forced Rebuild: 2026-04-04)
var baseDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location)!;
var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = baseDir,
    WebRootPath = Path.Combine(baseDir, "wwwroot")
});

Console.WriteLine($"[LOKYATRA] App Base Directory: {AppContext.BaseDirectory}");
Console.WriteLine($"[LOKYATRA] Web Root Path: {builder.Environment.WebRootPath}");

if (Directory.Exists(builder.Environment.WebRootPath))
{
    Console.WriteLine("[LOKYATRA] Web Root Files:");
    foreach (var f in Directory.GetFiles(builder.Environment.WebRootPath)) 
        Console.WriteLine($"  - {Path.GetFileName(f)}");
}
else
{
    Console.WriteLine("[LOKYATRA] Web Root NOT FOUND!");
}

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(
            new System.Text.Json.Serialization.JsonStringEnumConverter()
        );
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });
builder.Services.AddOpenApi();

// Railway provides DATABASE_URL as postgresql://user:pass@host:port/db
var dbUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
string connStr;

if (!string.IsNullOrEmpty(dbUrl))
{
    Console.WriteLine("[LOKYATRA] Using Railway Database URL...");
    try {
        connStr = BuildNpgsqlFromUrl(dbUrl);
    } catch (Exception ex) {
        Console.WriteLine($"[LOKYATRA] ERROR parsing DATABASE_URL: {ex.Message}");
        throw;
    }
}
else
{
    Console.WriteLine("[LOKYATRA] DATABASE_URL not found. Using local connection string.");
    connStr = builder.Configuration.GetConnectionString("UserDatabase") ?? "";
}

builder.Services.AddDbContext<AppDbContext>(options => options.UseNpgsql(connStr));

static string BuildNpgsqlFromUrl(string url)
{
    try 
    {
        // Handle postgres:// or postgresql://
        url = url.Replace("postgres://", "postgresql://");
        var uri = new Uri(url);
        var userInfo = uri.UserInfo.Split(':', 2);
        var username = userInfo[0];
        var password = userInfo.Length > 1 ? userInfo[1] : "";
        
        return $"Host={uri.Host};Port={uri.Port};Database={uri.AbsolutePath.TrimStart('/')};" +
               $"Username={username};Password={password};" +
               "Trust Server Certificate=true;SSL Mode=Require;";
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[LOKYATRA] CRITICAL: Invalid DATABASE_URL format: {ex.Message}");
        return ""; // Let it fail later with a clear message
    }
}

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["AppSettings:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["AppSettings:Audience"],
        ValidateLifetime = true,
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["AppSettings:Token"]!)
        ),
        ValidateIssuerSigningKey = true,
        RoleClaimType = ClaimTypes.Role
    };
    options.Events = new JwtBearerEvents();
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICloudImageService, CloudinaryImageService>();
builder.Services.AddScoped<NotificationService>();
builder.Services.AddHttpClient();
var app = builder.Build();

// Auto-apply pending migrations on startup
try 
{
    using (var scope = app.Services.CreateScope())
    {
        Console.WriteLine("[LOKYATRA] Applying database migrations...");
        scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.Migrate();
        Console.WriteLine("[LOKYATRA] Migrations applied successfully.");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"[LOKYATRA] Warning: Database migration failed: {ex.Message}");
    // We don't throw here so the app can still serve the Website even if DB is pending
}

app.UseCors("AllowAll");

// Serve Flutter web build from wwwroot/
app.UseDefaultFiles();
app.UseStaticFiles();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Debug endpoint to find files on Railway
app.MapGet("/debug-paths", () => 
{
    var root = AppContext.BaseDirectory;
    var webRoot = builder.Environment.WebRootPath;
    
    var rootFiles = Directory.Exists(root) ? Directory.GetFiles(root).Select(Path.GetFileName).ToArray() : [];
    var webRootFiles = Directory.Exists(webRoot) ? Directory.GetFiles(webRoot).Select(Path.GetFileName).ToArray() : [];
    var rootDirs = Directory.Exists(root) ? Directory.GetDirectories(root).Select(Path.GetFileName).ToArray() : [];

    return Results.Ok(new 
    { 
        status = "Active",
        baseDirectory = root,
        webRootPath = webRoot,
        indexHtmlExists = File.Exists(Path.Combine(webRoot ?? "", "index.html")),
        baseDirFolders = rootDirs,
        baseDirFiles = rootFiles,
        webRootFiles = webRootFiles
    });
});

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", timestamp = DateTime.UtcNow }));

// Serve index.html directly on root if DefaultFiles fails
app.MapGet("/", async (HttpContext context) =>
{
    var path = Path.Combine(builder.Environment.WebRootPath, "index.html");
    if (File.Exists(path))
    {
        context.Response.ContentType = "text/html";
        await context.Response.SendFileAsync(path);
    }
    else
    {
        context.Response.StatusCode = 404;
        await context.Response.WriteAsync("Website not found on server.");
    }
});

// SPA fallback — ensures we serve index.html for any frontend routes
app.MapFallbackToFile("index.html");

app.Run();