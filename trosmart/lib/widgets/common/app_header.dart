import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Clean white header bar matching the "Guest" UI design.
class AppGradientHeader extends StatelessWidget {
  final String roleLabel;
  final bool isDarkText;
  final VoidCallback? onMenuTap;

  const AppGradientHeader({
    super.key,
    this.roleLabel = 'Guest',
    this.isDarkText = false,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65, // Hoặc bọc trong SafeArea nếu không dùng Scaffold.appBar
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFFF3F4F6), // Đường viền xám mờ ở dưới
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cụm Menu + Logo gộp chung bên trái
            Row(
              children: [
                GestureDetector(
                  onTap: onMenuTap,
                  child: const _HamburgerIcon(color: Color(0xFF111827)), // Màu tối chuẩn
                ),
                const SizedBox(width: 16),
                _TroSmartLogo(),
              ],
            ),
            
            // Badge nằm bên phải
            _RoleBadge(label: roleLabel),
          ],
        ),
      ),
    );
  }
}

class _HamburgerIcon extends StatelessWidget {
  final Color color;
  const _HamburgerIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chỉnh lại 3 gạch dài bằng nhau cho giống hình
          Container(
            width: 22,
            height: 2,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            width: 22, 
            height: 2,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            width: 22,
            height: 2,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}

class _TroSmartLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dấu chấm tròn màu xanh Teal thay vì hình vuông
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF2DDCB1), // AppTheme.accentTeal
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'TroSmart',
          style: TextStyle(
            color: Color(0xFF111827), // Chữ màu tối đậm
            fontSize: 20,
            fontFamily: 'Poppins', 
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;

  const _RoleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Nền xám nhạt
        borderRadius: BorderRadius.circular(20), // Bo góc tạo hình viên thuốc
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon người dùng
          const Icon(
            Icons.person_outline, 
            size: 16, 
            color: Color(0xFF4B5563) // Màu icon xám đậm
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111827), // Chữ màu tối
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple header with back button and title for detail screens.
/// (Phần này tôi giữ nguyên không sửa vì không liên quan đến hình ảnh)
class AppDetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackTap;

  const AppDetailHeader({
    super.key,
    required this.title,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: AppTheme.bgWhite),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap ?? () => Navigator.maybePop(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.headingMd.copyWith(
                color: Colors.black,
                letterSpacing: -0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}