##### # 🏠 TroSmart - Smart Hostel Management System

Dự án TroSmart được tổ chức theo cấu trúc phân lớp (Layer-based Architecture), chia tách minh bạch giữa Giao diện (View), Thành phần (Widget), Dữ liệu (Model) và Logic xử lý. Hệ thống được thiết kế để hỗ trợ đa vai trò (Người thuê & Chủ trọ).

## 📂 Cấu trúc thư mục chi tiết (trosmart)

```text
trosmart/
├── assets/                 # Tài nguyên tĩnh
│   └── images/             # Hình ảnh minh họa và icons của ứng dụng
├── lib/
│   ├── logic/              # XỬ LÝ LOGIC & DỊCH VỤ (API Services, Controllers)
│   │   └── admin/          # Logic xử lý cho phía chủ trọ
│   │       ├── co_so_service.dart     # Quản lý dữ liệu cơ sở/tòa nhà
│   │       ├── invoice_controller.dart # Điều khiển luồng dữ liệu hóa đơn
│   │       ├── invoice_service.dart    # Gọi API liên quan đến hóa đơn
│   │       └── phong_service.dart      # Quản lý dữ liệu phòng trọ
│   ├── models/             # ĐỊNH NGHĨA DỮ LIỆU (DTOs, Entities)
│   │   ├── admin/          # Models phục vụ các tính năng quản lý
│   │   │   ├── co_so_model.dart       # Cấu trúc dữ liệu cơ sở
│   │   │   ├── invoice_model.dart     # Cấu trúc dữ liệu hóa đơn
│   │   │   ├── phong_model.dart       # Cấu trúc dữ liệu phòng
│   │   │   └── tien_ich_model.dart    # Cấu trúc dữ liệu dịch vụ (điện, nước...)
│   │   └── user/
│   │       └── app_pages.dart         # Cấu hình danh sách trang và điều hướng
│   ├── shared/             # CẤU HÌNH DÙNG CHUNG
│   │   ├── app_colors.dart            # Định nghĩa bảng màu thương hiệu
│   │   └── app_theme.dart             # Cấu hình Theme (Fonts, Styles, Dark/Light mode)
│   ├── views/              # LỚP HIỂN THỊ (Screens)
│   │   ├── admin/          # Giao diện dành cho Chủ trọ
│   │   │   ├── co_so_management_view.dart # Quản lý danh sách cơ sở
│   │   │   ├── phong_management_view.dart # Quản lý danh sách phòng
│   │   │   ├── invoice_screen.dart        # Danh sách hóa đơn
│   │   │   ├── add_invoice_screen.dart    # Tạo hóa đơn mới
│   │   │   ├── statistics_screen.dart     # Báo cáo thống kê doanh thu
│   │   │   ├── AD_Chat.dart               # Danh sách tin nhắn hỗ trợ
│   │   │   └── navigation_screen_admin.dart # Điều hướng chính của Admin
│   │   └── user/           # Giao diện dành cho Người thuê
│   │       ├── room_search_view.dart      # Tìm kiếm phòng trọ
│   │       ├── room_detail_view.dart      # Chi tiết phòng và đặt phòng
│   │       ├── payment_screen.dart        # Thanh toán hóa đơn hàng tháng
│   │       ├── UR_Chat.dart               # Nhắn tin trao đổi với chủ trọ
│   │       └── navigation_screen.dart     # Điều hướng chính của Người thuê
│   ├── widgets/            # THÀNH PHẦN GIAO DIỆN NHỎ (Components)
│   │   ├── admin/          # Widgets đặc thù cho giao diện Admin
│   │   │   ├── invoice_widgets.dart       # Các item card cho hóa đơn
│   │   │   └── utility_management_widgets.dart # Giao diện nhập chỉ số điện nước
│   │   ├── user/           # Widgets đặc thù cho giao diện Người thuê
│   │   │   ├── payment_widgets.dart       # Thành phần trong trang thanh toán
│   │   │   └── stats_widgets.dart         # Biểu đồ và thông số cá nhân
│   │   └── common/         # Widgets dùng chung cho toàn bộ app
│   │       ├── app_header.dart            # Thanh tiêu đề tùy chỉnh
│   │       ├── app_search_field.dart      # Thanh tìm kiếm đồng nhất
│   │       └── chat_bubble.dart           # Khung hiển thị nội dung chat
│   └── main.dart           # Điểm khởi chạy ứng dụng (Entry Point)
└── pubspec.yaml            # Quản lý dependencies và assets
```

---
*Lưu ý: Tài liệu này tập trung giải thích cấu trúc thư mục của ứng dụng di động (Flutter). Phần API Backend được quản lý trong thư mục PhongTroAPI riêng biệt.*
