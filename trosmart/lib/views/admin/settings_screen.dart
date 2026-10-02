import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool isDarkMode = true; // State cho Theme selector

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Background Header xám theo thiết kế
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120, // Độ cao bù trừ cho Profile Card
            child: Container(color: const Color(0xFFC2B5B5)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // Không gian cho BottomNav
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle("THÔNG TIN CÁ NHÂN"),
                  _buildPersonalInfoCard(),
                  const SizedBox(height: 16),
                  _buildNotificationsCard(),
                  const SizedBox(height: 16),
                  _buildSectionTitle("BẢO MẬT & CÀI ĐẶT"),
                  _buildSecurityCard(),
                  const SizedBox(height: 16),
                  _buildThemeCard(),
                  const SizedBox(height: 16),
                  _buildLanguageCard(),
                  const SizedBox(height: 16),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DDCB1), Color(0xFF1AAB87)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DDCB1).withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "M",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DDCB1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0D1520),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.edit, size: 10, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Nguyễn Minh",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Cài đặt tài khoản",
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2DDCB1),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC6A3092), // Tím với opacity 0.8
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "HỌ TÊN",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xCC6A3092),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Nguyễn Minh",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 2, height: 30, color: const Color(0xFF2DDCB1)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "SỐ ĐIỆN THOẠI",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xCC6A3092),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "0901 234 567",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC6A3092),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Thông báo",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0x1E2DDCB1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 15,
                    color: Color(0xFF2DDCB1),
                  ),
                ),
              ],
            ),
          ),
          _buildAdminListTile(
            "Nhắc thu tiền",
            "Rent Collection",
            Icons.monetization_on,
            showSwitch: true,
          ),
          _buildAdminListTile(
            "Phòng trống",
            "Vacant Rooms",
            Icons.meeting_room,
            showSwitch: true,
          ),
          _buildAdminListTile(
            "Bảo trì",
            "Maintenance",
            Icons.build,
            showSwitch: true,
          ),
          _buildAdminListTile(
            "Tin nhắn",
            "Messages",
            Icons.message,
            showSwitch: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC6A3092),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAdminListTile(
            "Mật khẩu",
            "Password",
            Icons.lock,
            iconColor: const Color(0xFF6382FF),
          ),
          _buildAdminListTile(
            "Bảo mật",
            "Security",
            Icons.shield,
            iconColor: const Color(0xFFA78BFA),
          ),
          _buildAdminListTile(
            "Quản lý thiết bị",
            "Managed Devices",
            Icons.devices,
            iconColor: const Color(0xFFFB923C),
          ),
          _buildAdminListTile(
            "Tải hợp đồng",
            "Download Contract",
            Icons.download,
            iconColor: const Color(0xFF2DDCB1),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminListTile(
    String title,
    String subtitle,
    IconData icon, {
    Color iconColor = const Color(0xFF2DDCB1),
    bool showSwitch = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(top: BorderSide(color: Color(0x142DDCB1))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
          if (showSwitch)
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF2DDCB1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x662DDCB1), blurRadius: 12),
                ],
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(3),
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF050A0F),
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            const Icon(Icons.chevron_right, color: Color(0x662DDCB1)),
        ],
      ),
    );
  }

  Widget _buildThemeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC6A3092),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Giao diện",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption("Sáng", Icons.light_mode, false),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildThemeOption("Tối", Icons.dark_mode, true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = isActive),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0x142DDCB1)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF2DDCB1) : const Color(0x332DDCB1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1A2535) : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF2DDCB1) : Colors.white54,
                size: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF2DDCB1) : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC6A3092),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildAdminListTile(
        "Tiếng Việt",
        "Vietnamese",
        Icons.language,
        iconColor: const Color(0xFFEF4444),
        isLast: true,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x66E74C3C), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            "Đăng xuất",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
