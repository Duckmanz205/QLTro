import 'package:flutter/material.dart';
import 'package:trosmart/views/admin/AD_HoaDon.dart';
import 'package:trosmart/views/admin/AD_QLDienNuoc.dart';
import 'package:trosmart/views/admin/AD_QLThongKe.dart';
import 'admin_sidebar.dart';
import 'admin_profile_screen.dart';
import '../../widgets/common/admin/custom_app_bar.dart';

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      drawer: const AdminSidebar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const StatisticsScreen(), // 0 - Trang chủ
          const InvoiceScreen(), // 1 - Hóa đơn
          UtilityManagementView(isActive: _currentIndex == 2), // 2 - Phòng / Điện nước
          const AdminProfileScreen(), // 3 - Tài khoản
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home, 'label': 'Trang chủ'},
      {'icon': Icons.description_outlined, 'label': 'Hóa đơn'},
      {'icon': Icons.home_outlined, 'label': 'Phòng'},
      {'icon': Icons.person_outline, 'label': 'Tài khoản'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = _currentIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isActive ? const Color(0xFF1F2937) : Colors.black45,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? const Color(0xFF1F2937) : Colors.black45,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
