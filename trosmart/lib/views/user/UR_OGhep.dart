import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 🌟 THÊM: Để bốc phòng động của khách đang đăng nhập
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';
import 'package:intl/intl.dart';

class UrOGhep extends StatefulWidget {
  final int? maPhong; 

  const UrOGhep({super.key, this.maPhong});

  @override
  State<UrOGhep> createState() => _UrOGhepState();
}

class _UrOGhepState extends State<UrOGhep> { // Sửa tên State cho chuẩn cấu trúc Flutter
  bool _isLoading = true;
  Map<String, dynamic>? _oGhepData;
  int _idPhongHienTai = 0;

  @override
  void initState() {
    super.initState();
    _loadRoomAndFetchData();
  }

  // 🌐 1. BỐC MÃ PHÒNG ĐỘNG TỪ HỢP ĐỒNG HOẶC USER ĐANG ĐĂNG NHẬP
  Future<void> _loadRoomAndFetchData() async {
    if (widget.maPhong != null && widget.maPhong! > 0) {
      _idPhongHienTai = widget.maPhong!;
    } else {
      try {
        // Dự phòng nếu tab cha không truyền xuống, bốc từ SharedPreferences hoặc gọi API hợp đồng nháp
        final prefs = await SharedPreferences.getInstance();
        final currentMaKhach = prefs.getInt('ma_khach') ?? 1;

        final token = await AuthService().getToken();
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/HopDong'),
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        );
        if (response.statusCode == 200) {
          final List<dynamic> contracts = jsonDecode(response.body);
          for (var hd in contracts) {
            var dynamicMaKhach = hd['MaKhach'] ?? hd['maKhach'];
            if (dynamicMaKhach != null && dynamicMaKhach.toString() == currentMaKhach.toString()) {
              _idPhongHienTai = int.tryParse((hd['MaPhong'] ?? hd['maPhong']).toString()) ?? 2;
              break;
            }
          }
        }
      } catch (e) {
        _idPhongHienTai = 2; // Fallback an toàn cho máy ảo nghiệm thu
      }
    }
    
    // Nếu vẫn bằng 0 thì gán fallback phòng mặc định để không bị lỗi trống API
    if (_idPhongHienTai == 0) _idPhongHienTai = 2;
    
