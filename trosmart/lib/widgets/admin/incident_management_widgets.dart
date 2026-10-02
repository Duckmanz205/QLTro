import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_colors.dart';

// --- BẢNG THỐNG KÊ LƯỚI ---
class IncidentStatsGrid extends StatelessWidget {
  final int pendingCount;
  final int processingCount;
  final int completedCount;
  final int urgentCount;

  const IncidentStatsGrid({
    super.key,
    required this.pendingCount,
    required this.processingCount,
    required this.completedCount,
    required this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        IncidentStatCard(
          count: pendingCount.toString().padLeft(2, '0'),
          label: 'Chờ xử lý',
          icon: Icons.access_time_rounded,
          accentColor: AppColors.statusPending,
        ),
        IncidentStatCard(
          count: processingCount.toString().padLeft(2, '0'),
          label: 'Đang xử lý',
          icon: Icons.build_rounded,
          accentColor: AppColors.statusProcessing,
        ),
        IncidentStatCard(
          count: completedCount.toString().padLeft(2, '0'),
          label: 'Hoàn thành',
          icon: Icons.check_circle_outline_rounded,
          accentColor: AppColors.accentTeal,
        ),
        IncidentStatCard(
          count: urgentCount.toString().padLeft(2, '0'),
          label: 'Khẩn cấp',
          icon: Icons.warning_amber_rounded,
          accentColor: AppColors.statusUrgent,
        ),
      ],
    );
  }
}

class IncidentStatCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color accentColor;

  const IncidentStatCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.incidentBg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- TÌM KIẾM VÀ LỌC ---
class IncidentSearchAndFilter extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;

  const IncidentSearchAndFilter({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 32,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bộ lọc trạng thái sự cố',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilterOption(ctx, 'Tất cả', 'Tất cả sự cố', Icons.receipt_long_outlined),
                _buildFilterOption(ctx, 'Chờ xử lý', 'Chờ xử lý', Icons.access_time_rounded),
                _buildFilterOption(ctx, 'Đang xử lý', 'Đang xử lý', Icons.build_rounded),
                _buildFilterOption(ctx, 'Đã hoàn thành', 'Đã hoàn thành', Icons.check_circle_outline_rounded),
                _buildFilterOption(ctx, 'Từ chối', 'Từ chối', Icons.close),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context, 
    String filterValue, 
    String title, 
    IconData icon
  ) {
    final isSelected = selectedStatus == filterValue;
    return GestureDetector(
      onTap: () {
        onStatusChanged(filterValue);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6E589E).withOpacity(0.08) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6E589E) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? const Color(0xFF6E589E) : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF6E589E) : const Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF6E589E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: Colors.grey[400], size: 20),
              hintText: 'Tìm sự cố, phòng, khách...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showFilterBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedStatus != 'Tất cả' 
                        ? const Color(0xFF6E589E) 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedStatus != 'Tất cả' 
                          ? const Color(0xFF6E589E) 
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined, 
                            size: 14, 
                            color: selectedStatus != 'Tất cả' ? Colors.white : Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedStatus == 'Tất cả' ? 'Trạng thái' : selectedStatus,
                            style: GoogleFonts.inter(
                              fontSize: 12, 
                              color: selectedStatus != 'Tất cả' ? Colors.white : Colors.grey[700],
                              fontWeight: selectedStatus != 'Tất cả' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.keyboard_arrow_down, 
                        size: 16, 
                        color: selectedStatus != 'Tất cả' ? Colors.white : Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- THẺ SỰ CỐ CHI TIẾT ---
class IncidentCard extends StatelessWidget {
  final String code;
  final String title;
  final String status;
  final String type;
  final String room;
  final String requester;
  final String date;
  final int imagesCount;
  final bool isUrgent;
  final int? rating;
  final Color bgColor;

  const IncidentCard({
    super.key,
    required this.code,
    required this.title,
    required this.status,
    required this.type,
    required this.room,
    required this.requester,
    required this.date,
    required this.imagesCount,
    this.isUrgent = false,
    this.rating,
    required this.bgColor,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.onTap,
  });

  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    Text(code, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    IncidentBadge(
                      label: status,
                      textColor: _getStatusColor(status),
                      bgColor: _getStatusColor(status).withOpacity(0.2),
                    ),
                    if (isUrgent)
                      const IncidentBadge(
                        label: 'KHẨN CẤP',
                        textColor: AppColors.statusUrgent,
                        bgColor: AppColors.statusUrgent,
                        hasIcon: true,
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(type, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            IncidentInfoGrid(room: room, requester: requester, date: date, imagesCount: imagesCount, rating: rating),
            const SizedBox(height: 16),
            IncidentActionButtons(
              status: status,
              onAccept: onAccept,
              onReject: onReject,
              onComplete: onComplete,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'CHỜ XỬ LÝ') return AppColors.statusPending;
    if (status == 'ĐANG XỬ LÝ') return AppColors.statusProcessing;
    if (status == 'HOÀN THÀNH') return AppColors.accentTeal;
    return Colors.white;
  }
}

class IncidentBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  final bool hasIcon;

  const IncidentBadge({super.key, required this.label, required this.textColor, required this.bgColor, this.hasIcon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon) ...[
            const Icon(Icons.flash_on, color: AppColors.statusUrgent, size: 10),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}

class IncidentInfoGrid extends StatelessWidget {
  final String room;
  final String requester;
  final String date;
  final int imagesCount;
  final int? rating;

  const IncidentInfoGrid({super.key, required this.room, required this.requester, required this.date, required this.imagesCount, this.rating});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
      ),
      children: [
        IncidentInfoItem(icon: Icons.door_front_door_outlined, text: room),
        IncidentInfoItem(icon: Icons.person_outline, text: requester),
        IncidentInfoItem(icon: Icons.calendar_today_outlined, text: date),
        if (rating != null)
          Row(
            children: List.generate(5, (index) => Icon(
              Icons.star,
              size: 14,
              color: index < rating! ? const Color(0xFFFACC15) : Colors.white24,
            )),
          )
        else
          IncidentInfoItem(icon: Icons.image_outlined, text: '$imagesCount ảnh đính kèm'),
      ],
    );
  }
}

class IncidentInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const IncidentInfoItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class IncidentActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const IncidentActionButtons({
    super.key, 
    required this.status,
    this.onAccept,
    this.onReject,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'CHỜ XỬ LÝ') {
      return Row(
        children: [
          Expanded(
            child: IncidentButton(
              label: 'Tiếp nhận',
              icon: Icons.check,
              color: AppColors.adminDarkPurple,
              textColor: Colors.white,
              onTap: onAccept,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IncidentButton(
              label: 'Từ chối',
              icon: Icons.close,
              color: Colors.white.withOpacity(0.1),
              textColor: AppColors.statusUrgent,
              hasBorder: true,
              onTap: onReject,
            ),
          ),
        ],
      );
    }
    if (status == 'ĐANG XỬ LÝ') {
      return IncidentButton(
        label: 'Đánh dấu hoàn thành',
        icon: Icons.check_circle_outline,
        color: AppColors.adminDarkPurple,
        textColor: AppColors.accentTeal,
        isFullWidth: true,
        onTap: onComplete,
      );
    }
    return const SizedBox.shrink();
  }
}

class IncidentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool isFullWidth;
  final bool hasBorder;
  final VoidCallback? onTap;

  const IncidentButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.isFullWidth = false,
    this.hasBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder ? Border.all(color: Colors.white10) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    );
  }
}