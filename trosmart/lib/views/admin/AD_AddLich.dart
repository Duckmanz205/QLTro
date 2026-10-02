import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/admin/co_so_service.dart';
import '../../logic/admin/phong_service.dart';
import '../../logic/auth/auth_service.dart';

class AdAddLich extends StatefulWidget {
  const AdAddLich({super.key});

  @override
  State<AdAddLich> createState() => _AdAddLichState();
}

class _AdAddLichState extends State<AdAddLich> {
  // Logic Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // 🌟 TÁCH RIÊNG: Ô nhập tên khách
  final TextEditingController _phoneController = TextEditingController(); // 🌟 TÁCH RIÊNG: Ô nhập SĐT khách
  final TextEditingController _noteController = TextEditingController();

  // State Variables
  String _selectedType = 'Gặp mặt';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  List<Map<String, dynamic>> _facilities = [];
  int? _selectedCoSoId;
  String _selectedCoSoName = 'Đang tải...';

  List<Map<String, dynamic>> _rooms = []; // 🌟 THÊM MỚI: Danh sách phòng động
  int? _selectedRoomId;
  String _selectedRoomName = 'Chọn phòng';
  
  final String _reminder = '🔔 Nhắc trước 15 phút';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Tải danh sách cơ sở từ CSDL
  void _loadFacilities() async {
    try {
      final list = await CoSoService().getDashboard();
      if (list.isNotEmpty) {
        setState(() {
          _facilities = list.map((e) => {'id': e.maCoSo, 'name': e.tenCoSo}).toList();
          _selectedCoSoId = _facilities[0]['id'];
          _selectedCoSoName = _facilities[0]['name'];
        });
        _loadRoomsByCoSo(_selectedCoSoId!); // Tự động load phòng của cơ sở đầu tiên
      } else {
        _setFallbackFacilities();
      }
    } catch (e) {
      _setFallbackFacilities();
    }
  }

  void _setFallbackFacilities() {
    setState(() {
      _facilities = [
        {'id': 1, 'name': 'KTX Sinh Viên A'},
        {'id': 2, 'name': 'Nhà trọ Trung Tâm B'},
        {'id': 3, 'name': 'Chung cư mini C'},
      ];
      _selectedCoSoId = 1;
      _selectedCoSoName = 'KTX Sinh Viên A';
    });
    _loadRoomsByCoSo(_selectedCoSoId!);
  }

  // 🌟 THÊM MỚI: Load phòng động từ API dựa theo Cơ sở được chọn
  void _loadRoomsByCoSo(int coSoId) async {
    setState(() {
      _rooms = [];
      _selectedRoomId = null;
      _selectedRoomName = 'Đang tải phòng...';
    });
    try {
      final list = await PhongService().getByCoSo(coSoId);
      if (list.isNotEmpty) {
        setState(() {
          _rooms = list.map((e) => {'id': e.maPhong, 'name': 'Phòng ${e.soPhong}'}).toList();
          _selectedRoomId = _rooms[0]['id'];
          _selectedRoomName = _rooms[0]['name'];
        });
      } else {
        _setFallbackRooms();
      }
    } catch (e) {
      _setFallbackRooms();
    }
  }

  void _setFallbackRooms() {
    setState(() {
      _rooms = [
        {'id': 1, 'name': 'Phòng 101'},
        {'id': 2, 'name': 'Phòng 102'},
        {'id': 3, 'name': 'Phòng 103'},
      ];
      _selectedRoomId = 1;
      _selectedRoomName = 'Phòng 101';
    });
  }

