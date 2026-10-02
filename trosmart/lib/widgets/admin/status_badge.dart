import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Status badge chip (e.g. "Đang xử lý", "Hoàn thành", "Chờ xử lý").
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.icon,
  });

  /// Factory for "Đang xử lý" (processing) status.
  factory StatusBadge.processing({String label = 'Đang xử lý'}) {
    return StatusBadge(
      label: label,
      color: AppTheme.statusBlue,
      backgroundColor: AppTheme.statusBlueBg,
      borderColor: AppTheme.statusBlueBorder,
      icon: Icons.autorenew_rounded,
    );
  }

  /// Factory for "Hoàn thành" (completed) status.
  factory StatusBadge.completed({String label = 'Hoàn thành'}) {
    return StatusBadge(
      label: label,
      color: AppTheme.statusTeal,
      backgroundColor: AppTheme.statusTealBg,
      borderColor: AppTheme.statusTealBorder,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Factory for "Chờ xử lý" (pending) status.
  factory StatusBadge.pending({String label = 'Chờ xử lý'}) {
    return StatusBadge(
      label: label,
      color: AppTheme.statusOrange,
      backgroundColor: AppTheme.statusOrangeBg,
      borderColor: AppTheme.statusOrange.withValues(alpha: 0.30),
      icon: Icons.schedule_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: borderColor ?? color.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTheme.captionBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
