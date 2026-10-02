import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050A0F), // Nền form màu đen
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 50, offset: Offset(0, 25)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDarkInputField(
                        label: "MẬT KHẨU HIỆN TẠI",
                        icon: Icons.lock_outline,
                        hint: "••••••••",
                        obscureText: _obscureCurrent,
                        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildDarkInputField(
                        label: "MẬT KHẨU MỚI",
                        icon: Icons.lock_outline,
                        hint: "••••••••",
                        obscureText: _obscureNew,
                        onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 20),
                      
                      // Security Checklist
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildChecklistItem(text: "Có ít nhất 8 ký tự", isMet: true),
                            const SizedBox(height: 12),
                            _buildChecklistItem(text: "Có chữ hoa & chữ thường", isMet: false),
                            const SizedBox(height: 12),
                            _buildChecklistItem(text: "Có chữ số hoặc ký tự đặc biệt", isMet: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildDarkInputField(
                        label: "XÁC NHẬN MẬT KHẨU MỚI",
                        icon: Icons.lock_outline,
                        hint: "••••••••",
                        obscureText: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 32),
                      
                      // Nút Cập nhật
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF988BE9), // Tím nhạt
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 5,
                            shadowColor: const Color(0xFF2DD4BF).withOpacity(0.2), // Bóng xanh mint
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.check_circle_outline, color: Color(0xFF0D0F11)),
                          label: const Text(
                            "Cập nhật mật khẩu",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0F11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Column(
            children: const [
              Text("Đổi mật khẩu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D0F11))),
              SizedBox(height: 4),
              Text("Vui lòng nhập mật khẩu mới của bạn", style: TextStyle(fontSize: 12, color: Color(0xFF0D0F11))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({required String text, required bool isMet}) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? const Color(0xFF21BE98) : const Color(0xFF595959),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? const Color(0xFF21BE98) : const Color(0xFF595959),
          ),
        ),
      ],
    );
  }

  Widget _buildDarkInputField({
    required String label,
    required IconData icon,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2DD4BF)), // Mint Green Icon
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.5), fontSize: 14),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF94A3B8), size: 20),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}