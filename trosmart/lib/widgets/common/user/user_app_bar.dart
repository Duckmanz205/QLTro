import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/app_colors.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const UserAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0, // Kéo Logo sát lại gần icon Menu
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textDark), // Chuyển menu sang màu tối
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dấu chấm tròn màu tím nhạt
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.primaryPurple, 
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // Chữ TroSmart in đậm, màu tối
          const Text(
            'TroSmart',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: actions ?? [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center( // Center giúp Container không bị kéo giãn theo chiều dọc của AppBar
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), // Nền xám nhạt giống hình
                borderRadius: BorderRadius.circular(20), // Bo góc tạo hình viên thuốc
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(LucideIcons.user, size: 16, color: AppColors.textDark),
                  SizedBox(width: 6),
                  Text(
                    'Guest',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}