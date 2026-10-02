import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../shared/api_constants.dart';
import '../../shared/app_theme.dart';
import '../../logic/user/user_contract_controller.dart';
import '../../logic/user/user_payment_controller.dart';
import '../../logic/auth/auth_service.dart';
import 'UR_KyHopDongOnline.dart';

class UrHopDong extends StatelessWidget {
  const UrHopDong({super.key});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime parsed = DateTime.parse(dateStr);
      if (parsed.year == 1) return "Chưa xác định";
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  String _getDayOfWeekTag(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime parsed = DateTime.parse(dateStr);
      if (parsed.year == 1) return "N/A";
      switch (parsed.weekday) {
        case 1:
          return "Thứ Hai";
        case 2:
          return "Thứ Ba";
        case 3:
          return "Thứ Tư";
        case 4:
          return "Thứ Năm";
        case 5:
          return "Thứ Sáu";
        case 6:
          return "Thứ Bảy";
        default:
          return "Chủ Nhật";
      }
    } catch (_) {
      return "N/A";
    }
  }

  double _calculateProgress(String? startStr, String? endStr) {
    if (startStr == null || endStr == null) return 0.0;
    try {
      DateTime start = DateTime.parse(startStr);
      DateTime end = DateTime.parse(endStr);
      if (end.year == 1) return 0.0; // avoid invalid date calculation
      DateTime now = DateTime.now();

      if (now.isBefore(start)) return 0.0;
      if (now.isAfter(end)) return 1.0;

      int totalDays = end.difference(start).inDays;
      int passedDays = now.difference(start).inDays;

      if (totalDays <= 0) return 0.0;
      return (passedDays / totalDays).clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  int _getPassedMonths(String? startStr) {
    if (startStr == null) return 0;
    try {
      DateTime start = DateTime.parse(startStr);
      if (start.year == 1) return 0;
      DateTime now = DateTime.now();
      if (now.isBefore(start)) return 0;

      int months = (now.year - start.year) * 12 + now.month - start.month;
      return months < 0 ? 0 : months;
    } catch (_) {
      return 0;
    }
  }

  int _getTotalMonths(String? startStr, String? endStr) {
    if (startStr == null || endStr == null) return 12;
    try {
      DateTime start = DateTime.parse(startStr);
      DateTime end = DateTime.parse(endStr);
      if (end.year == 1) return 12; // fallback for uninitialized dates
      int months = (end.year - start.year) * 12 + end.month - start.month;
      return months <= 0 ? 12 : months;
    } catch (_) {
      return 12;
    }
  }

  String _formatAmountToM(dynamic amount) {
    if (amount == null) return "0";
    try {
      double val = double.parse(amount.toString());
      double m = val / 1000000;
      return m % 1 == 0 ? m.toInt().toString() : m.toStringAsFixed(1);
    } catch (_) {
      return amount.toString();
    }
  }

  Future<void> _downloadAndOpenUserPdf(
    BuildContext context,
    UserContractController controller,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang khởi tạo tiến trình tải file PDF...'),
        backgroundColor: AppTheme.deepPurple,
      ),
    );

    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/HopDong/${controller.maHopDong}/export-pdf',
        ),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();

        String phongStr =
            (controller.contract!['soPhong'] ??
                    controller.contract!['SoPhong'] ??
                    'Trong')
                .toString();
        final filePath = '${directory.path}/HopDong_Phong_$phongStr.pdf';

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải tệp hợp đồng PDF thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          await OpenFilex.open(filePath);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể xuất tệp PDF. Mã phản hồi: ${response.statusCode}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải file hợp đồng PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thiết bị chưa cài ứng dụng đọc PDF hoặc lỗi đường truyền!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<UserContractController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.deepPurple),
            );
          }

          final contract = controller.contract;
          if (contract == null || controller.maHopDong == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Tài khoản của bạn hiện chưa có hợp đồng thuê phòng nào được tạo nháp!",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          String trangThai =
              contract['trangThai']?.toString().trim() ?? "Chờ khách ký";
          bool daKy = trangThai == "Đang hiệu lực";
          bool choKetThucSom = trangThai == "Chờ kết thúc sớm";
          bool isExpired = false;
          if (contract['ngayKetThuc'] != null) {
            try {
              DateTime end = DateTime.parse(contract['ngayKetThuc']);
              if (end.year > 1 && end.isBefore(DateTime.now())) {
                isExpired = true;
              }
            } catch (_) {}
          }
          if (trangThai == "Hết hạn" || trangThai == "Quá hạn") {
            isExpired = true;
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContractSelector(context, controller),
                        _buildDraftWarningBanner(controller),
                        _buildMainTitle(contract, trangThai),
                        const SizedBox(height: 24),
                        _buildContractProgressCard(
                          contract,
                          contract['ngayBatDau'],
                          contract['ngayKetThuc'],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.calendar_today_outlined,
                          iconBg: const Color(0xFFEEF2FF),
                          iconTint: const Color(0xFF4F46E5),
                          label: 'NGÀY BẮT ĐẦU',
                          value: _formatDate(contract['ngayBatDau']),
                          tag: _getDayOfWeekTag(contract['ngayBatDau']),
                          tagBg: const Color(0xFFE0E7FF),
                          tagTint: const Color(0xFF4F46E5),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.verified_outlined,
                          iconBg: const Color(0xFFFFF1F2),
                          iconTint: const Color(0xFFE11D48),
                          label: 'NGÀY KẾT THÚC',
                          value: _formatDate(contract['ngayKetThuc']),
                          tag: _getDayOfWeekTag(contract['ngayKetThuc']),
                          tagBg: const Color(0xFFFFE4E6),
                          tagTint: const Color(0xFFE11D48),
                        ),
                        const SizedBox(height: 12),
                        _buildPriceCard(
                          icon: Icons.bolt,
                          iconBg: const Color(0xFFFFFBEB),
                          label:
                              'TIỀN THUÊ / THÁNG (PHÒNG ${contract['soPhong']})',
                          amount: _formatAmountToM(contract['giaThue']),
                          currency: 'M',
                          currencyColor: const Color(0xFFD97706),
                          extraLabel: 'HẠN THANH TOÁN',
                          extraValue: 'Ngày 05',
                        ),
                        const SizedBox(height: 12),
                        _buildPriceCard(
                          icon: Icons.wallet_outlined,
                          iconBg: const Color(0xFFF5F3FF),
                          label: 'TIỀN ĐẶT CỌC BẢO LƯU',
                          amount: _formatAmountToM(contract['tienCoc']),
                          currency: 'M',
                          currencyColor: AppTheme.deepPurple,
                          statusTag: daKy ? 'Đã nộp' : 'Chờ đối chiếu',
                        ),
                        const SizedBox(height: 24),

                        // Điều khoản & Quy định bổ sung tăng tính học thuật đồ án
                        const Text(
                          '📜 ĐIỀU KHOẢN & QUY ĐỊNH',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          child: const Text(
                            'Điều 1: Trách nhiệm bên thuê phòng trọ HUIT\n'
                            '1.1. Thanh toán tiền phòng đúng hạn thỏa thuận ngày 05 mỗi tháng.\n'
                            '1.2. Giữ gìn vệ sinh chung, nghiêm chỉnh chấp hành quy định an ninh cơ sở.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Minh chứng chữ ký kéo từ Supabase Storage nếu đã ký thành công
                        if (daKy &&
                            contract['urlChuKySupabase'] != null &&
                            contract['urlChuKySupabase']
                                .toString()
                                .isNotEmpty) ...[
                          const Text(
                            'CHỮ KÝ ĐIỆN TỬ ĐÃ XÁC THỰC',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFF9FAFB),
                            ),
                            child: Image.network(
                              contract['urlChuKySupabase'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(
                  context,
                  controller,
                  contract,
                  daKy,
                  trangThai,
                  isExpired,
                  choKetThucSom,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainTitle(Map<String, dynamic> contract, String status) {
    bool isLive = status == "Đang hiệu lực";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HỢP ĐỒNG THUÊ KHÁCH HÀNG',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'HĐ-2026-P${contract['soPhong']}',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? const Color(0xFFFAF5FF) : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLive ? const Color(0xFFF3E8FF) : const Color(0xFFFFEDD5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                color: isLive ? AppTheme.deepPurple : Colors.orange,
                size: 8,
              ),
              const SizedBox(width: 8),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: isLive ? AppTheme.deepPurple : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractProgressCard(
    Map<String, dynamic> contract,
    String? start,
    String? end,
  ) {
    double progressValue = _calculateProgress(start, end);
    int passedMonths = _getPassedMonths(start);
    int totalMonths = _getTotalMonths(start, end);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CƠ SỞ HIỂN THỊ',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${contract['tenCoSo']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.description_outlined,
                color: AppTheme.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ thực tế',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$passedMonths / $totalMonths tháng',
                style: const TextStyle(
                  color: AppTheme.deepPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[300],
            color: AppTheme.deepPurple,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(start),
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(end),
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconTint,
    required String label,
    required String value,
    required String tag,
    required Color tagBg,
    required Color tagTint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconTint),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: tagTint,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String amount,
    required String currency,
    required Color currencyColor,
    String? extraLabel,
    String? extraValue,
    String? statusTag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: currencyColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currency,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: currencyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (extraLabel != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  extraLabel,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  extraValue!,
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (statusTag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusTag,
                style: const TextStyle(
                  color: Color(0xFF047857),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    UserContractController controller,
    Map<String, dynamic> contract,
    bool daKy,
    String trangThai,
    bool isExpired,
    bool choKetThucSom,
  ) {
    bool hasRequestedRenewal = trangThai == "Chờ gia hạn";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: () => _downloadAndOpenUserPdf(context, controller),
            icon: const Icon(Icons.download_outlined, color: Color(0xFF1F2937)),
            label: const Text(
              'Tải hợp đồng (PDF)',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Color(0xFFF3F4F6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (hasRequestedRenewal) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.hourglass_empty, color: Colors.white),
              label: const Text(
                'YÊU CẦU GIA HẠN ĐANG CHỜ DUYỆT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: null,
            ),
          ] else if (isExpired) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.autorenew, color: Colors.white),
              label: const Text(
                'GIA HẠN HỢP ĐỒNG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Yêu cầu gia hạn'),
                    content: const Text('Bạn có chắc chắn muốn gửi yêu cầu gia hạn hợp đồng này đến chủ trọ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Gửi yêu cầu', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ) ?? false;

                if (confirm) {
                  bool ok = await controller.yeuCauGiaHan(controller.maHopDong);
                  if (context.mounted) {
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã gửi yêu cầu gia hạn đến chủ trọ!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gửi yêu cầu gia hạn thất bại.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ] else ...[
            ElevatedButton.icon(
              icon: Icon(
                daKy ? Icons.lock_outline : Icons.border_color_outlined,
                color: Colors.white,
              ),
              label: Text(
                daKy ? 'HỢP ĐỒNG ĐANG CÓ HIỆU LỰC' : 'TIẾN HÀNH KÝ ONLINE NGAY',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: daKy
                    ? Colors.grey.shade400
                    : AppTheme.deepPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: daKy
                  ? null
                  : () async {
                      bool? success = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UrKyHopDongOnline(
                            maHopDong: controller.maHopDong,
                            maKhach:
                                int.tryParse(
                                  (contract['MaKhach'] ??
                                          contract['maKhach'] ??
                                          contract['MAKHACH'] ??
                                          contract['ma_khach'] ??
                                          1)
                                      .toString(),
                                ) ??
                                1,
                          ),
                        ),
                      );

                      if (success == true) {
                        controller.loadContractFlow();
                      }
                    },
            ),
          ],
          // Nút kết thúc sớm — chỉ hiện khi đang hiệu lực
          if (daKy && !isExpired && !hasRequestedRenewal) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showYeuCauKetThucSomDialog(context, controller),
              icon: const Icon(Icons.exit_to_app_outlined, color: Color(0xFFDC2626)),
              label: const Text(
                'Yêu cầu kết thúc sớm',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: const Color(0xFFFFF5F5),
              ),
            ),
          ],

          // Nút chờ duyệt kết thúc sớm
          if (choKetThucSom) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.hourglass_empty, color: Colors.white),
              label: const Text(
                'YÊU CẦU KẾT THÚC SỚM ĐANG CHỜ DUYỆT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: null,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showYeuCauKetThucSomDialog(
    BuildContext context,
    UserContractController controller,
  ) async {
    final lyDoController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.exit_to_app_outlined, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Yêu cầu kết thúc sớm',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vui lòng cung cấp lý do và ngày bạn muốn kết thúc hợp đồng sớm. Yêu cầu sẽ được gửi đến chủ trọ để xem xét và phê duyệt.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lý do kết thúc sớm *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: lyDoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do của bạn...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ngày muốn kết thúc *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      helpText: 'Chọn ngày muốn kết thúc',
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate == null
                              ? 'Chọn ngày...'
                              : '${selectedDate!.day.toString().padLeft(2,'0')}/${selectedDate!.month.toString().padLeft(2,'0')}/${selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (lyDoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập lý do kết thúc sớm!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn ngày muốn kết thúc!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final ok = await controller.yeuCauKetThucSom(
                  controller.maHopDong,
                  lyDoController.text.trim(),
                  selectedDate!,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Đã gửi yêu cầu kết thúc sớm đến chủ trọ!'
                            : 'Gửi yêu cầu thất bại. Vui lòng thử lại.',
                      ),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Gửi yêu cầu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractSelector(
    BuildContext context,
    UserContractController controller,
  ) {
    if (controller.myContracts.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepPurple.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: controller.selectedIndex,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.deepPurple),
          style: const TextStyle(
            color: AppTheme.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          items: List.generate(controller.myContracts.length, (index) {
            final hd = controller.myContracts[index];
            final soPhong = hd['soPhong'] ?? hd['SoPhong'] ?? 'N/A';
            final tenCoSo = hd['tenCoSo'] ?? hd['TenCoSo'] ?? 'Cơ sở';
            final trangThai = hd['trangThai'] ?? 'Chờ ký';
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                "Phòng $soPhong - $tenCoSo ($trangThai)",
                style: const TextStyle(
                  color: AppTheme.deepPurple,
                  fontSize: 14,
                ),
              ),
            );
          }),
          onChanged: (val) async {
            if (val != null) {
              await controller.selectContract(val);
              if (context.mounted) {
                Provider.of<UserPaymentController>(
                  context,
                  listen: false,
                ).loadUserInvoices();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildDraftWarningBanner(UserContractController controller) {
    final draftIndex = controller.myContracts.indexWhere(
      (hd) => (hd['trangThai'] ?? '').toString().trim() == 'Chờ khách ký',
    );
    if (draftIndex == -1 || draftIndex == controller.selectedIndex) {
      return const SizedBox.shrink();
    }

    final draftHd = controller.myContracts[draftIndex];
    final soPhong = draftHd['soPhong'] ?? draftHd['SoPhong'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Có hợp đồng mới chờ ký!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hợp đồng phòng $soPhong đang chờ ký số.',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => controller.selectContract(draftIndex),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xem ngay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
