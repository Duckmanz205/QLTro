import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';
import 'AD_EditLich.dart'; 
import 'AD_DeleteLich.dart'; 

class AdDetailLich extends StatefulWidget {
  final int maLichHen;

  const AdDetailLich({super.key, required this.maLichHen});

  @override
  State<AdDetailLich> createState() => _AdDetailLichState();
}

class _AdDetailLichState extends State<AdDetailLich> {
  bool _isLoading = true;
  Map<String, dynamic>? _lichHenData;

  @override
  void initState() {
    super.initState();
    _fetchDetailLichHen();
  }

  // --- HÀM LẤY DỮ LIỆU CHI TIẾT TỪ DB QUA API C# ---
  Future<void> _fetchDetailLichHen() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/${widget.maLichHen}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
        print("DỮ LIỆU THỰC TẾ TỪ C# TRẢ VỀ: ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          _lichHenData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnackBar('Không thể tải chi tiết lịch hẹn', Colors.red);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối API: $e', Colors.red);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM XỬ LÝ HOÀN THÀNH LỊCH (PUT STATUS) ---
  Future<void> _completeStatus() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/${widget.maLichHen}/status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'TrangThaiMoi': 'Đã hoàn thành'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar('Đã hoàn thành lịch hẹn!', Colors.green);
        _fetchDetailLichHen(); 
      } else {
        _showSnackBar('Thao tác thất bại!', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  String _getShortName(String fullName) {
    if (fullName.isEmpty) return "KH";
    List<String> words = fullName.trim().split(' ');
    if (words.length >= 2) {
      return (words[words.length - 2][0] + words[words.length - 1][0]).toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  String _getTimeRemaining(String? isoTimeString) {
    if (isoTimeString == null) return "";
    DateTime eventTime = DateTime.parse(isoTimeString);
    DateTime now = DateTime.now();
    
    if (eventTime.isBefore(now)) {
      return "Đã diễn ra";
    }
    
    Duration difference = eventTime.difference(now);
    if (difference.inDays > 0) {
      return "Còn ${difference.inDays} ngày nữa";
    } else if (difference.inHours > 0) {
      return "Còn ${difference.inHours} giờ ${difference.inMinutes % 60} phút";
    } else {
      return "Còn ${difference.inMinutes} phút";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF64417F))),
      );
    }

    if (_lichHenData == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy dữ liệu lịch hẹn.')),
      );
    }

    // ĐỌC DỮ LIỆU ĐỘNG: Hỗ trợ map chữ Hoa/Thường từ hàm danh sách C# truyền sang
    final hoTen = _lichHenData!['HoTenKhach'] ?? _lichHenData!['hoTenKhach'] ?? 'Khách ẩn danh';
    final sdt = _lichHenData!['SDTKhach'] ?? _lichHenData!['sdtKhach'] ?? _lichHenData!['SdtKhach'] ?? 'Chưa cập nhật số';
    final tieuDe = _lichHenData!['Tiêu đề'] ?? _lichHenData!['tieuDe'] ?? 'Hẹn xem phòng';
    final soPhong = _lichHenData!['SoPhong'] ?? _lichHenData!['soPhong'] ?? 'Trống';
    final tenCoSo = _lichHenData!['TenCoSo'] ?? _lichHenData!['tenCoSo'] ?? 'Chưa rõ cơ sở';
    final ghiChu = _lichHenData!['GhiChu'] ?? _lichHenData!['ghiChu'] ?? 'Không có ghi chú của bạn';
    
    final thoiGianStr = _lichHenData!['ThoiGianHen'] ?? _lichHenData!['thoiGianHen'];
    DateTime thoiGianHen = thoiGianStr != null ? DateTime.parse(thoiGianStr) : DateTime.now();
    
    final String formattedDate = DateFormat('EEEE, dd/MM/yyyy').format(thoiGianHen);
    final String formattedTime = DateFormat('HH:mm').format(thoiGianHen);
    final String timeRemaining = _getTimeRemaining(thoiGianStr);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildSubHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KHỐI THÔNG TIN KHÁCH HÀNG (VIỀN XANH ACCENT)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00B4FF), width: 2),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFF1ECF7),
                          child: Text(
                            _getShortName(hoTen),
                            style: const TextStyle(color: Color(0xFF64417F), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$hoTen (Khách xem phòng)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A0D2D)),
                              ),
                              const SizedBox(height: 4),
                              Text(sdt, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. KHỐI CHI TIẾT CHỮ THUẦN (MỤC ĐÍCH / THỜI GIAN / ĐỊA ĐIỂM)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MỤC ĐÍCH', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('$tieuDe P.$soPhong ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A0D2D))),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                        ),

                        const Text('THỜI GIAN', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A0D2D))),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              formattedTime, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF64417F)),
                            ),
                            const SizedBox(width: 10),
                            if (timeRemaining.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1ECF7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  timeRemaining, 
                                  style: const TextStyle(color: Color(0xFF64417F), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                        ),

                        const Text('ĐỊA ĐIỂM CƠ SỞ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(tenCoSo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF64417F))),
                        const SizedBox(height: 2),
                        
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. KHỐI GHI CHÚ
                  const Text('GHI CHÚ CỦA BẠN', style: TextStyle(color: Color(0xFF64417F), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFCFD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      ghiChu,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. HỆ THỐNG PHÍM ĐIỀU HƯỚNG
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _completeStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64417F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        elevation: 0,
                      ),
                      child: const Text('Hoàn thành lịch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AdEditLich(lichHenData: _lichHenData!)),
                              );
                              if (result == true) {
                                _fetchDetailLichHen(); 
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF64417F)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Text('Chỉnh sửa', style: TextStyle(color: Color(0xFF64417F), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            // 🌟 FIX ĐÚNG LOGIC: Bấm phát chuyển hướng sang trang AdDeleteLich chứ không tự delete thẳng tay
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AdDeleteLich(lichHenData: _lichHenData!)),
                              );
                              if (result == true) {
                                Navigator.pop(context, true); // Trở về danh sách cha và ép reload lại F5
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF5A5A)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Text('Hủy hẹn', style: TextStyle(color: Color(0xFFFF5A5A), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 18, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA161D2), Color(0xFF64417F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Chi tiết lịch hẹn', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('SẮP DIỄN RA', style: TextStyle(color: Color(0xFF2DDCB1), fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}