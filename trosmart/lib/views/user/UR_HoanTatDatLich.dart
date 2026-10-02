import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';
import '../../views/user/UR_LichSuXemPhong.dart';

class UrHoanTatDatLich extends StatelessWidget {
  // KHAI BÁO BIẾN ĐỘNG ĐỂ HỨNG DỮ LIỆU TỪ TRANG ĐẶT LỊCH NÉM SANG
  final int maKhach;
  final String soPhong;
  final String tenCoSo;
  final String thoiGianHenFormatted;

  const UrHoanTatDatLich({
    super.key,
    required this.maKhach,
    required this.soPhong,
    required this.tenCoSo,
    required this.thoiGianHenFormatted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // --- Icon Thành công ---
                      Center(
                        child: Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(color: Color(0xFFE8FAF6), shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentTeal, size: 60),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- Tiêu đề ---
                      const Text('Đặt lịch thành công!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text('Yêu cầu xem phòng của bạn đã được gửi đến chủ trọ. Vui lòng đợi xác nhận nhé!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
                      ),
                      const SizedBox(height: 32),

                      // --- Card tóm tắt thông tin ĐỘNG ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: AppTheme.bgSlate, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.bgGray200)),
                          child: Column(
                            children: [
                              _buildSummaryRow(Icons.business_rounded, 'Cơ sở:', tenCoSo),
                              const Divider(height: 30),
                              _buildSummaryRow(Icons.meeting_room_rounded, 'Phòng:', soPhong),
                              const Divider(height: 30),
                              _buildSummaryRow(Icons.event_available_rounded, 'Thời gian:', thoiGianHenFormatted),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // --- Nút bấm điều hướng luồng ---
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.deepPurple, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                              child: const Text('Về trang chủ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UrLichSuXemPhong(maKhach: maKhach)),
                                );
                              },
                              child: const Text('Xem lịch sử đặt lịch', style: TextStyle(color: AppTheme.deepPurple, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, color: AppTheme.deepPurple, size: 20), const SizedBox(width: 12), Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)), const Spacer(), Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis))]);
  }
}