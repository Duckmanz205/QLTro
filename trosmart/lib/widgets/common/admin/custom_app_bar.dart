import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:trosmart/shared/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(LucideIcons.menu, color: AppColors.textDark),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentTeal, // Đã đồng bộ màu
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.home, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            'TroSmart',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.accentTeal, // Đã đồng bộ màu
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)), 
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 3, backgroundColor: AppColors.accentTeal),
              const SizedBox(width: 6),
              Text(
                'Chủ trọ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentTeal, // Đã đồng bộ màu
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}