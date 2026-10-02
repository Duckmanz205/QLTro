import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../models/thong_bao.dart';
import '../../services/thong_bao_service.dart';
import '../../logic/auth/auth_service.dart';

class AdEditLich extends StatefulWidget {
  // Nhận dữ liệu của lịch hẹn cần chỉnh sửa từ màn hình danh sách truyền sang
  final Map<String, dynamic> lichHenData;

  const AdEditLich({super.key, required this.lichHenData});

  @override
  State<AdEditLich> createState() => _AdEditLichState();
}

class _AdEditLichState extends State<AdEditLich> {
  // --- LOGIC CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _nameController;  // 🌟 THÊM MỚI: Sửa riêng tên khách
  late TextEditingController _phoneController; // 🌟 THÊM MỚI: Sửa riêng số điện thoại
  late TextEditingController _noteController;

  // --- STATE VARIABLES ---
  bool _sendNotify = true;
  bool _isLoading = false;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late Map<String, dynamic> _currentLichHen;

  // Thông tin định danh dưới SQL Server
  late int _maLichHen;
  late int _maPhong;
  int? _maKhach;

  @override
  void initState() {
    super.initState();
    _currentLichHen = widget.lichHenData;
    _maLichHen = _currentLichHen['MaLichHen'] ?? _currentLichHen['maLichHen'] ?? 0;
    _maPhong = _currentLichHen['MaPhong'] ?? _currentLichHen['maPhong'] ?? 1; // Mặc định phòng 1 nếu lỗi
    _maKhach = _currentLichHen['MaKhach'] ?? _currentLichHen['maKhach'];
    
    // Đổ dữ liệu cũ lên form gõ chữ (Hỗ trợ cả trường hợp key hoa hoặc thường từ API)
    _titleController = TextEditingController(text: _currentLichHen['Tiêu đề'] ?? 'Lịch hẹn xem phòng');
    _nameController = TextEditingController(text: _currentLichHen['HoTenKhach'] ?? _currentLichHen['hoTenKhach'] ?? '');
    _phoneController = TextEditingController(text: _currentLichHen['SDTKhach'] ?? _currentLichHen['sdtKhach'] ?? '');
    _noteController = TextEditingController(text: _currentLichHen['GhiChu'] ?? _currentLichHen['ghiChu'] ?? '');
    
    // Phân tích DateTime cũ từ API để đổ lên bộ chọn thời gian
    final thoiGianHenVal = _currentLichHen['ThoiGianHen'] ?? _currentLichHen['thoiGianHen'];
    if (thoiGianHenVal != null) {
      DateTime originalDateTime = DateTime.parse(thoiGianHenVal);
      _selectedDate = originalDateTime;
      _selectedTime = TimeOfDay(hour: originalDateTime.hour, minute: originalDateTime.minute);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- HÀM MỞ BỘ CHỌN NGÀY THẬT ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- HÀM MỞ BỘ CHỌN GIỜ THẬT ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- CÁC TÙY CHỌN DỜI GIỜ NHANH ---
  void _quickAdjustTime(int minutes) {
    DateTime currentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    DateTime adjusted = currentDateTime.add(Duration(minutes: minutes));
    setState(() {
      _selectedDate = adjusted;
      _selectedTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
    });
  }

  void _shiftToAfternoon() {
    setState(() {
      _selectedTime = const TimeOfDay(hour: 14, minute: 0); // Mặc định dời sang 2:00 PM
    });
  }

  // --- LOGIC GỬI LỆNH CẬP NHẬT LÊN BACKEND C# (.NET) ---
  void _handleSaveUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Gộp ngày giờ mới thành chuỗi ISO 8601 chuẩn chỉnh
    final DateTime finalUpdatedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      // 🌟 ĐỒNG BỘ JSON: Đóng gói chuẩn xác khít 100% các trường thuộc CreateLichHenDto bên C#
      final Map<String, dynamic> updateBody = {
        'MaPhong': _maPhong,
        'HoTenKhach': _nameController.text.trim(),
        'SDTKhach': _phoneController.text.trim(),
        'ThoiGianHen': finalUpdatedDateTime.toIso8601String(),
        'GhiChu': _noteController.text.trim(),
      };

      // Gọi API PUT thường cập nhật thông tin lịch hẹn lên SQL Server
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/$_maLichHen'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (_sendNotify && _maKhach != null && _maKhach != 0) {
          try {
            final formattedNewTime = DateFormat('HH:mm dd/MM/yyyy').format(finalUpdatedDateTime);
            final soPhongStr = _currentLichHen['SoPhong'] ?? _currentLichHen['soPhong'] ?? '$_maPhong';
            final tenCoSoStr = _currentLichHen['TenCoSo'] ?? _currentLichHen['tenCoSo'] ?? '';
            final diaDiemStr = tenCoSoStr.isNotEmpty ? '$soPhongStr ($tenCoSoStr)' : '$soPhongStr';

            await ThongBaoService().sendThongBao(ThongBao(
              maThongBao: 0,
              maKhach: _maKhach!,
              tieuDe: 'Thay đổi lịch hẹn xem phòng',
              noiDung: 'Lịch hẹn xem phòng tại phòng $diaDiemStr đã được thay đổi sang lúc $formattedNewTime.',
              daDoc: false,
              loaiThongBao: 'Hệ thống',
            ));
          } catch (e) {
            debugPrint("Lỗi gửi thông báo: $e");
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Cập nhật lịch hẹn thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Trả về true để màn hình danh sách tự reload dữ liệu mới
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng kiểm tra lại dữ liệu!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối API: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateString = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final String timeString = _selectedTime.format(context);

    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSubHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('MỤC ĐÍCH / TIÊU ĐỀ'),
                      _buildInputField('Tiêu đề lịch hẹn', _titleController),
                      
                      const SizedBox(height: 24),
                      _buildLabel('THỜI GIAN HẸN MỚI'),
                      Row(
                        children: [
                          Expanded(child: _buildSelectBox(dateString, () => _selectDate(context))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSelectBox(timeString, () => _selectTime(context))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTimeQuickOptions(),
                      
                      const SizedBox(height: 24),
                      _buildLabel('TÊN KHÁCH HÀNG'), // 🌟 ĐẤY Ô GÕ CHỮ ĐỘNG
                      _buildInputField('Nhập tên khách hàng', _nameController),

                      const SizedBox(height: 24),
                      _buildLabel('SỐ ĐIỆN THOẠI KHÁCH'), // 🌟 ĐẤY Ô GÕ CHỮ ĐỘNG
                      _buildInputField('Nhập số điện thoại', _phoneController, keyboardType: TextInputType.phone),
                      
                      const SizedBox(height: 24),
                      _buildLabel('ĐỊA ĐIỂM CỐ ĐỊNH'),
                      _buildReadOnlyField(null, 'Mã số phòng ID đang hẹn: $_maPhong'),
                      
                      const SizedBox(height: 24),
                      _buildLabel('TÙY CHỌN CẬP NHẬT'),
                      _buildNotifySwitch(),
                      
                      const SizedBox(height: 24),
                      _buildLabel('GHI CHÚ NỘI BỘ', isMuted: true),
                      _buildTextArea(_noteController),
                      
                      const SizedBox(height: 32),
                      _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.deepPurple))
                          : _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: statusBarHeight + 24, bottom: 24, left: 20, right: 20),
      color: AppTheme.deepPurple,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Chỉnh sửa lịch hẹn', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Text('ID: #L$_maLichHen', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isMuted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, 
        style: TextStyle(
          color: isMuted ? Colors.grey : AppTheme.deepPurple, 
          fontSize: 11, 
          fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A0D2D)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String? label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }

  Widget _buildSelectBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.deepPurple.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 14)),
            Icon(Icons.arrow_drop_down, color: AppTheme.deepPurple, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeQuickOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickOptButton('+30 phút', () => _quickAdjustTime(30)),
        _buildQuickOptButton('+1 giờ', () => _quickAdjustTime(60)),
        _buildQuickOptButton('Dời sang chiều', _shiftToAfternoon),
      ],
    );
  }

  Widget _buildQuickOptButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF3EDF7), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: AppTheme.deepPurple, fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildNotifySwitch() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3F0F8), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Gửi thông báo thay đổi cho khách',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Switch(
            value: _sendNotify,
            onChanged: (v) => setState(() => _sendNotify = v),
            activeColor: AppTheme.deepPurple,
          )
        ],
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _handleSaveUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepPurple,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: const Text('Lưu cập nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.deepPurple,
      currentIndex: 2,
      onTap: (int index) {
        if (index != 2) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Hóa đơn'),
        BottomNavigationBarItem(icon: Icon(Icons.business_outlined), label: 'Phòng'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
    );
  }
}