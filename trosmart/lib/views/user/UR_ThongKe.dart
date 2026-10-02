import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../logic/admin/thong_ke_service.dart';
import '../../models/thong_ke_model.dart';
import '../../shared/app_colors.dart';

class HistoryStatsScreen extends StatefulWidget {
  const HistoryStatsScreen({super.key});

  @override
  State<HistoryStatsScreen> createState() => _HistoryStatsScreenState();
}

class _HistoryStatsScreenState extends State<HistoryStatsScreen> {
  final ThongKeService _thongKeService = ThongKeService();
  late Future<UserThongKeModel> _userStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  void _loadUserStats() {
    setState(() {
      _userStatsFuture = _thongKeService.getUserStats();
    });
  }

  String formatCurrency(double amount) {
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
          'Thống kê Chi tiêu & Điện nước',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.primaryPurple, size: 20),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body: FutureBuilder<UserThongKeModel>(
        future: _userStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
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
                      onPressed: _loadUserStats,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
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
            onRefresh: () async => _loadUserStats(),
            color: AppColors.primaryPurple,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thẻ thông tin phòng & tiền cọc
                  _buildRoomOverviewCard(data),
                  const SizedBox(height: 20),

                  // Thống kê tài chính tóm tắt
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: "TỔNG ĐÃ CHI",
                          value: formatCurrency(data.tongTienDaThanhToan),
                          dotColor: AppColors.accentTeal,
                          status: "Đã thanh toán",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          title: "KHOẢN CẦN TRẢ",
                          value: formatCurrency(data.tongTienChuaThanhToan),
                          dotColor: AppColors.statusOrange,
                          status: data.tongTienChuaThanhToan > 0 ? "Chưa thanh toán" : "Đã hoàn thành",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biểu đồ Chi tiêu 6 tháng gần nhất
                  _buildSpendingChartCard(data.lichSuChiTieu),
                  const SizedBox(height: 24),

                  // Biểu đồ Điện & Nước tiêu thụ
                  _buildUtilityUsageChartCard(data.lichSuTieuThu),
                  const SizedBox(height: 24),

                  // Thẻ mẹo tiết kiệm
                  _buildSavingTipCard(data),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomOverviewCard(UserThongKeModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D5FC0), Color(0xFF7E49A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D5FC0).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
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
                children: [
                  Text(
                    'Phòng của tôi',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.tenPhongHienTai != 'Chưa thuê' ? 'Phòng ${data.tenPhongHienTai}' : 'Chưa thuê phòng',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(LucideIcons.home, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRoomInfoSubItem('Cơ sở', data.tenCoSoHienTai),
              _buildRoomInfoSubItem('Tiền cọc hợp đồng', formatCurrency(data.tienCocHienTai)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfoSubItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color dotColor,
    required String status,
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
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSpendingChartCard(List<ChiTieuThangModel> lichSuCt) {
    if (lichSuCt.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('Chưa có lịch sử chi tiêu'),
      );
    }

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
            'Xu hướng Chi tiêu 6 tháng',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1A1D1F)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (val == idx.toDouble() && idx >= 0 && idx < lichSuCt.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              lichSuCt[idx].kyThanhToan,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 9, fontWeight: FontWeight.bold),
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
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: lichSuCt.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.tongTien)).toList(),
                    isCurved: true,
                    color: AppColors.primaryPurple,
                    barWidth: 3.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4, color: Colors.white, strokeWidth: 2.5, strokeColor: AppColors.primaryPurple,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryPurple.withOpacity(0.15), AppColors.primaryPurple.withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildUtilityUsageChartCard(List<TieuThuDienNuocModel> lichSuTt) {
    if (lichSuTt.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('Chưa có chỉ số điện nước'),
      );
    }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lượng tiêu thụ Điện & Nước',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1A1D1F)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLegendItem('Điện (kWh)', AppColors.statusOrange),
                  const SizedBox(width: 16),
                  _buildLegendItem('Nước (m³)', AppColors.accentTeal),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (val == idx.toDouble() && idx >= 0 && idx < lichSuTt.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              lichSuTt[idx].kyThanhToan,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 9, fontWeight: FontWeight.bold),
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
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Đường Điện
                  LineChartBarData(
                    spots: lichSuTt.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.soDienTieuThu.toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.statusOrange,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5, color: Colors.white, strokeWidth: 2, strokeColor: AppColors.statusOrange,
                      ),
                    ),
                  ),
                  // Đường Nước
                  LineChartBarData(
                    spots: lichSuTt.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.soNuocTieuThu.toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.accentTeal,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5, color: Colors.white, strokeWidth: 2, strokeColor: AppColors.accentTeal,
                      ),
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

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildSavingTipCard(UserThongKeModel data) {
    const Color greenSuccess = Color(0xFF48BB78);
    // Tính toán tiết kiệm giả lập
    int dienTietKiem = 15;
    if (data.lichSuTieuThu.length >= 2) {
      final last = data.lichSuTieuThu.last.soDienTieuThu;
      final prev = data.lichSuTieuThu[data.lichSuTieuThu.length - 2].soDienTieuThu;
      dienTietKiem = prev - last;
    }

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
        children: [
          Row(
            children: [
              const Icon(LucideIcons.lightbulb, color: AppColors.statusOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                "Góc Tiết Kiệm & Tiêu dùng",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greenSuccess.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: greenSuccess.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.trendingDown, color: greenSuccess, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dienTietKiem > 0 ? "Tiết kiệm năng lượng" : "Mẹo dùng thiết bị",
                        style: const TextStyle(color: greenSuccess, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dienTietKiem > 0
                            ? "Tháng này bạn đã dùng giảm được $dienTietKiem kWh điện so với tháng trước. Hãy tiếp tục duy trì bật điều hòa ở nhiệt độ 26°C và tắt hết các ổ cắm điện khi rời khỏi phòng nhé!"
                            : "Để tối ưu tiền điện tháng tới, hãy ưu tiên dùng quạt thay vì điều hòa vào ban đêm, rút sạc laptop và sạc điện thoại ra khỏi ổ cắm khi đã đầy 100%.",
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}