import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/auth/auth_service.dart';

class AdAddHopDong extends StatefulWidget {
  const AdAddHopDong({super.key});

  @override
  State<AdAddHopDong> createState() => _AdAddHopDongState();
}

class _AdAddHopDongState extends State<AdAddHopDong> {
  // Bộ điều khiển thu thập dữ liệu nhập vào
  final TextEditingController _giaThueController = TextEditingController(text: "3500000");
  final TextEditingController _tienCocController = TextEditingController(text: "3500000");
  final TextEditingController _soDienController = TextEditingController(text: "1250");
  final TextEditingController _soNuocController = TextEditingController(text: "430");
  final TextEditingController _ghiChuController = TextEditingController();

  // Quản lý dữ liệu danh sách động lấy từ DB
  List<dynamic> _customers = [];
  List<dynamic> _rooms = [];
  
  int? _selectedMaKhach;
  int? _selectedMaPhong;
  int _selectedDurationMonths = 6; // Mặc định là chọn 6 tháng

  bool _isFetchingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // 🌐 1. TẢI DỮ LIỆU ĐỘNG (KHÁCH THUÊ & PHÒNG TRỐNG) TỪ BACKEND
  Future<void> _fetchInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maQuanLy = prefs.getInt('ma_quan_ly') ?? 1;

