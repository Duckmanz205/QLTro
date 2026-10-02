import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';

class AdEditHopDong extends StatefulWidget {
  final int maHopDong;
  const AdEditHopDong({super.key, required this.maHopDong});

  @override
  State<AdEditHopDong> createState() => _AdEditHopDongState();
}

class _AdEditHopDongState extends State<AdEditHopDong> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Dữ liệu chỉ đọc hiển thị cho Admin biết đang sửa hợp đồng nào
  String _tenKhach = "";
  String _thongTinPhong = "";
  
  // Dữ liệu có thể chỉnh sửa
  DateTime? _ngayBatDau;
  DateTime? _ngayKetThuc;
  final TextEditingController _tienCocController = TextEditingController();

  final NumberFormat _currencyFormat = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();
    _fetchContractDetails();
  }

  // 1. GỌI API LẤY THÔNG TIN HỢP ĐỒNG HIỆN TẠI ĐỂ ĐỔ VÀO FORM
  Future<void> _fetchContractDetails() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tenKhach = data['tenKhach'] ?? "N/A";
          _thongTinPhong = "Phòng ${data['soPhong']} - ${data['tenCoSo']}";
          
          if (data['ngayBatDau'] != null) {
            _ngayBatDau = DateTime.parse(data['ngayBatDau'].toString());
          }
          if (data['ngayKetThuc'] != null) {
            _ngayKetThuc = DateTime.parse(data['ngayKetThuc'].toString());
          }
          
          if (data['tienCoc'] != null) {
            // Chuyển đổi định dạng số nguyên gọn gàng để cho vào Text Field
            _tienCocController.text = double.parse(data['tienCoc'].toString()).toInt().toString();
          }
          
          _isLoading = false;
        });
      } else {
        throw Exception("Lỗi khi tải dữ liệu hợp đồng");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Lỗi hệ thống: $e", Colors.red);
    }
  }

  // 2. GỌI API CẬP NHẬT ĐIỀU KHOẢN (PUT)
  Future<void> _updateContract() async {
    if (_ngayBatDau == null || _ngayKetThuc == null || _tienCocController.text.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ các trường!", Colors.orange);
      return;
    }
    
    if (_ngayBatDau!.isAfter(_ngayKetThuc!)) {
      _showSnackBar("Ngày bắt đầu không được lớn hơn ngày kết thúc!", Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}'),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "maPhong": 0, // Backend ông không check mã phòng/khách khi update nên truyền ảo 0 là an toàn
          "maKhach": 0,
          "ngayBatDau": DateFormat('yyyy-MM-dd').format(_ngayBatDau!),
          "ngayKetThuc": DateFormat('yyyy-MM-dd').format(_ngayKetThuc!),
          "tienCoc": double.parse(_tienCocController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Trả kết quả true về trang danh sách để báo hiệu cập nhật lưới dữ liệu
        if (mounted) Navigator.pop(context, true); 
      } else {
        throw Exception("Không thể cập nhật. Lỗi server!");
      }
    } catch (e) {
      _showSnackBar("Lỗi khi lưu: $e", Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  // HÀM CHỌN NGÀY CHUẨN UI
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_ngayBatDau ?? DateTime.now()) : (_ngayKetThuc ?? DateTime.now().add(const Duration(days: 365))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepPurple, 
              onPrimary: Colors.white, 
              onSurface: Colors.black, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _ngayBatDau = picked;
        } else {
          _ngayKetThuc = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepPurple, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text('Chỉnh sửa hợp đồng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.deepPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD THÔNG TIN CỐ ĐỊNH TỪ SERVER (Read-Only)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.deepPurple, Color(0xFF64417F)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppTheme.deepPurple.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ĐANG CHỈNH SỬA CHO", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(_tenKhach, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.meeting_room, color: Color(0xFF2DDCB1), size: 16),
                            const SizedBox(width: 6),
                            Text(_thongTinPhong, style: const TextStyle(color: Color(0xFF2DDCB1), fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // FORM NHẬP LIỆU CHÍNH
                  const Text('Điều khoản hợp đồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),

                  // 1. Ngày bắt đầu
                  _buildDatePickerField(
                    label: "Ngày bắt đầu tính tiền",
                    dateValue: _ngayBatDau,
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 16),

                  // 2. Ngày kết thúc
                  _buildDatePickerField(
                    label: "Ngày kết thúc hợp đồng",
                    dateValue: _ngayKetThuc,
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 16),

                  // 3. Tiền cọc
                  const Text("Tiền đặt cọc (VND)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tienCocController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'VD: 3000000',
                      prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppTheme.deepPurple),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.deepPurple, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      // NÚT LƯU THAY ĐỔI
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _isLoading || _isSaving ? null : _updateContract,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text("Lưu Thay Đổi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }

  // WIDGET DÙNG CHUNG CHO CHỌN NGÀY
  Widget _buildDatePickerField({required String label, required DateTime? dateValue, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateValue != null ? DateFormat('dd/MM/yyyy').format(dateValue) : "Chọn ngày...",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: dateValue != null ? Colors.black87 : Colors.black38),
                ),
                const Icon(Icons.calendar_month, color: AppTheme.deepPurple, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}