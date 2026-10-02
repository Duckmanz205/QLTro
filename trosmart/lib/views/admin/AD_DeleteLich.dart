import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';

class AdDeleteLich extends StatefulWidget {
  final Map<String, dynamic> lichHenData;

  const AdDeleteLich({super.key, required this.lichHenData});

  @override
  State<AdDeleteLich> createState() => _AdDeleteLichState();
}

class _AdDeleteLichState extends State<AdDeleteLich> {
  bool _sendNotify = true;
  bool _isLoading = false;
  String _selectedReason = 'Khách báo bận / Dời lịch';
  
  late int _maLichHen;
  late String _customerName;
  late String _soPhong;
  late String _formattedDateTime;

  final List<String> _reasons = [
    'Khách báo bận / Dời lịch',
    'Khách không đến / Không liên lạc được',
    'Phòng đã có người khác cọc trước',
    'Chủ nhà bận đột xuất',
    'Lý do khác'
  ];

  @override
  void initState() {
    super.initState();
    //  ĐỒNG BỘ ÉP CHUỖI AN TOÀN: Đọc cả hai kiểu key hoa/thường và lót sẵn text tránh gãy biến late
    final data = widget.lichHenData;
    _maLichHen = data['MaLichHen'] ?? data['maLichHen'] ?? 0;
    _customerName = data['HoTenKhach'] ?? data['hoTenKhach'] ?? 'Khách thuê';
    _soPhong = (data['SoPhong'] ?? data['soPhong'] ?? '101').toString();
    
    final thoiGianHenVal = data['ThoiGianHen'] ?? data['thoiGianHen'];
    if (thoiGianHenVal != null) {
      DateTime date = DateTime.parse(thoiGianHenVal);
      _formattedDateTime = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} | ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } else {
      _formattedDateTime = "18:36 | 31/05/2026";
    }
  }

  // 🌟 HÀM FIX LỖI CHÍ MẠNG: Gọi chuẩn API HttpDelete xóa cứng vĩnh viễn dữ liệu khỏi SQL Server
  Future<void> _executeDeleteLichHen() async {
    if (_maLichHen == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ma lich hen không hop le!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🌟 ĐỒNG BỘ: Chuyển hoàn toàn sang http.delete và truyền ID trực tiếp lên URL
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/$_maLichHen'),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Hiện thông báo sạch (Không kèm emoji lạ tránh lỗi kẹt font Noto treo UI)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Da xoa vinh vien lich hen khoi he thong!'), 
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // Đóng màn hình và truyền giá trị true về để trang danh sách AD_LichCongViec gọi lại _fetchLichHens() làm mới UI
        Navigator.pop(context, true); 
      } else {
        // In log ra debug console để ông dễ kiểm soát lỗi hệ thống ngầm
        debugPrint('Lỗi Server Code: ${response.statusCode} - Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Huy lich hen that bai!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Lỗi kết nối client: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loi ket noi den may chu API!'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewCard(),
                  const SizedBox(height: 24),
                  const Text('Lý do hủy lịch', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildReasonDropdown(),
                  const SizedBox(height: 24),
                  _buildNotifySwitch(),
                  const SizedBox(height: 12),
                  Text(
                    'Lưu ý: Sau khi xác nhận xóa, bản ghi lịch hẹn này sẽ bị loại bỏ vĩnh viễn khỏi cơ sở dữ liệu.',
                    style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 11),
                  ),
                  const SizedBox(height: 40),
                  _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.red))
                      : _buildActionButtons(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: statusBarHeight + 24, bottom: 24),
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.red, size: 32),
          ),
          const SizedBox(height: 8),
          const Text('Xác nhận hủy lịch?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LỊCH HẸN VỚI', style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('$_customerName - Xem phòng P.$_soPhong', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.deepPurple),
              const SizedBox(width: 8),
              Text(_formattedDateTime, style: const TextStyle(color: AppTheme.deepPurple, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReason,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => _selectedReason = newValue);
          },
          items: _reasons.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotifySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3F0F8), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Gửi thông báo hủy cho khách', style: TextStyle(fontSize: 13, color: Colors.black87)),
          Switch(
            value: _sendNotify,
            onChanged: (v) => setState(() => _sendNotify = v),
            activeColor: AppTheme.deepPurple,
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _executeDeleteLichHen,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
          child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            side: const BorderSide(color: AppTheme.deepPurple),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: const Text('Quay lại', style: TextStyle(color: AppTheme.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
        )
      ],
    );
  }
}