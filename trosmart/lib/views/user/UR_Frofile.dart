import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trosmart/shared/app_theme.dart';
import 'package:trosmart/shared/api_constants.dart';
import 'package:trosmart/views/auth/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  bool _isEditingProfile = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();

  int _maKhach = 0;

  // Trạng thái cho các Toggles (Switch)
  bool pushNotification = true;
  bool paymentReminder = true;
  bool maintenanceAlert = false;
  bool newMessages = true;
  bool contractReminder = true;
  bool biometricAuth = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _maKhach = prefs.getInt('ma_khach') ?? 1; // Fallback to 1

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/KhachThue/$_maKhach'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['hoTen'] ?? '';
          _phoneController.text = data['sdt'] ?? '';
          _emailController.text = data['email'] ?? '';
          _cccdController.text = data['cccd'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/KhachThue/$_maKhach'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'maKhach': _maKhach,
          'hoTen': _nameController.text.trim(),
          'sdt': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'cccd': _cccdController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _isEditingProfile = false;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật thông tin cá nhân!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB794F4)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            _buildProfileSummary(),
            const SizedBox(height: 32),
            _buildPersonalInfoForm(),
            const Divider(height: 48, color: Color(0xFFF3F4F6), thickness: 1),
            _buildNotificationSettings(),
            const Divider(height: 48, color: Color(0xFFF3F4F6), thickness: 1),
            _buildSecuritySettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Hồ Sơ Cá Nhân",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _nameController.text.isNotEmpty
                    ? _nameController.text[0].toUpperCase()
                    : "K",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : "Khách thuê",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _phoneController.text.isNotEmpty
              ? _phoneController.text
              : "Chưa cập nhật SĐT",
          style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: const Text(
            "Người thuê",
            style: TextStyle(
              color: Color(0xFF0D9488),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Thông tin cá nhân",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditingProfile = !_isEditingProfile;
                });
              },
              child: Text(
                _isEditingProfile ? "Hủy" : "Chỉnh sửa",
                style: const TextStyle(fontSize: 12, color: Color(0xFF0D9488)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "HỌ VÀ TÊN",
          _nameController,
          enabled: _isEditingProfile,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          "SỐ ĐIỆN THOẠI",
          _phoneController,
          enabled: _isEditingProfile,
        ),
        const SizedBox(height: 20),
        _buildTextField("EMAIL", _emailController, enabled: _isEditingProfile),
        const SizedBox(height: 20),
        _buildTextField(
          "SỐ CCCD / CMND",
          _cccdController,
          enabled: _isEditingProfile,
          isVerified: true,
        ),
        const SizedBox(height: 24),
        if (_isEditingProfile)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB794F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFB794F4).withOpacity(0.4),
              ),
              child: const Text(
                "Lưu Thay Đổi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = false,
    bool isVerified = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF718096),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFB794F4)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: enabled
                    ? TextField(
                        controller: controller,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : "Chưa cập nhật",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                      ),
              ),
              if (isVerified && !enabled)
                const Text(
                  "Đã xác thực",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF0D9488),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xFF0D9488),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Cài Đặt Thông Báo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSwitchTile(
          "Thông báo đẩy",
          "Nhận thông báo trên điện thoại",
          pushNotification,
          (val) => setState(() => pushNotification = val),
        ),
        _buildSwitchTile(
          "Nhắc nhở thanh toán",
          "Thông báo hóa đơn đến hạn",
          paymentReminder,
          (val) => setState(() => paymentReminder = val),
        ),
        _buildSwitchTile(
          "Cảnh báo bảo trì",
          "Lịch bảo trì và sửa chữa",
          maintenanceAlert,
          (val) => setState(() => maintenanceAlert = val),
        ),
        _buildSwitchTile(
          "Tin nhắn mới",
          "Thông báo từ chủ nhà",
          newMessages,
          (val) => setState(() => newMessages = val),
        ),
        _buildSwitchTile(
          "Hợp đồng sắp hết hạn",
          "Nhắc nhở gia hạn hợp đồng",
          contractReminder,
          (val) => setState(() => contractReminder = val),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFB794F4),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security,
                color: Color(0xFF0D9488),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Bảo Mật",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionTile("Đổi mật khẩu", Icons.chevron_right, onTap: () {}),
        const SizedBox(height: 12),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Xác thực sinh trắc học",
                style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
              Switch(
                value: biometricAuth,
                onChanged: (val) => setState(() => biometricAuth = val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFFB794F4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9FAFB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              elevation: 0,
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
            Icon(icon, size: 20, color: const Color(0xFF718096)),
          ],
        ),
      ),
    );
  }
}
