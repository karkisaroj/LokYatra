using backend.Database;
using backend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Security.Claims;
using System.Text;
using System.Text.Json.Serialization;
var builder = WebApplication.CreateBuilder(args);

// Railway injects PORT; fallback to 5257 for local dev
var port = Environment.GetEnvironmentVariable("PORT") ?? "5257";
builder.WebHost.UseUrls($"http://*:{port}");
Console.WriteLine($"[LOKYATRA] Starting on port {port}...");

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
    var uri    = new Uri(url);
    var parts  = uri.UserInfo.Split(':', 2);
    return $"Host={uri.Host};Port={uri.Port};Database={uri.AbsolutePath.TrimStart('/')};Username={parts[0]};Password={parts[1]};Trust Server Certificate=true;SSL Mode=Require;";
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
using (var scope = app.Services.CreateScope())
{
    scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.Migrate();
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

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", timestamp = DateTime.UtcNow }));

// SPA fallback — ensures we serve index.html for any frontend routes
app.MapFallbackToFile("index.html");

app.Run();