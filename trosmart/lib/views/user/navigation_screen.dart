import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:trosmart/models/user/app_pages.dart';
import 'package:trosmart/views/user/UR_BaoCaoSuCo.dart';
import 'package:trosmart/views/user/UR_DanhSachChat.dart';
import 'package:trosmart/views/user/UR_HopDong.dart';
import 'package:trosmart/views/user/UR_OGhep.dart';
import 'package:trosmart/views/user/UR_ThongBao.dart';
import 'package:trosmart/views/user/UR_TrangChu.dart';
import 'package:trosmart/views/user/UR_Frofile.dart';
import 'package:trosmart/views/user/UR_TimKiemPhong.dart';
import 'package:trosmart/views/user/UR_ThongKe.dart';
import 'package:trosmart/widgets/common/user/user_app_bar.dart';
import 'app_sidebar.dart';
import 'UR_ThanhToan.dart';
import 'package:trosmart/logic/user/user_contract_controller.dart';
import 'package:trosmart/logic/user/user_payment_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 1. Quản lý bằng Tên Trang
  String _activePage = AppPages.home;

  // 2. Danh sách các trang hiển thị trong IndexedStack
  // Thứ tự này sẽ tương ứng với số index của IndexedStack
  final List<String> _pageOrder = [
    AppPages.home,              // 0: Trang chủ
    AppPages.payment,           // 1: Thanh toán
    AppPages.chat,              // 2: Chat
    AppPages.contract,          // 3: Hợp đồng
    AppPages.searchroom,        // 4: Tra cứu phòng
    AppPages.reportIssue,       // 5: Báo cáo sự cố
    AppPages.notifications,     // 6: UrThongBao 
    AppPages.accommodationShare,// 7: Ở ghép
    AppPages.stats,             // 8: HistoryStatsScreen
    AppPages.profileDetail,     // 9: Cá nhân
  ];

  // 3. Hàm điều hướng dùng chung
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
    if (_activePage == AppPages.home) return 0;
    if (_activePage == AppPages.payment) return 1;
    if (_activePage == AppPages.chat) return 2;
    if (_activePage == AppPages.profileDetail) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserContractController()),
        ChangeNotifierProvider(create: (_) => UserPaymentController()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: UserAppBar(), // Hiển thị tiêu đề động
            drawer: AppSidebar(
              activePage: _activePage, 
              onPageSelected: _navigateTo,
            ),
            body: IndexedStack(
              index: _pageOrder.indexOf(_activePage), // Tự động tìm số thứ tự dựa trên tên
              children: [
                const UserHomeScreen(),                       // 0
                const PaymentDetailsScreen(),                 // 1
                const UrDanhSachChat(),                           // 2
                const UrHopDong(),                            // 3
                const RoomSearchView(),                       // 4
                const IssueReportingScreen(),                 // 5
                UrThongBao(onNavigateToPayment: () => _navigateTo(AppPages.payment)), // 6
                const UrOGhep(),                              // 7
                const HistoryStatsScreen(),                   // 8
                const UserProfileScreen(),                    // 9
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _getBottomNavIndex(),
              onTap: (index) {
                // Ánh xạ từ số bấm ở dưới ra Tên trang tương ứng
                final bottomPages = [AppPages.home, AppPages.payment, AppPages.chat, AppPages.profileDetail];
                _navigateTo(bottomPages[index]);
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.purple,
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'TRANG CHỦ'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.creditCard), label: 'THANH TOÁN'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.messageCircle), label: 'CHAT'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'HỒ SƠ'),
              ],
            ),
          );
        }
      ),
    );
  }
}