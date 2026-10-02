import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart'; // 🌟 Gọi đúng file constants chung của Thái
import '../../logic/auth/auth_service.dart';

class UrLichSuXemPhong extends StatefulWidget {
  final int maKhach; // 🌟 THÊM BIẾN NÀY ĐỂ HỨNG MAKHACH TỪ TRANG HOÀN TẤT SANG

  const UrLichSuXemPhong({super.key, required this.maKhach});

  @override
  State<UrLichSuXemPhong> createState() => _UrLichSuXemPhongState();
}

class _UrLichSuXemPhongState extends State<UrLichSuXemPhong> {
  int _activeTab = 0; // 0 = Sắp tới, 1 = Đã xem, 2 = Đã hủy
  List<dynamic> _allAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLichSuHen();
  }

  // 🌐 LẤY DANH SÁCH LỊCH HẸN THEO MAKHACH ĐỘNG ĐÃ QUA LỌC TỪ C#
  Future<void> _fetchLichSuHen() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/lich-su/${widget.maKhach}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _allAppointments = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Mã lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Lỗi tải lịch sử xem phòng: $e");
    }
  }

  // 🌐 CẬP NHẬT TRẠNG THÁI HỦY LỊCH HẸN KHỚP 100% C# SWAGGER
  Future<void> _handleCancelAppointment(int maLichHen) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Xác nhận hủy lịch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn hủy lịch hẹn xem phòng này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Không',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hủy lịch',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/$maLichHen/status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"trangThaiMoi": "Đã hủy"}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy lịch hẹn thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchLichSuHen(); // Reload lại data
        }
      } else {
        throw Exception('Server phản hồi mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể hủy lịch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🌟 ĐỒNG BỘ BỘ LỌC CHỮ HOA/THƯỜNG THEO ĐÚNG GIÁ TRỊ TRONG SQL SERVER
  List<dynamic> _getFilteredAppointments() {
    if (_activeTab == 0) {
      return _allAppointments.where((item) {
        final status = (item['trangThai'] ?? item['TrangThai'] ?? "")
            .toString()
            .trim();
        return status == "Chờ xác nhận" || status == "Đã xác nhận";
      }).toList();
    } else if (_activeTab == 1) {
      return _allAppointments
          .where((item) {
            final status = (item['trangThai'] ?? item['TrangThai'] ?? "")
                .toString()
                .trim();
            return status == "Đã xem" || status == "Đã hoàn thành";
          })
          .toList();
    } else {
      return _allAppointments
          .where(
            (item) =>
                (item['trangThai'] ?? item['TrangThai'] ?? "")
                    .toString()
                    .trim() ==
                "Đã hủy",
          )
          .toList();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case "Chờ xác nhận":
        return const Color(0xFF1976D2);
      case "Đã xác nhận":
        return const Color(0xFF2E7D32);
      case "Đã xem":
      case "Đã hoàn thành":
        return const Color(0xFF059669);
      case "Đã hủy":
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.trim()) {
      case "Chờ xác nhận":
        return const Color(0xFFE3F2FD);
      case "Đã xác nhận":
        return const Color(0xFFE8F5E9);
      case "Đã xem":
      case "Đã hoàn thành":
        return const Color(0xFFD1FAE5);
      case "Đã hủy":
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredAppointments();

    final upcomingCount = _allAppointments.where((item) {
      final s = (item['trangThai'] ?? item['TrangThai'] ?? "")
          .toString()
          .trim();
      return s == "Chờ xác nhận" || s == "Đã xác nhận";
    }).length;

    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _fetchLichSuHen,
        color: AppTheme.deepPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildSubHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabToggle(upcomingCount),
                    const SizedBox(height: 20),
                    if (upcomingCount > 0) ...[
                      _buildNotificationBanner(),
                      const SizedBox(height: 20),
                    ],
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : filteredData.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Không tìm thấy lịch hẹn nào ở mục này !',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final item = filteredData[index];
                              DateTime thoiGian = DateTime.parse(
                                item['thoiGianHen'] ?? item['ThoiGianHen'],
                              );
                              String trangThaiStr =
                                  (item['trangThai'] ??
                                          item['TrangThai'] ??
                                          "Chờ xác nhận")
                                      .toString()
                                      .trim();

                              String dayOfWeek = DateFormat(
                                "EEEE",
                              ).format(thoiGian).toUpperCase();
                              String monthStr = DateFormat(
                                "MM",
                              ).format(thoiGian);
                              String dayStr = DateFormat("dd").format(thoiGian);
                              String formatDay =
                                  "$dayOfWeek, THÁNG $monthStr $dayStr";

                              String formatTime = DateFormat(
                                "HH:mm",
                              ).format(thoiGian);
                              String formatTimeEnd = DateFormat('HH:mm').format(
                                thoiGian.add(const Duration(minutes: 30)),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildAppointmentCard(
                                  status: trangThaiStr,
                                  statusColor: _getStatusColor(trangThaiStr),
                                  statusBg: _getStatusBg(trangThaiStr),
                                  date: formatDay,
                                  title:
                                      'Phòng ${item['soPhong'] ?? item['SoPhong'] ?? 'Trống'} - ${item['tenCoSo'] ?? item['TenCoSo'] ?? "Cơ sở hệ thống"}',
                                  time: '$formatTime - $formatTimeEnd',
                                  guide: 'Ban Quản Lý Trợ Smart',
                                  contact:
                                      (item['ghiChu'] ?? item['GhiChu']) !=
                                              null &&
                                          (item['ghiChu'] ?? item['GhiChu'])
                                              .toString()
                                              .isNotEmpty
                                      ? 'Ghi chú: ${item['ghiChu'] ?? item['GhiChu']}'
                                      : 'Liên hệ: 0905123136',
                                  hasCallButton: trangThaiStr == "Đã xác nhận",
                                  hasCancelButton:
                                      trangThaiStr == "Chờ xác nhận",
                                  isPast: _activeTab != 0,
                                  onCancelPressed: () =>
                                      _handleCancelAppointment(
                                        item['maLichHen'] ?? item['MaLichHen'],
                                      ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA161D2), Color(0xFF64417F)],
          ),
        ),
      ),
      leading: const Icon(Icons.menu, color: Colors.white),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.home_work_rounded, color: Color(0xFF2DDCB1), size: 24),
          SizedBox(width: 8),
          Text(
            'TroSmart',
            style: TextStyle(
              color: Color(0xFF2DDCB1),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x4C2DDCB1)),
              ),
              child: const Text(
                'Khách',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      color: AppTheme.deepPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Lịch hẹn của tôi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 4),
            child: Text('Theo dõi và quản lý các lượt xem phòng', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle(int upcomingCount) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Sắp tới ($upcomingCount)'),
          _buildTabItem(1, 'Đã xem'),
          _buildTabItem(2, 'Đã hủy'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Text('🔔', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bạn đang có lịch xem phòng sắp diễn ra, chú ý điện thoại nhé!',
              style: TextStyle(
                color: AppTheme.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String date,
    required String title,
    required String time,
    String? guide,
    String? contact,
    bool hasCallButton = false,
    bool hasCancelButton = false,
    bool isPast = false,
    VoidCallback? onCancelPressed,
  }) {
    return Opacity(
      opacity: isPast ? 0.65 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.bgGray200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: const TextStyle(
                color: AppTheme.deepPurple,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF3F0F8),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: AppTheme.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide ?? 'Ban Quản Lý',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        contact ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasCallButton)
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text(
                        'Gọi điện',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (hasCancelButton)
                  GestureDetector(
                    onTap: onCancelPressed,
                    child: const Text(
                      'Hủy lịch',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.deepPurple,
      currentIndex: 3,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Hóa đơn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work_outlined),
          label: 'Phòng',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
    );
  }
}