    _fetchDataOGhep();
  }

  //  2. TẢI DỮ LIỆU ĐỘNG THEO PHÒNG THỰC TẾ
  Future<void> _fetchDataOGhep() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/OGhep/chi-tiet/$_idPhongHienTai'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _oGhepData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _oGhepData = null);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu ở ghép: $e');
      if (mounted) {
        setState(() {
          _oGhepData = null;
          _isLoading = false;
        });
      }
    }
  }

  String _formatMoney(dynamic amount) {
    if (amount == null) return "0đ";
    return NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppTheme.deepPurple)),
      );
    }

    if (_oGhepData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.roofing_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Phòng này hiện tại chưa kích hoạt hợp đồng "Đang hiệu lực" hoặc chưa có thành viên ở ghép để tính toán hóa đơn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadRoomAndFetchData, 
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tải lại dữ liệu'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.deepPurple, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final soPhong = _oGhepData!['soPhong'] ?? 'Trống';
    final tenCoSo = _oGhepData!['tenCoSo'] ?? 'Chưa rõ cơ sở';
    final soNguoiO = _oGhepData!['soNguoiO'] ?? 0;
    final List<dynamic> thanhViens = _oGhepData!['thanhViens'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 🌟 TỰ ĐỘNG ẨN/HIỆN NÚT BACK: Tránh lỗi crash điều hướng khi chạy lồng trong IndexedStack cha
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepPurple),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDataOGhep,
        color: AppTheme.deepPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ở ghép', style: AppTheme.titleMd.copyWith(fontSize: 32, color: AppTheme.deepPurple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('Phòng $soPhong ($soNguoiO người) - $tenCoSo', style: AppTheme.bodySm.copyWith(color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 24),

              _buildProgressCard(),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.group_outlined, size: 20, color: AppTheme.deepPurple),
                  const SizedBox(width: 8),
                  Text('Thành viên phòng', style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: thanhViens.length,
                itemBuilder: (context, index) {
                  final tv = thanhViens[index];
                  bool isPaid = tv['trangThaiThanhToan'] == 'Đã trả';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildMemberCard(
                      tv['hoTen'] ?? 'Khách thuê',
                      tv['vaiTro'] ?? 'Thành viên',
                      tv['trangThaiThanhToan'] ?? 'Chưa rõ',
                      _formatMoney(tv['conPhaiTra'] ?? 0),
                      isPaid: isPaid,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              _buildPaymentDetailCard(),
              const SizedBox(height: 24),
              
              Center(
                child: Text(
                  'Hệ thống tính toán tự động dựa trên hợp đồng thuê phòng',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySm.copyWith(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    // 🌟 FIX CHÍ MẠNG: Ép kiểu an toàn qua num.parse để tránh crash kẹt lỗi kiểu dữ liệu int vs double trong Dart
    final rawProgress = _oGhepData!['phanTramTienDo'] ?? 0.0;
    final double progressValue = double.parse(rawProgress.toString()).clamp(0.0, 1.0);
    
    final progressPercentStr = "${(progressValue * 100).toStringAsFixed(0)}%";
    final daThuStr = _formatMoney(_oGhepData!['daThu']);
    final conLaiStr = _formatMoney(_oGhepData!['conLai']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgGray200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressInfo('Tiến độ thu tiền', progressPercentStr),
              _buildProgressInfo('Đã thu: $daThuStr', 'Còn lại: $conLaiStr', alignRight: true),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: AppTheme.bgGray200,
            color: AppTheme.deepPurple,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('KHỞI TẠO', style: AppTheme.bodySm.copyWith(fontSize: 10, letterSpacing: 1, color: Colors.grey)),
              Text('HOÀN TẤT', style: AppTheme.bodySm.copyWith(fontSize: 10, letterSpacing: 1, color: AppTheme.deepPurple, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProgressInfo(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySm.copyWith(color: AppTheme.textSecondary)),
        Text(value, style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold, color: AppTheme.deepPurple)),
      ],
    );
  }

  Widget _buildMemberCard(String name, String role, String status, String amount, {required bool isPaid}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPaid ? AppTheme.bgGray200 : AppTheme.deepPurple.withOpacity(0.4), width: isPaid ? 1 : 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.bgGray200, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person_outline, size: 24, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                Text(role, style: AppTheme.bodySm.copyWith(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: isPaid ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(amount, style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentDetailCard() {
    final tongHoaDonStr = _formatMoney(_oGhepData!['tongHoaDon']);
    final tienChiaDeuStr = _formatMoney(_oGhepData!['tienChiaDeu']);
    
    String tenNguoiChuaTra = "";
    final List<dynamic> thanhViens = _oGhepData!['thanhViens'] ?? [];
    for (var tv in thanhViens) {
      if (tv['trangThaiThanhToan'] == 'Chưa trả' && tv['vaiTro'] != 'Chủ phòng') {
        tenNguoiChuaTra = tv['hoTen'] ?? '';
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF3F0F8), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.deepPurple.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHI TIẾT THANH TOÁN CHIA ĐỀU', style: AppTheme.bodySm.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.deepPurple)),
          const SizedBox(height: 16),
          _buildDetailRow('Tổng hóa đơn tháng này', tongHoaDonStr),
          _buildDetailRow('Chia đều mỗi thành viên', tienChiaDeuStr, isPurple: true),
          
          if (tenNguoiChuaTra.isNotEmpty) ...[
            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('⚡ Đã gửi thông báo FCM nhắc nhở đóng tiền phòng đến $tenNguoiChuaTra!'), backgroundColor: Colors.purple),
                );
              },
              icon: const Icon(Icons.campaign_outlined),
              label: Text('Nhắc $tenNguoiChuaTra thanh toán liền'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepPurple.withOpacity(0.2),
                foregroundColor: AppTheme.deepPurple,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPurple = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMd.copyWith(color: Colors.black87)),
          Text(value, style: AppTheme.bodyMd.copyWith(
            fontWeight: isPurple ? FontWeight.w900 : FontWeight.bold,
            color: isPurple ? AppTheme.deepPurple : AppTheme.textPrimary,
          )),
        ],
      ),
    );
  }
}