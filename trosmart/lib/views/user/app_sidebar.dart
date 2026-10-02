import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:trosmart/models/user/app_pages.dart';
import 'package:trosmart/views/auth/login_screen.dart';
import '../../shared/app_colors.dart';
import '../../widgets/user/sidebar_item.dart';

class AppSidebar extends StatelessWidget {
 final String activePage;
  final Function(String) onPageSelected;

  const AppSidebar({
    super.key, 
    required this.activePage, 
    required this.onPageSelected
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _item(LucideIcons.home, AppPages.home),
                _item(LucideIcons.creditCard, AppPages.payment),
                _item(LucideIcons.fileText, AppPages.contract),
                _item(LucideIcons.search, AppPages.searchroom),
                _item(LucideIcons.alertTriangle, AppPages.reportIssue),
                _item(LucideIcons.messageCircle, AppPages.chat),
                _item(LucideIcons.bell, AppPages.notifications, hasDot: true),
                const Divider(height: 32),
                _item(LucideIcons.users, AppPages.accommodationShare),
                _item(LucideIcons.barChart2, AppPages.stats),
                _item(LucideIcons.user, AppPages.profileDetail),
              ],
            ),
          ),
          _buildFooterProfile(context),
        ],
      ),
    );
  }

  // Hàm tạo item nhanh để code sạch hơn
  Widget _item(IconData icon, String title, {String? badge, bool hasDot = false}) {
    return SidebarItem(
      icon: icon,
      title: title,
      badge: badge,
      hasDot: hasDot,
      isActive: activePage == title,
      onTap: () => onPageSelected(title),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: AppColors.adminDarkPurple,
          ),
          SizedBox(width: 12),
          Text(
            'TroSmart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundGray,
      child: Column(
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF00D1B2),
              child: Text(
                'T',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              'Trọ Smart User',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'user@trosmart.vn',
              style: TextStyle(fontSize: 11),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          SidebarItem(
            icon: LucideIcons.logOut,
            title: 'Đăng xuất',
            onTap: () {Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context)=>const LoginScreen()),
              (Route<dynamic> route) => false);},
          ),
        ],
      ),
    );
  }
}