  // Chọn ngày hẹn
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepPurple,
              onPrimary: Colors.white,
              onSurface: AppTheme.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Chọn giờ hẹn
  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepPurple,
              onPrimary: Colors.white,
              onSurface: AppTheme.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Submit gửi lịch lên Server
  void _handleSubmit() async {
    final title = _titleController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty || name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền Tiêu đề, Tên và SĐT khách!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng cụ thể cho lịch hẹn!'), backgroundColor: Colors.red),
      );
      return;
    }

    final DateTime appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        'MaPhong': _selectedRoomId,
        'HoTenKhach': name,
        'SDTKhach': phone,
        'ThoiGianHen': appointmentDateTime.toIso8601String(),
        'GhiChu': 'Tiêu đề: $title. Loại sự kiện: $_selectedType. Lưu ý: $note',
        'TrangThai': 'Chờ xác nhận',
      };

      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/dat-lich'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      //  Nếu mã phản hồi thành công (200, 201, 204) thì đóng trang luôn, không decode body rỗng
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo lịch hẹn thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Trả về true để màn hình danh sách Admin tự động F5 refresh
      } else {
        //  Kiểm tra xem body server trả về có rỗng không trước khi decode
        String errorMessage = 'Tạo lịch hẹn thất bại! (Mã lỗi: ${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            errorMessage = data['message'] ?? data['Message'] ?? errorMessage;
          } catch (_) {}
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối máy chủ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateString = "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";
    final String timeString = _selectedTime.format(context);

    return Scaffold(
      backgroundColor: AppTheme.bgSlate, 
      body: SingleChildScrollView(
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
                    _buildLabel('TIÊU ĐỀ & MỤC ĐÍCH'),
                    _buildTextField('Ví dụ: Xem phòng đăng ký ở ghép', _titleController),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildClickableTag('Thu tiền'),
                          const SizedBox(width: 8),
                          _buildClickableTag('Bảo trì'),
                          const SizedBox(width: 8),
                          _buildClickableTag('Gặp mặt'),
                          const SizedBox(width: 8),
                          _buildClickableTag('Khác'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('THỜI GIAN HẸN'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectField(dateString, Icons.calendar_month, () => _selectDate(context)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSelectField(timeString, Icons.access_time, () => _selectTime(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('HỌ TÊN KHÁCH HÀNG'), // 🌟 ĐÃ TÁCH RIÊNG
                    _buildTextField('Nhập họ tên khách (Ví dụ: Nguyễn Văn A)', _nameController),
                    const SizedBox(height: 24),
                    _buildLabel('SỐ ĐIỆN THOẠI LIÊN HỆ'), // 🌟 ĐÃ TÁCH RIÊNG
                    _buildTextField('Nhập số điện thoại khách', _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 24),
                    _buildLabel('CƠ SỞ TRỌ'),
                    _buildDropdownField(),
                    const SizedBox(height: 24),
                    _buildLabel('CHỌN PHÒNG CỤ THỂ'), // 🌟 THÊM DROPDOWN PHÒNG ĐỘNG
                    _buildRoomDropdownField(),
                    const SizedBox(height: 24),
                    _buildLabel('NHẮC NHỞ'),
                    _buildReminderBox(_reminder),
                    const SizedBox(height: 24),
                    _buildLabel('GHI CHÚ THÊM'),
                    _buildTextArea(_noteController),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
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
          const Text('Thêm lịch hẹn mới', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.deepPurple, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Nhập ghi chú thêm...',
          hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildClickableTag(String typeName) {
    bool isSelected = _selectedType == typeName;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = typeName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Text(typeName, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.orange, 
            fontSize: 12, 
            fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSelectField(String text, IconData icon, VoidCallback onTap) {
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
            Icon(icon, size: 16, color: AppTheme.deepPurple),
          ],
        ),
      ),
    );
  }

  // Dropdown Cơ sở
  Widget _buildDropdownField() {
    return PopupMenuButton<Map<String, dynamic>>(
      onSelected: (Map<String, dynamic> value) {
        setState(() {
          _selectedCoSoId = value['id'];
          _selectedCoSoName = value['name'];
        });
        _loadRoomsByCoSo(value['id']); // 🌟 Khi đổi cơ sở, tự load lại danh sách phòng tương ứng
      },
      itemBuilder: (BuildContext context) {
        return _facilities.map((Map<String, dynamic> f) {
          return PopupMenuItem<Map<String, dynamic>>(
            value: f,
            child: Text(f['name']),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedCoSoName,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 🌟 THÊM MỚI: UI Dropdown chọn phòng động
  Widget _buildRoomDropdownField() {
    return PopupMenuButton<Map<String, dynamic>>(
      onSelected: (Map<String, dynamic> value) {
        setState(() {
          _selectedRoomId = value['id'];
          _selectedRoomName = value['name'];
        });
      },
      itemBuilder: (BuildContext context) {
        return _rooms.map((Map<String, dynamic> r) {
          return PopupMenuItem<Map<String, dynamic>>(
            value: r,
            child: Text(r['name']),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.deepPurple.withOpacity(0.3)), // Viền nổi bật dễ thấy
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedRoomName,
                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.roofing_rounded, color: AppTheme.deepPurple, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.deepPurple, fontSize: 13)),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepPurple,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: _isLoading 
        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : const Text('Tạo lịch hẹn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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