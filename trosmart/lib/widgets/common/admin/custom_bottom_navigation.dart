import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../views/admin/AD_TrangChu.dart';
import '../../../views/admin/AD_HoaDon.dart';
import '../../../views/admin/AD_QLPhong.dart';
import '../../../views/admin/settings_screen.dart';
import '../../../logic/admin/invoice_controller.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    // Nếu có truyền onTap tuỳ chỉnh thì dùng nó (ví dụ trong navigation_screen_admin)
    if (onTap != null) {
      onTap!(index);
      return;
    }

    Widget page;
    switch (index) {
      case 0:
        page = const AdminHomeScreen();
        break;
      case 1:
        page = ChangeNotifierProvider(
          create: (_) => InvoiceController(),
          child: const InvoiceScreen(),
        );
        break;
      case 2:
        page = const PhongManagementView(maCoSo: 1, tenCoSo: 'Cơ sở 1');
        break;
      case 3:
        page = const AdminSettingsScreen();
        break;
      default:
        return;
    }
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _navigate(context, 0),
            child: NavItem(icon: Icons.home_outlined, label: 'Trang chủ', isActive: currentIndex == 0),
          ),
          GestureDetector(
            onTap: () => _navigate(context, 1),
            child: NavItem(icon: Icons.description, label: 'Hóa đơn', isActive: currentIndex == 1),
          ),
          GestureDetector(
            onTap: () => _navigate(context, 2),
            child: NavItem(icon: Icons.business_outlined, label: 'Phòng', isActive: currentIndex == 2),
          ),
          GestureDetector(
            onTap: () => _navigate(context, 3),
            child: NavItem(icon: Icons.person_outline_rounded, label: 'Tài khoản', isActive: currentIndex == 3),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({required this.icon, required this.label, this.isActive = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF2DDCB1) : Colors.black26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF2DDCB1) : Colors.black26,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: Color(0xFF2DDCB1), shape: BoxShape.circle),
          ),
      ],
    );
  }
}