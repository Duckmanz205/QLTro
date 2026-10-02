import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

// --- COMPONENT: Page Header (Title + Utility Icon) ---
class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Thống kê & Báo cáo',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1D1F),
          ),
        ),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE9FAF6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD0F4EC)),
          ),
          child: const Icon(LucideIcons.trendingUp, color: Color(0xFF2DDCB1), size: 20),
        )
      ],
    );
  }
}

// --- COMPONENT: Action Buttons (Year + Download) ---
class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.calendar, color: Color(0xFF2DDCB1), size: 18),
              SizedBox(width: 8),
              Text('2024', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9D5FC0), Color(0xFF7E49A3)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9D5FC0).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.download, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Download PDF',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- COMPONENT: Section Label ---
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: const Color(0xFF6F767E),
      ),
    );
  }
}

// --- COMPONENT: Metrics Grid ---
class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: const [
        SummaryCard(icon: LucideIcons.dollarSign, value: '13.5B', label: 'Tổng doanh thu', growth: '+18%'),
        SummaryCard(icon: LucideIcons.trendingUp, value: '8.7B', label: 'Lợi Nhuận', growth: '+24%'),
        SummaryCard(icon: LucideIcons.home, value: '85%', label: 'Tỷ lệ trung bình', growth: '+12%'),
        SummaryCard(icon: LucideIcons.users, value: '156', label: 'Khách hàng mới', growth: '+31%'),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String growth;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: const Color(0xFFE9FAF6), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF2DDCB1), size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6F767E))),
                ],
              )
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFE9FAF6), borderRadius: BorderRadius.circular(6)),
              child: Text(growth, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2DDCB1))),
            ),
          )
        ],
      ),
    );
  }
}

// --- COMPONENT: Chart 1 (Revenue & Profit) ---
class RevenueProfitChartCard extends StatelessWidget {
  const RevenueProfitChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doanh thu và lợi nhuận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Phân tích hiệu suất hàng tháng', style: TextStyle(fontSize: 12, color: Color(0xFF6F767E))),
                ],
              ),
              Text('2024', style: TextStyle(fontSize: 12, color: Color(0xFF6F767E))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              legendItem('Doanh thu', const Color(0xFF2DDCB1)),
              const SizedBox(width: 12),
              legendItem('Tỷ giá', const Color(0xFFF43F5E)),
              const SizedBox(width: 12),
              legendItem('Lợi nhuận', const Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  lineData(const Color(0xFF2DDCB1), [const FlSpot(0, 3), const FlSpot(2, 4), const FlSpot(4, 3.5), const FlSpot(6, 5)]),
                  lineData(const Color(0xFFF43F5E).withOpacity(0.6), [const FlSpot(0, 1), const FlSpot(2, 1.5), const FlSpot(4, 1.2), const FlSpot(6, 1.8)]),
                  lineData(const Color(0xFF6366F1), [const FlSpot(0, 0.5), const FlSpot(2, 1), const FlSpot(4, 0.8), const FlSpot(6, 1.2)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget legendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF6F767E))),
      ],
    );
  }

  LineChartBarData lineData(Color color, List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }
}

// --- COMPONENT: Chart 2 (Rental Trend) ---
class RentalTrendChartCard extends StatelessWidget {
  const RentalTrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Xu hướng thuê nhà', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Tỷ lệ thuê hàng tháng (%)', style: TextStyle(fontSize: 12, color: Color(0xFF6F767E))),
                ],
              ),
              Text('2024', style: TextStyle(fontSize: 12, color: Color(0xFF6F767E))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF2DDCB1), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Tỷ lệ thuê', style: TextStyle(fontSize: 10, color: Color(0xFF6F767E))),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: const [
                  SizedBox(width: 12, child: Divider(color: Colors.grey, thickness: 1.5)),
                  SizedBox(width: 4),
                  Text('Mục tiêu (90%)', style: TextStyle(fontSize: 10, color: Color(0xFF6F767E))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 60), FlSpot(2, 70), FlSpot(4, 85), FlSpot(6, 92), FlSpot(8, 90), FlSpot(10, 80)],
                    isCurved: true,
                    color: const Color(0xFF2DDCB1),
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF2DDCB1).withOpacity(0.1)),
                    dotData: const FlDotData(show: true),
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