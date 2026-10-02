import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/app_colors.dart'; // Đảm bảo import đúng file chứa AppColors[cite: 1]

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color dotColor;
  final String status;
  final Color? valueColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.dotColor,
    required this.status,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.primaryPurple)), // Màu tím chính[cite: 1]
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textLight)),
            ],
          )
        ],
      ),
    );
  }
}

class ExpenditureChartBox extends StatelessWidget {
  const ExpenditureChartBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Chi phí Điện & Nước", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Đơn vị: 1000 VNĐ", style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
              Row(
                children: [
                  _chartLegend(AppColors.statusOrange, "Điện"), // Màu cam điện[cite: 1]
                  const SizedBox(width: 12),
                  _chartLegend(AppColors.accentTeal, "Nước"), // Màu xanh nước[cite: 1]
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 200),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const style = TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold);
                        switch (val.toInt()) {
                          case 0: return const Text('T9', style: style);
                          case 1: return const Text('T10', style: style);
                          case 2: return const Text('T11', style: style);
                          case 3: return const Text('T12', style: style);
                          case 4: return const Text('T1', style: style);
                          case 5: return const Text('T2', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineBarData(AppColors.statusOrange, [320, 450, 420, 580, 520, 480]), // Màu cam[cite: 1]
                  _lineBarData(AppColors.accentTeal, [150, 180, 160, 210, 190, 180]), // Màu xanh teal[cite: 1]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight)),
      ],
    );
  }

  LineChartBarData _lineBarData(Color color, List<double> data) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: color,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withValues(alpha:0.2), color.withValues(alpha:0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class SavingTipCard extends StatelessWidget {
  const SavingTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color greenSuccess = Color(0xFF48BB78); // Giữ màu xanh lá cho mẹo tiết kiệm
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(LucideIcons.lightbulb, color: AppColors.statusOrange, size: 18), // Màu cam status[cite: 1]
              SizedBox(width: 8),
              Text("Mẹo tiết kiệm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greenSuccess.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: greenSuccess.withValues(alpha:0.1)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.trendingDown, color: greenSuccess, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tiền điện giảm 7%", style: TextStyle(color: greenSuccess, fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text(
                        "So với tháng trước, bạn đã tiết kiệm được khoảng 120.000đ tiền điện. Hãy tiếp tục duy trì thói quen tắt thiết bị khi không sử dụng!",
                        style: TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.5),
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

class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const TransactionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: iconColor.withValues(alpha:0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ],
              )
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}

class RecentActivityHeader extends StatelessWidget {
  const RecentActivityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("GẦN ĐÂY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1.2)),
          Text("Xem tất cả", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentTeal)), // Màu teal[cite: 1]
        ],
      ),
    );
  }
}