import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trosmart/views/admin/AD_QLDienNuoc.dart';
import 'package:trosmart/views/admin/AD_QLThongKe.dart';
import '../../logic/admin/invoice_controller.dart';
import '../../views/admin/AD_HoaDon.dart';
import '../../views/admin/AD_TrangChu.dart';
import '../../views/admin/AD_QLCoSo.dart';
import '../../views/admin/AD_QLPhong.dart';
import '../../views/admin/AD_QLHopDong.dart';
import '../../views/admin/AD_SuCo.dart';
import '../../views/admin/AD_LichCongViec.dart';
import '../../views/admin/AD_Chat.dart';
import '../../views/admin/AD_ThongBao.dart';
import '../../views/admin/settings_screen.dart';

import '../../views/auth/login_screen.dart';

class AdminDrawer extends StatelessWidget {
  final String activeTitle;
  const AdminDrawer({Key? key, this.activeTitle = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          //header: logon + close button
          Padding(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2DDCB1), Color(0xFF1AAB87)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "TroSmart",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B8A9),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x662DDCB1)),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "OVERVIEW",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Menu Items List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    isActive: activeTitle == "Dashboard",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminHomeScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business,
                    title: "Cơ sở",
                    isActive: activeTitle == "Cơ sở",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CoSoManagementView(maQuanLy: 1),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.meeting_room,
                    title: "Phòng",
                    isActive: activeTitle == "Phòng",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhongManagementView(
                            maCoSo: 1,
                            tenCoSo: "Cơ sở 1",
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long,
                    title: "Thu & Thuê",
                    isActive: activeTitle == "Thu & Thuê",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => InvoiceController(),
                            child: const InvoiceScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: "Hợp đồng",
                    isActive: activeTitle == "Hợp đồng",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdQLHopDong(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.flash_on,
                    title: "Điện nước",
                    isActive: activeTitle == "Điện nước",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UtilityManagementView(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.build,
                    title: "Sự cố",
                    isActive: activeTitle == "Sự cố",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AD_SuCo(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_active,
                    title: "Thông báo",
                    isActive: activeTitle == "Thông báo",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AD_ThongBao(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_month,
                    title: "Lịch & Công việc",
                    isActive: activeTitle == "Lịch & Công việc",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdLichCongViec(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.pie_chart,
                    title: "Báo cáo",
                    isActive: activeTitle == "Báo cáo",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: "Chat",
                    isActive: activeTitle == "Chat",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdChat()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: "Cài đặt",
                    isActive: activeTitle == "Cài đặt",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Footer: User Profile & Sign Out
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA07ABA),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "T",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Trọ Smart User",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "user@trosmart.vn",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: const [
                        Icon(Icons.logout, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 10),
                        Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFFEFEFF), Color(0x146A3092)],
              )
            : null,
        border: Border.all(color: const Color(0xFF988BE9)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF976DB3) : const Color(0xCC6A3092),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF976DB3) : const Color(0xCC6A3092),
          ),
        ),
        trailing: badgeCount != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA07ABA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
