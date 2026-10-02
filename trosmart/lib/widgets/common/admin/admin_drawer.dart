import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:trosmart/views/auth/login_screen.dart';
import '../../../models/admin/admin_pages.dart';

class AdminDrawer extends StatelessWidget {
  final String activePage;
  final Function(String) onPageSelected;

  const AdminDrawer({
    super.key,
    required this.activePage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 290,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _item(LucideIcons.layoutGrid, AdminPages.dashboard),
                  _item(LucideIcons.building, AdminPages.coSo),
                  _item(LucideIcons.doorClosed, AdminPages.phong),
                  _item(LucideIcons.wallet, AdminPages.thuThue),
                  _item(LucideIcons.fileText, AdminPages.hopDong),
                  _item(LucideIcons.zap, AdminPages.dienNuoc),
                  _item(LucideIcons.alertTriangle, AdminPages.suCo),
                  _item(LucideIcons.bell, AdminPages.thongBao),
                  _item(LucideIcons.calendar, AdminPages.lichCongViec),
                  _item(LucideIcons.barChart2, AdminPages.baoCao),
                  _item(LucideIcons.messageCircle, AdminPages.chat),
                  _item(LucideIcons.settings, AdminPages.caiDat),
                ],
              ),
            ),
            _buildFooterProfile(context),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String pageName, {String? badge}) {
    final isActive = activePage == pageName;

    // Màu sắc theo ảnh AD_Menu2
    final activeColor = const Color(0xFF7C53C7);
    final inactiveColor = const Color(0xFF8C7BB2);

    final activeBg = const Color(0xFFF3EDFC);
    final inactiveBg = Colors.white;

    final activeBorder = const Color(0xFFB794F4);
    final inactiveBorder = const Color(0xFFE2E0F4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => onPageSelected(pageName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? activeBorder : inactiveBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  pageName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB794F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TroSmart',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F1A30),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'QUẢN LÝ NHÀ TRỌ',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.black26,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF9E77F1),
                child: Text(
                  'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trọ Smart User',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F1A30),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'user@trosmart.vn',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (router) => false,
                );
              },
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
