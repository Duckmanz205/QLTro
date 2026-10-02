import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/admin/thong_ke_service.dart';
import '../../models/thong_ke_model.dart';
import '../../shared/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
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

  String formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Thống kê & Báo cáo',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF9D5FC0), size: 20),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: FutureBuilder<AdminThongKeModel>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF9D5FC0)));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Colors.amber, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải thống kê',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception:', ''),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadStats,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D5FC0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadStats(),
            color: const Color(0xFF9D5FC0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn năm thống kê
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TỔNG QUAN VẬN HÀNH',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: const Color(0xFF6F767E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            items: [DateTime.now().year - 1, DateTime.now().year, DateTime.now().year + 1]
                                .map((y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedYear = val;
                                  _loadStats();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grid các thẻ tóm tắt
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                      _buildSummaryCard(
                        icon: LucideIcons.checkCircle,
                        iconColor: const Color(0xFF2DDCB1),
                        bgColor: const Color(0xFFE9FAF6),
                        value: formatCurrency(data.tongDoanhThuDaThu),
                        label: 'Doanh thu đã thu',
                      ),
                      _buildSummaryCard(
                        icon: LucideIcons.clock,
                        iconColor: const Color(0xFFF43F5E),
                        bgColor: const Color(0xFFFFECEF),
                        value: formatCurrency(data.tongDoanhThuChuaThu),
                        label: 'Chưa thanh toán',
                      ),
                      _buildSummaryCard(
                        icon: LucideIcons.percent,
                        iconColor: const Color(0xFF6366F1),
                        bgColor: const Color(0xFFEEEDFD),
                        value: '${data.tiLeLapDay}%',
                        label: 'Tỷ lệ lấp đầy',
                      ),
                      _buildSummaryCard(
                        icon: LucideIcons.alertCircle,
                        iconColor: const Color(0xFFFF9F1C),
                        bgColor: const Color(0xFFFFF6EB),
                        value: '${data.suCoChuaXuLy}/${data.tongSuCo}',
                        label: 'Sự cố tồn đọng',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biểu đồ Doanh thu (Đã thu vs Chưa thu)
                  _buildRevenueBarChartCard(data.doanhThuTheoThang),
                  const SizedBox(height: 24),

                  // Thống kê trạng thái phòng
                  _buildRoomStatusCard(data),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1D1F)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6F767E), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBarChartCard(List<DoanhThuThangModel> listDt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích Doanh thu',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1D1F)),
          ),
          Text(
            'Biểu đồ so sánh khoản đã thu và khoản nợ theo tháng trong năm $_selectedYear',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6F767E)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem('Đã thu', const Color(0xFF2DDCB1)),
              const SizedBox(width: 16),
              _buildLegendItem('Chưa thanh toán', const Color(0xFFF43F5E)),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxRevenue(listDt),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800]!,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rodIndex == 0 ? "Đã thu" : "Chưa thu"}: ${formatCurrency(rod.toY)}',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final mIndex = value.toInt();
                        if (mIndex >= 1 && mIndex <= 12) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'T$mIndex',
                              style: const TextStyle(color: Color(0xFF6F767E), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: listDt.map((m) {
                  return BarChartGroupData(
                    x: m.thang,
                    barRods: [
                      BarChartRodData(
                        toY: m.daThanhToan,
                        color: const Color(0xFF2DDCB1),
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: m.chuaThanhToan,
                        color: const Color(0xFFF43F5E),
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxRevenue(List<DoanhThuThangModel> listDt) {
    double max = 0;
    for (var m in listDt) {
      if (m.daThanhToan > max) max = m.daThanhToan;
      if (m.chuaThanhToan > max) max = m.chuaThanhToan;
    }
    return max == 0 ? 1000000 : max * 1.15;
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6F767E), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRoomStatusCard(AdminThongKeModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tình trạng Phòng trọ',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1D1F)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      sections: [
                        PieChartSectionData(
                          value: data.phongDangThue.toDouble(),
                          color: const Color(0xFF6366F1),
                          title: data.phongDangThue > 0 ? '${data.phongDangThue}' : '',
                          radius: 20,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: data.phongTrong.toDouble(),
                          color: const Color(0xFFE2E8F0),
                          title: data.phongTrong > 0 ? '${data.phongTrong}' : '',
                          radius: 18,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6F767E)),
                        ),
                        PieChartSectionData(
                          value: data.phongBaoTri.toDouble(),
                          color: const Color(0xFFFF9F1C),
                          title: data.phongBaoTri > 0 ? '${data.phongBaoTri}' : '',
                          radius: 18,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusIndicator('Đang thuê (${data.phongDangThue} phòng)', const Color(0xFF6366F1)),
                    const SizedBox(height: 10),
                    _buildStatusIndicator('Phòng trống (${data.phongTrong} phòng)', const Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),
                    _buildStatusIndicator('Bảo trì (${data.phongBaoTri} phòng)', const Color(0xFFFF9F1C)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1A1D1F), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
