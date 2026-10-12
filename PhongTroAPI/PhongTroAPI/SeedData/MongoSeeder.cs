using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Driver;
using PhongTroAPI.Entities;
using PhongTroAPI.Repositories.Mongo;
using System;
using System.Reflection;

namespace PhongTroAPI.SeedData
{
    public class MongoSeeder
    {
        private readonly TaiKhoanRepository _taiKhoanRepo;
        private readonly NganHangRepository _nganHangRepo;
        private readonly TienIchRepository _tienIchRepo;
        private readonly NguoiQuanLyRepository _quanLyRepo;
        private readonly KhachThueRepository _khachThueRepo;
        private readonly CoSoRepository _coSoRepo;
        private readonly PhongRepository _phongRepo;
        private readonly HoaDonRepository _hoaDonRepo;
        private readonly HopDongRepository _hopDongRepo;
        private readonly ChiSoRepository _chiSoRepo;
        private readonly LichHenRepository _lichHenRepo;
        private readonly TinNhanRepository _tinNhanRepo;
        private readonly SuCoRepository _suCoRepo;
        private readonly OGhepRepository _oGhepRepo;
        private readonly CounterRepository _counterRepo;

        public MongoSeeder(
            TaiKhoanRepository taiKhoanRepo, NganHangRepository nganHangRepo,
            TienIchRepository tienIchRepo, NguoiQuanLyRepository quanLyRepo,
            KhachThueRepository khachThueRepo, CoSoRepository coSoRepo,
            PhongRepository phongRepo, HoaDonRepository hoaDonRepo,
            HopDongRepository hopDongRepo, ChiSoRepository chiSoRepo,
            LichHenRepository lichHenRepo, TinNhanRepository tinNhanRepo,
            SuCoRepository suCoRepo, OGhepRepository oGhepRepo,
            CounterRepository counterRepo)
        {
            _taiKhoanRepo = taiKhoanRepo; _nganHangRepo = nganHangRepo;
            _tienIchRepo = tienIchRepo; _quanLyRepo = quanLyRepo;
            _khachThueRepo = khachThueRepo; _coSoRepo = coSoRepo;
            _phongRepo = phongRepo; _hoaDonRepo = hoaDonRepo;
            _hopDongRepo = hopDongRepo; _chiSoRepo = chiSoRepo;
            _lichHenRepo = lichHenRepo; _tinNhanRepo = tinNhanRepo;
            _suCoRepo = suCoRepo; _oGhepRepo = oGhepRepo;
            _counterRepo = counterRepo;
        }

        public async Task SeedAsync()
        {
            var dataPath = Path.Combine(Directory.GetCurrentDirectory(), "SeedData", "Data");
            if (!Directory.Exists(dataPath)) return;

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            options.Converters.Add(new IntToBoolConverter());

            await SeedCollection<NganHang>(_nganHangRepo, "NganHang.json", dataPath, options, "nganhang_id");
            await SeedCollection<TienIch>(_tienIchRepo, "TienIch.json", dataPath, options, "tienich_id");
            await SeedCollection<TaiKhoan>(_taiKhoanRepo, "TaiKhoan.json", dataPath, options, "taikhoan_id");
            await SeedCollection<NguoiQuanLy>(_quanLyRepo, "NguoiQuanLy.json", dataPath, options, "nguoiquanly_id");
            await SeedCollection<KhachThue>(_khachThueRepo, "KhachThue.json", dataPath, options, "khachthue_id");
            await SeedCollection<CoSo>(_coSoRepo, "CoSo.json", dataPath, options, "coso_id");
            await SeedCollection<Phong>(_phongRepo, "Phong.json", dataPath, options, "phong_id");
            await SeedCollection<HopDongThue>(_hopDongRepo, "HopDongThue.json", dataPath, options, "hopdong_id");
            await SeedCollection<HoaDon>(_hoaDonRepo, "HoaDon.json", dataPath, options, "hoadon_id");
            await SeedCollection<ChiSoDienNuoc>(_chiSoRepo, "ChiSoDienNuoc.json", dataPath, options, "chiso_id");
            await SeedCollection<LichHenXemPhong>(_lichHenRepo, "LichHenXemPhong.json", dataPath, options, "lichhen_id");
            await SeedCollection<TinNhan>(_tinNhanRepo, "TinNhan.json", dataPath, options, "tinnhan_id");
            await SeedCollection<SuCo>(_suCoRepo, "SuCo.json", dataPath, options, "suco_id");
            await SeedCollection<OGhep>(_oGhepRepo, "OGhep.json", dataPath, options, "oghep_id");
        }

        private async Task SeedCollection<T>(dynamic repo, string fileName, string path, JsonSerializerOptions options, string counterName)
        {
            var existing = await repo.GetAllAsync();
            if (existing != null && ((IEnumerable<T>)existing).Any()) return;

            var fullPath = Path.Combine(path, fileName);
            if (!File.Exists(fullPath)) return;

            var json = await File.ReadAllTextAsync(fullPath);
            var items = JsonSerializer.Deserialize<List<T>>(json, options);
            if (items == null || !items.Any()) return;

            foreach (var item in items)
            {
                await repo.CreateAsync(item);
            }

            int maxId = 0;
            foreach (var item in items)
            {
                var props = item.GetType().GetProperties();
                var idProp = props.FirstOrDefault(p => p.Name.StartsWith("Ma") || p.Name == "Id");
                if (idProp != null && idProp.PropertyType == typeof(int))
                {
                    int id = (int)idProp.GetValue(item);
                    if (id > maxId) maxId = id;
                }
            }
            
            if (maxId > 0)
            {
                await _counterRepo.InitializeSequenceValueAsync(counterName, maxId);
            }
        }
    }

    public class IntToBoolConverter : System.Text.Json.Serialization.JsonConverter<bool>
    {
        public override bool Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType == JsonTokenType.Number)
            {
                return reader.GetInt32() != 0;
            }
            if (reader.TokenType == JsonTokenType.True) return true;
            if (reader.TokenType == JsonTokenType.False) return false;
            
            return false;
        }

        public override void Write(Utf8JsonWriter writer, bool value, JsonSerializerOptions options)
        {
            writer.WriteBooleanValue(value);
        }
    }
}
