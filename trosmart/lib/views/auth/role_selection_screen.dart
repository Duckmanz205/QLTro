import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';
import '../admin/admin_navigation_screen.dart';
import '../user/navigation_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.deepPurple,
              AppTheme.deepPurple.withValues(alpha: 0.8),
              AppTheme.bgSlate,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'TroSmart',
                  style: AppTheme.headingXl.copyWith(color: Colors.white, fontSize: 42),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hệ thống quản lý trọ thông minh',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 64),
                const Text(
                  'BẠN LÀ AI?',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Admin Card
                _RoleCard(
                  title: 'Chủ trọ / Quản lý',
                  subtitle: 'Quản lý cơ sở, hóa đơn & sự cố',
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  textColor: AppTheme.deepPurple,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminNavigationScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Tenant Card
                _RoleCard(
                  title: 'Khách thuê',
                  subtitle: 'Xem hóa đơn, báo sự cố & chat AI',
                  icon: Icons.person_rounded,
                  color: Colors.white.withValues(alpha: 0.15),
                  textColor: Colors.white,
                  isOutlined: true,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool isOutlined;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.textColor,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: isOutlined ? Border.all(color: Colors.white24) : null,
          boxShadow: !isOutlined ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOutlined ? Colors.white10 : textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: textColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMd.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
