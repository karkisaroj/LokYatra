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
// Fall back to appsettings.json for local dev
var dbUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
var connStr = dbUrl != null
    ? BuildNpgsqlFromUrl(dbUrl)
    : builder.Configuration.GetConnectionString("UserDatabase");

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
    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            Console.WriteLine($"Authentication failed: {context.Exception.Message}");
            return Task.CompletedTask;
        },
        OnTokenValidated = context =>
        {
            Console.WriteLine("Token validated successfully");
            return Task.CompletedTask;
        }
    };
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

// Health check endpoint for Railway
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

// SPA fallback — only if wwwroot/index.html exists (Flutter web build)
var indexPath = Path.Combine(app.Environment.WebRootPath ?? "", "index.html");
if (File.Exists(indexPath))
{
    app.MapFallbackToFile("index.html");
}

app.Run();