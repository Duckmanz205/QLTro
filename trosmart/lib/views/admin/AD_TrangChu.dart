import 'package:flutter/material.dart';
import '../../logic/admin/thong_ke_service.dart';
import '../../models/thong_ke_model.dart';
import 'package:intl/intl.dart';
import '../../models/admin/admin_pages.dart';
import '../../models/thong_bao.dart';
import '../../services/thong_bao_service.dart';

class AdminHomeScreen extends StatefulWidget {
  final Function(String)? onNavigate;
  const AdminHomeScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ThongKeService _thongKeService = ThongKeService();
  late Future<AdminThongKeModel> _statsFuture;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _thongKeService.getAdminStats(year: _selectedYear);
    });
  }

  String formatRevenue(double amount) {
    if (amount >= 1000000) {
      return (amount / 1000000).toStringAsFixed(1);
    }
    return NumberFormat('#,###').format(amount);
  }

  String formatRevenueUnit(double amount) {
    if (amount >= 1000000) {
      return "tr";
    }
    return "đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadStats();
        },
        color: const Color(0xFF6A3092),
        child: FutureBuilder<AdminThongKeModel>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6A3092),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi tải dữ liệu thống kê:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadStats,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A3092),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final stats = snapshot.data!;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 24),
                  _buildRevenueChart(stats),
                  const SizedBox(height: 24),
                  _buildAlertsSection(stats),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    final currentMonthYear = DateFormat('MM/yyyy').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Tổng quan hoạt động nhà trọ",
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Tháng",
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 2),
                Text(
                  currentMonthYear,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A3092),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AdminThongKeModel stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard(
            title: "Doanh thu đã thu",
            value: formatRevenue(stats.tongDoanhThuDaThu),
            unit: formatRevenueUnit(stats.tongDoanhThuDaThu),
            icon: Icons.monetization_on,
            iconColor: const Color(0xFF2DDCB1),
            badge: stats.tongDoanhThuChuaThu > 0
                ? "Còn: ${formatRevenue(stats.tongDoanhThuChuaThu)}${formatRevenueUnit(stats.tongDoanhThuChuaThu)}"
                : "Hoàn tất",
          ),
          _buildStatCard(
            title: "Tổng phòng",
            value: "${stats.tongSoPhong}",
            unit: "${stats.tongSoCoSo} cơ sở",
            icon: Icons.meeting_room,
            iconColor: const Color(0xFF2DDCB1),
            isSecondaryUnit: true,
          ),
          _buildStatCard(
            title: "Tỷ lệ lấp đầy",
            value: stats.tiLeLapDay.toStringAsFixed(0),
            unit: "%",
            icon: Icons.pie_chart,
            iconColor: const Color(0xFF2DDCB1),
            badge: "Trống: ${stats.phongTrong}",
            hasProgress: true,
            progressValue: stats.tiLeLapDay / 100,
          ),
          _buildStatCard(
            title: "Sự cố chưa xử lý",
            value: "${stats.suCoChuaXuLy}",
            unit: "Tổng: ${stats.tongSuCo}",
            icon: Icons.build,
            iconColor: stats.suCoChuaXuLy > 0 ? const Color(0xFFFF5757) : const Color(0xFF2DDCB1),
            isSecondaryUnit: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    String? badge,
    bool isSecondaryUnit = false,
    bool hasProgress = false,
    double progressValue = 0.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.bottomLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (!isSecondaryUnit)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      unit,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            if (isSecondaryUnit) ...[
                              const SizedBox(height: 4),
                              Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
                                ),
                              ),
                            ],
                            if (hasProgress) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progressValue.clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFFF3F4F6),
                                color: iconColor,
                                minHeight: 3,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(AdminThongKeModel stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Doanh thu theo tháng",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    "triệu VNĐ",
                    style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildYearFilter("2026", isActive: _selectedYear == 2026),
                  const SizedBox(width: 8),
                  _buildYearFilter("2025", isActive: _selectedYear == 2025),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats.doanhThuTheoThang.isEmpty)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Chưa có dữ liệu doanh thu",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            Container(
              height: 160,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: stats.doanhThuTheoThang.map((dt) {
                  final totalRevenue = dt.daThanhToan + dt.chuaThanhToan;
                  // Tính chiều cao tương đối (tối đa 120px)
                  double maxInList = stats.doanhThuTheoThang
                      .map((e) => e.daThanhToan + e.chuaThanhToan)
                      .reduce((a, b) => a > b ? a : b);
                  if (maxInList == 0) maxInList = 1;
                  final heightRatio = (totalRevenue / maxInList).clamp(0.05, 1.0);
                  final barHeight = 120.0 * heightRatio;

                  return Expanded(
                    child: Tooltip(
                      message: "Tháng ${dt.thang}: ${formatRevenue(dt.daThanhToan)}tr / ${formatRevenue(totalRevenue)}tr",
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 14,
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E35B6), Color(0xFF6A3092)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "T${dt.thang}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildYearFilter(String year, {required bool isActive}) {
    return GestureDetector(
      onTap: () {
        final yr = int.tryParse(year);
        if (yr != null && yr != _selectedYear) {
          setState(() {
            _selectedYear = yr;
            _loadStats();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6A3092).withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? const Color(0xFF6A3092).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          year,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6A3092) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(AdminThongKeModel stats) {
    final bool hasSuCo = stats.suCoChuaXuLy > 0;
    final bool hasHoaDon = stats.tongDoanhThuChuaThu > 0;
    final int alertCount = (hasSuCo ? 1 : 0) + (hasHoaDon ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF5A623),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Cảnh báo hệ thống",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$alertCount mục",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (alertCount == 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Không có cảnh báo nào từ hệ thống",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            if (hasSuCo) ...[
              _buildAlertCard(
                "Sự cố chưa xử lý",
                "Có ${stats.suCoChuaXuLy} sự cố phòng trọ đang chờ giải quyết",
                "Mới nhận",
                Icons.flash_on,
                const Color(0xFFDC2626),
                onTap: () => widget.onNavigate?.call(AdminPages.suCo),
              ),
              const SizedBox(height: 12),
            ],
            if (hasHoaDon) ...[
              _buildAlertCard(
                "Hóa đơn chưa thu tiền",
                "Còn ${formatRevenue(stats.tongDoanhThuChuaThu)}tr chưa thanh toán",
                "Trong tháng",
                Icons.payment,
                const Color(0xFFEA580C),
                onTap: () => widget.onNavigate?.call(AdminPages.thuThue),
              ),
              const SizedBox(height: 12),
            ],
          ],
          _buildAlertCard(
            "Trạng thái vận hành",
            "Đang thuê ${stats.phongDangThue}/${stats.tongSoPhong} phòng (${stats.tiLeLapDay.toStringAsFixed(0)}%)",
            "Cập nhật",
            Icons.check_circle_outline,
            const Color(0xFF10B981),
            onTap: () => widget.onNavigate?.call(AdminPages.phong),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hoạt động gần đây",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onNavigate?.call(AdminPages.thongBao);
                },
                child: const Text(
                  "Xem tất cả →",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A3092),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ThongBao>>(
            future: ThongBaoService().getAllThongBao(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Color(0xFF6A3092)),
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: const Center(
                    child: Text(
                      "Chưa có hoạt động nào gần đây",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                );
              }

              // Lấy tối đa 4 thông báo mới nhất
              final list = snapshot.data!.take(4).toList();

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(list.length, (index) {
                    final item = list[index];
                    final date = item.ngayGui;
                    String timeStr = "Vừa xong";
                    if (date != null) {
                      final diff = DateTime.now().difference(date);
                      if (diff.inMinutes < 60) {
                        timeStr = "${diff.inMinutes} phút trước";
                      } else if (diff.inHours < 24) {
                        timeStr = "${diff.inHours} giờ trước";
                      } else {
                        timeStr = "${diff.inDays} ngày trước";
                      }
                    }
                    
                    // Xác định icon và màu sắc dựa trên nội dung/tiêu đề thông báo
                    IconData icon = Icons.notifications;
                    Color color = const Color(0xFF3B82F6);
                    if (item.tieuDe.toLowerCase().contains("thanh toán") || item.tieuDe.toLowerCase().contains("hóa đơn")) {
                      icon = Icons.attach_money;
                      color = const Color(0xFF10B981);
                    } else if (item.tieuDe.toLowerCase().contains("sự cố") || item.tieuDe.toLowerCase().contains("báo cáo")) {
                      icon = Icons.warning;
                      color = const Color(0xFFEF4444);
                    } else if (item.tieuDe.toLowerCase().contains("hợp đồng")) {
                      icon = Icons.history_edu;
                      color = const Color(0xFF3B82F6);
                    }

                    return _buildTimelineItem(
                      item.tieuDe,
                      item.noiDung ?? '',
                      timeStr,
                      icon,
                      color,
                      isFirst: index == 0,
                      isLast: index == list.length - 1,
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 1,
                height: isFirst ? 0 : 10,
                color: const Color(0xFFE5E7EB),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  border: Border.all(color: color.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              Expanded(
                child: Container(
                  width: 1,
                  color: isLast ? Colors.transparent : const Color(0xFFE5E7EB),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
