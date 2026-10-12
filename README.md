# 🏠 TroSmart - Smart Hostel Management System (Multi-Model NoSQL)

Dự án **TroSmart** là hệ thống quản lý phòng trọ thông minh, được xây dựng theo kiến trúc phân tách Client-Server hiện đại. Dự án vừa trải qua quá trình Migration lớn từ hệ quản trị CSDL quan hệ (SQL Server) sang kiến trúc **Multi-Model NoSQL** nhằm giải quyết các bài toán về hiệu suất, khả năng mở rộng và tìm kiếm thông minh.

Hệ thống hỗ trợ đa vai trò (Người thuê & Chủ trọ), với khả năng gợi ý phòng, tìm kiếm toàn văn bản siêu tốc, và quản lý linh hoạt.

---

## 🏗 Kiến Trúc Hệ Thống

### 1. Backend API (`/PhongTroAPI`) - Multi-Model NoSQL
Backend được phát triển bằng **ASP.NET Core 8 Web API**, tích hợp 4 cơ sở dữ liệu NoSQL khác nhau để phân tải và chuyên biệt hóa từng luồng xử lý:

* **MongoDB (Document DB):** Đóng vai trò là Cơ sở dữ liệu chính (Primary Database). Lưu trữ toàn bộ dữ liệu nghiệp vụ (Cơ sở, Phòng, Khách thuê, Hợp đồng, Hóa đơn) dưới dạng JSON Document để tránh các truy vấn JOIN phức tạp.
* **Elasticsearch (Search Engine):** Đóng vai trò làm Search Engine và Analytics Engine. Lưu trữ các chỉ mục (indexes) của Phòng để hỗ trợ tính năng Full-text search, lọc nâng cao theo giá/tiện ích, và tính toán báo cáo thống kê doanh thu tốc độ cao.
* **Neo4j (Graph DB):** Đóng vai trò hệ thống khuyến nghị (Recommendation Engine). Quản lý mối quan hệ giữa người thuê (KhachThue) và phòng (Phong) qua các action như `[:XEM]`, `[:THUE]` để gợi ý phòng thông minh dựa trên hành vi của người dùng khác.
* **Redis (Key-Value DB):** Đóng vai trò làm Cache & Session store. Lưu trữ và quản lý token/session đăng nhập, caching dữ liệu tần suất cao (danh sách phòng trống), và TTL cho hệ thống thông báo.

### 2. Frontend App (`/trosmart`) - Flutter
Ứng dụng di động được xây dựng bằng **Flutter**, tuân theo cấu trúc phân lớp (Layer-based Architecture) chia tách minh bạch giữa Giao diện, Dịch vụ và Data Models.

---

## 📂 Cấu trúc thư mục Frontend (trosmart)

```text
trosmart/
├── assets/                 # Tài nguyên tĩnh (Hình ảnh, Icons)
├── lib/
│   ├── logic/              # XỬ LÝ LOGIC & DỊCH VỤ (API Services, Controllers)
│   │   ├── admin/          # Logic xử lý phía chủ trọ (CoSo, Invoice, Phong...)
│   │   └── user/           # Logic xử lý phía người thuê
│   ├── models/             # ĐỊNH NGHĨA DỮ LIỆU (DTOs, Entities)
│   ├── shared/             # CẤU HÌNH DÙNG CHUNG (App Colors, Themes)
│   ├── views/              # LỚP HIỂN THỊ (Screens)
│   │   ├── admin/          # Giao diện dành cho Chủ trọ (Quản lý phòng, Thống kê, v.v.)
│   │   └── user/           # Giao diện dành cho Người thuê (Tìm kiếm, Chi tiết phòng, Thanh toán)
│   ├── widgets/            # THÀNH PHẦN GIAO DIỆN NHỎ (Components tái sử dụng)
│   └── main.dart           # Điểm khởi chạy ứng dụng (Entry Point)
└── pubspec.yaml            # Quản lý dependencies
```

---

## 🚀 Hướng Dẫn Khởi Chạy Môi Trường Cục Bộ

Để chạy dự án TroSmart trên máy tính local, bạn cần làm theo các bước sau:

### Bước 1: Khởi động hệ sinh thái NoSQL Databases
Dự án cung cấp sẵn file `docker-compose.yml` để dễ dàng dựng 4 database cùng lúc.
Yêu cầu: Đã cài đặt **Docker** và **Docker Compose**.

Mở terminal tại thư mục gốc của dự án (`TroSmart-main`) và chạy:
```bash
docker-compose up -d
```
Lệnh này sẽ tải image và chạy 4 container: `mongodb` (port 27017), `elasticsearch` (port 9200), `neo4j` (port 7474, 7687) và `redis` (port 6379).

### Bước 2: Khởi động Backend API
1. Chuyển vào thư mục Backend:
```bash
cd PhongTroAPI/PhongTroAPI
```
2. Phục hồi các packages và build:
```bash
dotnet restore
dotnet build
```
3. Chạy API:
```bash
dotnet run
```
API sẽ chạy ở địa chỉ mặc định (vd: `http://localhost:5137`). (Lưu ý: Data seeding từ file SQL cũ đã được tích hợp qua module `DataSeeder`).

### Bước 3: Khởi động Frontend Flutter
1. Chuyển sang thư mục ứng dụng Flutter:
```bash
cd trosmart
```
2. Cập nhật các dependencies:
```bash
flutter pub get
```
3. Chạy ứng dụng trên thiết bị (hoặc máy ảo/web):
```bash
flutter run
```
*(Hãy chắc chắn đổi Base URL trong source code Flutter về `http://localhost:5137/api` hoặc IPv4 của máy tính nếu chạy trên máy ảo di động).*

---

## 📋 Thông Tin Bổ Sung
- **API Swagger Documentation:** Có thể truy cập thông qua `http://localhost:5137/swagger/index.html` khi backend đang chạy.
- **Tài khoản mặc định (Test):** Sử dụng các tài khoản có trong DB (đã được migrate từ data SQL) để kiểm thử luồng admin và user.
