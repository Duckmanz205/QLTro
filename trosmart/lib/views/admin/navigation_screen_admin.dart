import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trosmart/views/admin/AD_LichCongViec.dart';
import 'package:trosmart/views/admin/AD_QLHopDong.dart';
import 'package:trosmart/views/admin/AD_TrangChu.dart';
import 'package:trosmart/views/admin/settings_screen.dart';
// Import models
import '../../models/admin/admin_pages.dart';

// Import views
import 'select_manager_view.dart';
import 'AD_HoaDon.dart';
import 'AD_QLPhong.dart';
import 'AD_QLCoSo.dart';
import 'AD_QLDienNuoc.dart';
import 'AD_SuCo.dart';
import 'AD_ThongBao.dart';
import 'AD_QLThongKe.dart';
import 'AD_Chat.dart';
import 'admin_profile_screen.dart';

// Import widgets
import '../../widgets/common/admin/custom_app_bar.dart';
import '../../widgets/common/admin/custom_bottom_navigation.dart';
import '../../widgets/common/admin/admin_drawer.dart';

// Import logic
import '../../logic/admin/invoice_controller.dart';
import '../../logic/auth/auth_service.dart';

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  // 1. Quản lý trạng thái bằng Tên Trang như phía User
  String _activePage = AdminPages.dashboard;

  // 2. Danh sách các trang tương ứng với thứ tự hiển thị trong IndexedStack
  final List<String> _pageOrder = [
    AdminPages.dashboard, // 0
    AdminPages.coSo, // 1
    AdminPages.phong, // 2
    AdminPages.thuThue, // 3
    AdminPages.hopDong, // 4
    AdminPages.dienNuoc, // 5
    AdminPages.suCo, // 6
    AdminPages.thongBao, // 7
    AdminPages.lichCongViec, // 8
    AdminPages.baoCao, // 9
    AdminPages.chat, // 10
    AdminPages.caiDat, // 11
    AdminPages.taiKhoan, // 12
  ];

  // 3. Hàm điều hướng dùng chung để đóng drawer và chuyển trang
  void _navigateTo(String pageName) {
    setState(() {
      _activePage = pageName;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Tính toán Index cho BottomNavigationBar
  int _getBottomNavIndex() {
    if (_activePage == AdminPages.dashboard) return 0;
    if (_activePage == AdminPages.thuThue) return 1;
    if (_activePage == AdminPages.phong) return 2;
    if (_activePage == AdminPages.taiKhoan) return 3;
    return -1; // Trả về -1 để không làm sáng mục nào khi đang xem trang chi tiết từ Drawer
  }

  void _onBottomNavTapped(int index) {
    final bottomPages = [
      AdminPages.dashboard,
      AdminPages.thuThue,
      AdminPages.phong,
      AdminPages.taiKhoan,
    ];
    _navigateTo(bottomPages[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: AdminDrawer(activePage: _activePage, onPageSelected: _navigateTo),
      body: IndexedStack(
        index: _pageOrder.indexOf(_activePage),
        children: [
          AdminHomeScreen(onNavigate: _navigateTo), // 0: Dashboard
          const _CoSoManagementWrapper(), // 1: Cơ sở (Dynamic wrapper)
          const PhongManagementView(), // 2: Phòng
          ChangeNotifierProvider(
            create: (context) => InvoiceController(),
            child: const InvoiceScreen(),
          ), // 3: Thu & Thuê (Hóa đơn)
          const AdQLHopDong(), // 4: Hợp đồng (chờ hoàn thiện)
          UtilityManagementView(isActive: _activePage == AdminPages.dienNuoc), // 5: Điện nước
          const AD_SuCo(), // 6: Sự cố
          AD_ThongBao(onNavigate: _navigateTo), // 7: Thông báo
          const AdLichCongViec(), // 8: Lịch & Công việc
          const StatisticsScreen(), // 9: Báo cáo (Thống kê)
          const AdChat(), // 10: Chat
          const AdminSettingsScreen(), // 11: Cài đặt (chờ hoàn thiện)
          const AdminProfileScreen(), // 12: Tài khoản
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _getBottomNavIndex(),
        onTap: _onBottomNavTapped,
      ),
    );
  }
}

class _CoSoManagementWrapper extends StatefulWidget {
  const _CoSoManagementWrapper();

  @override
  State<_CoSoManagementWrapper> createState() => _CoSoManagementWrapperState();
}

class _CoSoManagementWrapperState extends State<_CoSoManagementWrapper> {
  int? _maQuanLy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaQuanLy();
  }

  Future<void> _loadMaQuanLy() async {
    final mq = await AuthService().getMaQuanLy();
    if (mounted) {
      setState(() {
        _maQuanLy = mq;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7430A3),
          ),
        ),
      );
    }
    return CoSoManagementView(maQuanLy: _maQuanLy ?? 1);
  }
}
