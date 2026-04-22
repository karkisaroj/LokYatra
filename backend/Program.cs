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
builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer((document, context, cancellationToken) =>
    {
        document.Info.Title = "LokYatra API";
        document.Info.Version = "v1";
        
        // Force HTTPS production URL so Scalar doesn't use HTTP or localhost
        document.Servers = new List<Microsoft.OpenApi.Models.OpenApiServer> 
        { 
            new Microsoft.OpenApi.Models.OpenApiServer { Url = "https://lokyatra-production.up.railway.app" } 
        };
        
        var scheme = new Microsoft.OpenApi.Models.OpenApiSecurityScheme
        {
            Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
            Name = "Authorization",
            In = Microsoft.OpenApi.Models.ParameterLocation.Header,
            Scheme = "bearer",
            BearerFormat = "JWT",
            Description = "Enter your JWT token in the format: {your token}"
        };
        
        document.Components ??= new Microsoft.OpenApi.Models.OpenApiComponents();
        document.Components.SecuritySchemes.Add("Bearer", scheme);
        
        document.SecurityRequirements.Add(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
        {
            [
                new Microsoft.OpenApi.Models.OpenApiSecurityScheme 
                { 
                    Reference = new Microsoft.OpenApi.Models.OpenApiReference 
                    { 
                        Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme, 
                        Id = "Bearer" 
                    } 
                }
            ] = Array.Empty<string>()
        });
        
        return Task.CompletedTask;
    });
});

// Railway provides DATABASE_URL
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
        policy => policy.SetIsOriginAllowed(_ => true) 
                        .AllowAnyMethod()
                        .AllowAnyHeader()
                        .WithExposedHeaders("Content-Disposition"));
});

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICloudImageService, CloudinaryImageService>();
builder.Services.AddScoped<NotificationService>();
builder.Services.AddHttpClient();

// Bind to Railway's dynamic PORT env var
var port = Environment.GetEnvironmentVariable("PORT");
Console.WriteLine($"[STARTUP] PORT={port ?? "not set"}, DATABASE_URL={(Environment.GetEnvironmentVariable("DATABASE_URL") != null ? "set" : "not set")}");
if (!string.IsNullOrEmpty(port))
    builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();
Console.WriteLine("[STARTUP] App built successfully");

// Auto-apply pending migrations on startup
using (var scope = app.Services.CreateScope())
{
    try
    {
        Console.WriteLine("[STARTUP] Running migrations...");
        scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.Migrate();
        Console.WriteLine("[STARTUP] Migrations complete");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[MIGRATION ERROR] {ex.GetType().Name}: {ex.Message}");
    }
}
Console.WriteLine("[STARTUP] Starting web server...");

app.UseRouting();
app.UseCors("AllowAll");


app.MapOpenApi();
app.MapScalarApiReference();

// Helper redirects for easier access
app.MapGet("/scalar", () => Results.Redirect("/scalar/v1"));
app.MapGet("/docs", () => Results.Redirect("/scalar/v1"));

if (app.Environment.IsDevelopment())
{
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/health", () => Results.Ok("healthy"));

app.Run();