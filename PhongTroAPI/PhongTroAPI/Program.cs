using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using PhongTroAPI.Entities;
using System.Text;
using PhongTroAPI.Services;
using System.Text.Json;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// NoSQL DB Contexts
builder.Services.AddSingleton<PhongTroAPI.DataAccess.MongoDbContext>();
builder.Services.AddSingleton<PhongTroAPI.DataAccess.Neo4jDbContext>();
builder.Services.AddSingleton<PhongTroAPI.DataAccess.RedisDbContext>();
builder.Services.AddSingleton<PhongTroAPI.DataAccess.ElasticDbContext>();

//  CONFIG CONTROLLERS: Tối ưu hóa cấu hình JSON chống mất trường MaKhach
builder.Services.AddControllers().AddJsonOptions(options =>
{
    // 1. Chống vòng lặp vô hạn khi Include các bảng liên kết quan hệ
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    
    // 2. Ép giữ nguyên quy tắc đặt tên chữ cái đầu viết thường (camelCase) đồng bộ với Flutter
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    
    // 3.  Ép buộc trả ra toàn bộ các trường, kể cả khi mang giá trị bằng 0 hoặc null
    options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.Never;
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register NoSQL Repositories
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.ChiSoRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.CoSoRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.CounterRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.HoaDonRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.HopDongRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.KhachThueRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.LichHenRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.NganHangRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.NguoiQuanLyRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.OGhepRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.PhongRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.SuCoRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.TaiKhoanRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.TienIchRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Mongo.TinNhanRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Neo4j.GraphRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Redis.CacheRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Redis.NotificationRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Redis.SessionRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Elastic.AnalyticsRepository>();
builder.Services.AddScoped<PhongTroAPI.Repositories.Elastic.SearchRepository>();

// Register Custom Services
builder.Services.AddScoped<HopDongService>();
builder.Services.AddScoped<OGhepService>();
builder.Services.AddScoped<LichHenService>();
builder.Services.AddScoped<SyncService>();
builder.Services.AddScoped<GraphService>();
builder.Services.AddScoped<PhongTroAPI.Services.IInvoiceService, PhongTroAPI.Services.InvoiceService>();

// Register Seeders
builder.Services.AddScoped<PhongTroAPI.SeedData.MongoSeeder>();
builder.Services.AddScoped<PhongTroAPI.SeedData.ElasticSeeder>();
builder.Services.AddScoped<PhongTroAPI.SeedData.Neo4jSeeder>();
builder.Services.AddScoped<PhongTroAPI.SeedData.DataSeeder>();

// ✅ JWT Authentication
var jwtSecret = builder.Configuration["JwtSettings:SecretKey"]!;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["JwtSettings:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["JwtSettings:Audience"],
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

//  THÊM CORS CHO FLUTTER WEB
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

// Seed Data (Đã chạy ở Phase 6)
// using (var scope = app.Services.CreateScope())
// {
//     var seeder = scope.ServiceProvider.GetRequiredService<PhongTroAPI.SeedData.DataSeeder>();
//     await seeder.SeedAllAsync();
// }

// Swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Middleware
app.UseCors("AllowFlutterWeb");
app.UseStaticFiles();

app.UseAuthentication(); 
app.UseAuthorization();

app.MapControllers();

app.Run();