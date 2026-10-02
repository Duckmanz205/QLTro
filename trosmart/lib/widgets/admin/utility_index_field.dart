import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';

class UtilityIndexField extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;

  const UtilityIndexField({
    super.key,
    required this.label,
    required this.value,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isEditable ? const Color(0xFF0F1620) : const Color(0x7F0F1620),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEditable ? AppColors.accentTeal.withOpacity(0.3) : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                color: isEditable ? Colors.white : const Color(0x7FA0AEC0),
                fontSize: 14,
                fontWeight: isEditable ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}