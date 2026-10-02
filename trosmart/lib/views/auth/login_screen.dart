import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:trosmart/logic/auth/auth_service.dart';
import 'package:trosmart/views/admin/navigation_screen_admin.dart';
import 'package:trosmart/views/user/navigation_screen.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginByEmail = true;
  bool isRememberDevice = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    final String tenDangNhap = isLoginByEmail
        ? _emailController.text.trim()
        : _phoneController.text.trim();
    final String matKhau = _passwordController.text.trim();

    if (tenDangNhap.isEmpty || matKhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authResponse = await _authService.login(tenDangNhap, matKhau);
      if (!mounted) return;

      // 🌟 2. FIX LINH HOẠT CHỐT HẠ: Tự động lưu maKhach thực tế của phiên đăng nhập vào máy
      // Đảm bảo thuộc tính của authResponse trùng với biến trả về từ Backend (VD: authResponse.maKhach)
      final prefs = await SharedPreferences.getInstance();
      if (authResponse.maKhach != null) {
        await prefs.setInt('maKhach', authResponse.maKhach!);
        debugPrint("Đã lưu linh hoạt maKhach đăng nhập: ${authResponse.maKhach}");
      }

      // Điều hướng theo VaiTro
      if (authResponse.vaiTro == 'Admin' || authResponse.vaiTro == 'QuanLy' || authResponse.vaiTro == 'NguoiQuanLy') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminNavigationScreen(),
          ),
        );
      } else {
        // KhachThue → màn hình home user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chào mừng\ntrở lại 👋",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A0D2D),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Đăng nhập để quản lý nhà trọ của bạn",
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 24),

                  // Tab chuyển đổi
                  _buildTabSwitch(),
                  const SizedBox(height: 24),

                  // Input Fields
                  if (isLoginByEmail) ...[
                    CustomTextField(
                      controller: _emailController,
                      label: "Tên đăng nhập",
                      iconData: Icons.person_outline,
                      keyboardType: TextInputType.text,
                    ),
                  ] else ...[
                    CustomTextField(
                      controller: _phoneController,
                      label: "Tên đăng nhập",
                      iconData: Icons.person_outline,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: "Mật khẩu",
                    iconData: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  // Nhớ thiết bị & Quên MK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isRememberDevice,
                            onChanged: (val) {
                              setState(() => isRememberDevice = val ?? false);
                            },
                            activeColor: const Color(0xFF6A3092),
                          ),
                          const Text(
                            "Nhớ thiết bị",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Color(0xFF6A3092),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nút Đăng nhập hoặc vòng xoay Loading chờ API
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A3092)))
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A3092),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0x592DDCB1),
                            ),
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Login
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickLoginBtn(Icons.qr_code, "QR Code"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickLoginBtn(
                          Icons.fingerprint,
                          "Sinh trắc học",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.black26)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Hoặc tiếp tục với",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.black26)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Login
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialBtn(
                          "Google",
                          "assets/images/login/google.png",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialBtn(
                          "Facebook",
                          "assets/images/login/facebook.png",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Đăng ký ngay",
                          style: TextStyle(
                            color: Color(0xFF2DDCB1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA162D3), Color(0xFF644180), Color(0xFF28212D)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2DDCB1), Color(0xFF1AAB87)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            "TroSmart",
            style: TextStyle(
              color: Color(0xFF2DDCB1),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitch() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLoginByEmail = true;
                  _phoneController.clear();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isLoginByEmail
                      ? const Color(0xFF6A3092)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Email",
                  style: TextStyle(
                    color: isLoginByEmail ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLoginByEmail = false;
                  _emailController.clear();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !isLoginByEmail
                      ? const Color(0xFF6A3092)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Điện thoại",
                  style: TextStyle(
                    color: !isLoginByEmail ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginBtn(IconData icon, String label) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FA),
        border: Border.all(color: const Color(0xFF0D1822)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2DDCB1)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(String label, String iconPath) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FA),
        border: Border.all(color: const Color(0xFF0A1218)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.circle,
            size: 20,
          ), 
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}