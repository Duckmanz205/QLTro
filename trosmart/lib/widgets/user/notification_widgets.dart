import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Notification card used in UR_ThongBao screen.
class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeAgo;
  final Color themeColor;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool isUrgent;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.themeColor,
    this.icon = Icons.notifications_outlined,
    this.actionLabel,
    this.onActionTap,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: AppTheme.bgWhite,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: isUrgent
                ? themeColor.withValues(alpha: 0.30)
                : Colors.black.withValues(alpha: 0.10),
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        shadows: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: themeColor.withValues(alpha: 0.10),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: themeColor.withValues(alpha: 0.30),
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Icon(icon, color: themeColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.headingMd.copyWith(color: themeColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: AppTheme.caption.copyWith(
                        letterSpacing: -0.60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  description,
                  style: AppTheme.bodyMd,
                ),
                // Action button (optional)
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onActionTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        shadows: AppTheme.cardShadow,
                      ),
                      child: Text(
                        actionLabel!,
                        textAlign: TextAlign.center,
                        style: AppTheme.captionBold.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.20,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
