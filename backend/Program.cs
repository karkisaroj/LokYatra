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
var connStr = string.IsNullOrEmpty(dbUrl) 
    ? builder.Configuration.GetConnectionString("UserDatabase") ?? ""
    : BuildNpgsqlFromUrl(dbUrl);

builder.Services.AddDbContext<AppDbContext>(options => options.UseNpgsql(connStr));

static string BuildNpgsqlFromUrl(string url)
{
    url = url.Replace("postgres://", "postgresql://");
    var uri = new Uri(url);
    var userInfo = uri.UserInfo.Split(':', 2);
    var username = userInfo[0];
    var password = userInfo.Length > 1 ? userInfo[1] : "";
    
    return $"Host={uri.Host};Port={uri.Port};Database={uri.AbsolutePath.TrimStart('/')};" +
           $"Username={username};Password={password};" +
           "Trust Server Certificate=true;SSL Mode=Require;";
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

// Bind to Railway's dynamic PORT env var
var port = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrEmpty(port))
    builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();

// Auto-apply pending migrations on startup
using (var scope = app.Services.CreateScope())
{
    try
    {
        scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.Migrate();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[MIGRATION ERROR] {ex.Message}");
    }
}

app.UseCors("AllowAll");


if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/health", () => Results.Ok("healthy"));

app.Run();