      final token = await AuthService().getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final customerRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/KhachThue'),
        headers: headers,
      );
      final roomRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Phong/trong?maQuanLy=$maQuanLy'),
        headers: headers,
      );

      List<dynamic> parsedCustomers = [];
      List<dynamic> parsedRooms = [];

      if (customerRes.statusCode == 200) {
        parsedCustomers = jsonDecode(customerRes.body);
      }
      if (roomRes.statusCode == 200) {
        parsedRooms = jsonDecode(roomRes.body);
      }

      setState(() {
        _customers = parsedCustomers;
        _rooms = parsedRooms;
        _isFetchingData = false;
      });
    } catch (e) {
      setState(() => _isFetchingData = false);
      debugPrint("Lỗi nạp dữ liệu ban đầu lập hợp đồng: $e");
    }
  }

  // 💾 2. LOGIC BẮN REQUEST TẠO HỢP ĐỒNG NHÁP LÊN BACKEND C#
  Future<void> _handleCreateContract() async {
    if (_selectedMaKhach == null) {
      _showSnackBar('Bạn chưa chọn khách hàng đứng tên thuê!', Colors.orange);
      return;
    }
    if (_selectedMaPhong == null) {
      _showSnackBar('Vui lòng chọn số phòng trọ để lập hợp đồng!', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    // Tính toán tự động Ngày bắt đầu và Ngày kết thúc chuẩn định dạng ISO String
    DateTime ngayBatDau = DateTime.now();
    DateTime ngayKetThuc = ngayBatDau.add(Duration(days: _selectedDurationMonths * 30));

    // Đóng gói JSON khít 100% với CreateHopDongDto phía C# Backend
    Map<String, dynamic> createDto = {
      "maPhong": _selectedMaPhong,
      "maKhach": _selectedMaKhach,
      "ngayBatDau": ngayBatDau.toIso8601String().substring(0, 10),
      "ngayKetThuc": ngayKetThuc.toIso8601String().substring(0, 10),
      "giaThue": double.tryParse(_giaThueController.text) ?? 3000000.0,
      "tienCoc": double.tryParse(_tienCocController.text) ?? 3000000.0,
      "soDienMoDau": double.tryParse(_soDienController.text) ?? 0.0,
      "soNuocMoDau": double.tryParse(_soNuocController.text) ?? 0.0,
      "ghiChu": _ghiChuController.text.trim(),
    };

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/create-nhap'),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(createDto),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSnackBar('Lập hợp đồng nháp thành công! Chờ khách thuê ký số.', Colors.green);
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception("Server trả lỗi: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Lập hợp đồng thất bại: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.deepPurple)),
      );
    }

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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('BÊN THUÊ & VỊ TRÍ PHÒNG'),
                    
                    // Tìm kiếm Chọn Khách Thuê Động
                    _buildCustomerSearch(),
                    const SizedBox(height: 12),
                    
                    // Dropdown Chọn Phòng Trống Động
                    _buildRoomDropdown(),
                    
                    const SizedBox(height: 24),
                    _buildLabel('THỜI HẠN CHU KỲ (THÁNG)'),
                    _buildDurationToggle(),
                    
                    const SizedBox(height: 24),
                    _buildLabel('CHI PHÍ THUÊ & ĐẶT CỌC BẢO LƯU'),
                    _buildInputField(_giaThueController, 'Giá thuê / tháng (VND)', isPurple: true, isNumber: true),
                    const SizedBox(height: 12),
                    _buildInputField(_tienCocController, 'Tiền cọc giữ chỗ an toàn', isRed: true, isNumber: true),
                    
                    const SizedBox(height: 24),
                    _buildLabel('CHỈ SỐ ĐIỆN / NƯỚC ĐẦU KỲ BÀN GIAO'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chỉ số ĐIỆN cũ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              _buildInputField(_soDienController, 'Nhập số điện (kWh)', isNumber: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chỉ số NƯỚC cũ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              _buildInputField(_soNuocController, 'Nhập số nước (m3)', isNumber: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    _buildLabel('GHI CHÚ / ĐIỀU KHOẢN RÀNG BUỘC RIÊNG'),
                    _buildTextArea(),
                    
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
          const Text('Tạo hợp đồng mới', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: AppTheme.deepPurple, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // 🛠️ NÂNG CẤP ĐỘNG: Chuyển khối nhập thành TextField thực tế
  Widget _buildInputField(TextEditingController controller, String hint, {bool isPurple = false, bool isRed = false, bool isNumber = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: isPurple 
            ? Border.all(color: AppTheme.deepPurple.withOpacity(0.5), width: 1.5) 
            : Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          fontSize: 14, 
          fontWeight: (isPurple || isRed) ? FontWeight.bold : FontWeight.normal,
          color: isRed ? Colors.red : const Color(0xFF1A0D2D)
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Tìm kiếm khách thuê từ danh sách DB
  Widget _buildCustomerSearch() {
    if (_selectedMaKhach != null) {
      final selectedCust = _customers.firstWhere(
        (c) => c['maKhach'] == _selectedMaKhach,
        orElse: () => null,
      );
      if (selectedCust != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.deepPurple.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: AppTheme.deepPurple, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCust['hoTen'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepPurple),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "SĐT: ${selectedCust['sdt'] ?? 'N/A'} | CCCD: ${selectedCust['cccd'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _selectedMaKhach = null;
                  });
                },
              )
            ],
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<Map<String, dynamic>>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Map<String, dynamic>>.empty();
              }
              return _customers.whereType<Map<String, dynamic>>().where((cust) {
                final name = (cust['hoTen'] ?? '').toString().toLowerCase();
                final phone = (cust['sdt'] ?? '').toString().toLowerCase();
                final query = textEditingValue.text.toLowerCase();
                return name.contains(query) || phone.contains(query);
              });
            },
            displayStringForOption: (Map<String, dynamic> option) => option['hoTen'] ?? '',
            onSelected: (Map<String, dynamic> selection) {
              setState(() {
                _selectedMaKhach = selection['maKhach'];
              });
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Nhập tên hoặc số điện thoại để tìm khách...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: AppTheme.deepPurple),
                  border: InputBorder.none,
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: constraints.maxWidth,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            option['hoTen'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            "SĐT: ${option['sdt'] ?? 'N/A'} - CCCD: ${option['cccd'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dropdown chọn Phòng trống lấy từ DB
  Widget _buildRoomDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMaPhong,
          hint: const Text('Chọn phòng trống phân hệ *', style: TextStyle(fontSize: 14, color: Colors.grey)),
          isExpanded: true,
          items: _rooms.map((room) {
            return DropdownMenuItem<int>(
              value: room['maPhong'],
              child: Text("Phòng ${room['soPhong']} - ${room['tenCoSo']}", style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedMaPhong = val;
              // Nếu admin chọn phòng trọ nào, tự động điền giá gốc của phòng đó lên TextField mẫu của ông
              final selectedRoom = _rooms.firstWhere((r) => r['maPhong'] == val);
              _giaThueController.text = selectedRoom['giaThue'].toString();
              _tienCocController.text = selectedRoom['giaThue'].toString(); // Cọc mặc định bằng 1 tháng tiền phòng
            });
          },
        ),
      ),
    );
  }

  Widget _buildDurationToggle() {
    return Row(
      children: [
        _toggleItem('6 tháng', 6),
        const SizedBox(width: 8),
        _toggleItem('12 tháng', 12),
        const SizedBox(width: 8),
        _toggleItem('Khác (3 th)', 3),
      ],
    );
  }

  Widget _toggleItem(String label, int months) {
    bool isSelected = _selectedDurationMonths == months;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDurationMonths = months),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.deepPurple : const Color(0xFFF3F0F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppTheme.deepPurple, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }


  Widget _buildTextArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        controller: _ghiChuController,
        maxLines: 3,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Nhập điều khoản bổ sung đặc biệt cho khách thuê...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleCreateContract,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepPurple,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: _isSubmitting 
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text('Ký & Tạo hợp đồng nháp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.deepPurple,
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Hóa đơn'),
        BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Hợp đồng'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
    );
  }
}