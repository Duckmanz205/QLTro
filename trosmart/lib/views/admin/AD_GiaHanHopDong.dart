import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';

class AdGiaHanHopDong extends StatefulWidget {
  final int maHopDong; // Nhận ID hợp đồng từ trang chi tiết sang

  const AdGiaHanHopDong({super.key, required this.maHopDong});

  @override
  State<AdGiaHanHopDong> createState() => _AdGiaHanHopDongState();
}

class _AdGiaHanHopDongState extends State<AdGiaHanHopDong> {
  // Bộ điều khiển thu thập dữ liệu nhập vào
  final TextEditingController _giaThueMoiController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  Map<String, dynamic>? _oldContractData;
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  // Biến quản lý thời gian gia hạn thực tế
  DateTime _ngayBatDauMoi = DateTime.now();
  DateTime _ngayKetThucMoi = DateTime.now().add(const Duration(days: 180)); // Mặc định +6 tháng
  int _selectedDurationMonths = 6;

  @override
  void initState() {
    super.initState();
    _fetchCurrentContractInfo();
  }

  // 🌐 1. TẢI THÔNG TIN HỢP ĐỒNG HIỆN TẠI ĐỂ HIỂN THỊ LÊN KHUNG KHÓA
  Future<void> _fetchCurrentContractInfo() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _oldContractData = data;
          _giaThueMoiController.text = data['giaThue']?.toString() ?? "3500000";
          
          if (data['ngayKetThuc'] != null) {
            _ngayBatDauMoi = DateTime.parse(data['ngayKetThuc']);
            _ngayKetThucMoi = _ngayBatDauMoi.add(Duration(days: _selectedDurationMonths * 30));
          }
          _isLoadingData = false;
        });
      } else {
        throw Exception("Không thể load thông tin hợp đồng gốc.");
      }
    } catch (e) {
      setState(() => _isLoadingData = false);
      debugPrint("Lỗi nạp hợp đồng gia hạn: $e");
    }
  }

  // 📅 2. BỘ CHỌN NGÀY THÁNG BẰNG DATE PICKER THỰC TẾ
  Future<void> _selectNewEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngayKetThucMoi,
      firstDate: _ngayBatDauMoi.add(const Duration(days: 30)), 
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.deepPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _ngayKetThucMoi) {
      setState(() {
        _ngayKetThucMoi = picked;
        int days = _ngayKetThucMoi.difference(_ngayBatDauMoi).inDays;
        _selectedDurationMonths = (days / 30).round();
      });
    }
  }

  // 💾 3. LOGIC GỬI YÊU CẦU GIA HẠN XUỐNG API ENDPOINT CHUẨN C#
  Future<void> _submitGiaHanHopDong() async {
    setState(() => _isSubmitting = true);

    Map<String, dynamic> giaHanDto = {
      "ngayBatDauMoi": _ngayBatDauMoi.toIso8601String().substring(0, 10), 
      "ngayKetThucMoi": _ngayKetThucMoi.toIso8601String().substring(0, 10),
      "giaThueMoi": double.tryParse(_giaThueMoiController.text) ?? 3500000.0,
      "ghiChu": _ghiChuController.text.trim(),
    };

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}/gia-han'),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(giaHanDto),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chốt phụ lục gia hạn hợp đồng thành công!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception("Server trả lỗi cổng: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gia hạn thất bại: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String _formatCurrency(dynamic number) {
    if (number == null) return "0 đ";
    final format = NumberFormat("#,##0", "vi_VN");
    return "${format.format(number)} đ";
  }

  String _calculateTotalSummaryAmount() {
    double giaMoi = double.tryParse(_giaThueMoiController.text) ?? 0.0;
    double cacCu = double.tryParse(_oldContractData?['tienCoc']?.toString() ?? "0") ?? 0.0;
    return _formatCurrency(giaMoi + cacCu);
  }

  // ─── CÁC HÀM UI PHỤ TRỢ (ĐÃ KHAI BÁO ĐẦY ĐỦ BÊN TRONG STATE CLASS) ───
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.deepPurple, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDisabledField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStaticField(String label, String value, {bool isRed = false, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: (isRed || isBold) ? FontWeight.bold : FontWeight.normal, color: isRed ? Colors.red : const Color(0xFF1A0D2D))),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String value, {bool isDatePicker = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDatePicker ? Colors.white : const Color(0xFFF9FAFB), 
            borderRadius: BorderRadius.circular(12), 
            border: isDatePicker ? Border.all(color: AppTheme.deepPurple, width: 1.2) : Border.all(color: const Color(0xFFF3F4F6))
          ),
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.deepPurple)),
        ),
      ],
    );
  }

  Widget _buildMainPriceField(TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepPurple.withOpacity(0.5), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}), 
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A0D2D)),
        decoration: const InputDecoration(
          labelText: "Nhập giá thuê mới chu kỳ kế tiếp (VND) *",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildServiceInfo(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3F0F8), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: AppTheme.deepPurple, fontSize: 12)),
    );
  }

  Widget _buildDashedUploadBox(String label) {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Center(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))),
    );
  }

  Widget _buildTextArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.deepPurple.withOpacity(0.3))),
      child: TextField(
        controller: _ghiChuController,
        maxLines: 3,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          hintText: "Nhập lý do gia hạn hoặc các cam kết điều khoản phòng trọ mới...",
          hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.deepPurple.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TỔNG DỰ KIẾN KHI BẮT ĐẦU CHU KỲ GIA HẠN:', style: TextStyle(color: AppTheme.deepPurple, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_calculateTotalSummaryAmount(), style: const TextStyle(color: AppTheme.deepPurple, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitGiaHanHopDong,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepPurple,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('XÁC NHẬN GIA HẠN (CHỐT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFA161D2), Color(0xFF64417F)]),
        ),
      ),
      leading: const Icon(Icons.menu, color: Colors.white),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.home_work_rounded, color: Color(0xFF2DDCB1), size: 24),
          SizedBox(width: 8),
          Text('TroSmart', style: TextStyle(color: Color(0xFF2DDCB1), fontWeight: FontWeight.bold, fontSize: 18)),
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
              child: const Text('Chủ trọ', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gia hạn hợp đồng thuê', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Tạo phụ lục lịch sử gia hạn cho hợp đồng #00${widget.maHopDong}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
            ],
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: AppTheme.bgSlate,
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
                    _buildLabel('ĐỐI TƯỢNG KÝ KẾT (KHÓA CỨNG)'),
                    _buildDisabledField('Khách thuê: ${_oldContractData!['tenKhach']}'),
                    const SizedBox(height: 12),
                    _buildDisabledField('Phòng: ${_oldContractData!['soPhong']} - ${_oldContractData!['tenCoSo']}'),
                    
                    const SizedBox(height: 24),
                    _buildLabel('THỜI HẠN GIA HẠN CHU KỲ MỚI'),
                    Row(
                      children: [
                        Expanded(child: _buildStaticField('Ngày bắt đầu mới', _formatDate(_ngayBatDauMoi))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectNewEndDate(context),
                            child: _buildInputField('Ngày kết thúc mới 📅', _formatDate(_ngayKetThucMoi), isDatePicker: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('⏱ Tổng thời gian gia hạn thêm tương đối: $_selectedDurationMonths tháng', style: const TextStyle(color: AppTheme.deepPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                    
                    const SizedBox(height: 24),
                    _buildLabel('ĐIỀU CHỈNH CHI PHÍ THUÊ MỚI'),
                    _buildMainPriceField(_giaThueMoiController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStaticField('Cọc phòng cũ (Bảo lưu)', _formatCurrency(_oldContractData!['tienCoc']), isRed: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStaticField('Cọc thiết bị gốc', '1.000.000 đ', isBold: true)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    _buildLabel('ĐỊNH MỨC DỊCH VỤ CƠ SỞ (CỐ ĐỊNH)'),
                    _buildServiceInfo('⚡ Điện: 3.500đ/kWh | 💧 Nước: 20k/m³'),
                    const SizedBox(height: 8),
                    _buildServiceInfo('🌐 Wifi: 50k/phòng | 🗑 Rác: 30k/người'),
                    
                    const SizedBox(height: 24),
                    _buildLabel('HỒ SƠ MINH CHỨNG'),
                    Row(
                      children: [
                        Expanded(child: _buildDashedUploadBox('Ảnh CCCD gốc đã duyệt ✓')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDashedUploadBox('Phụ lục gia hạn mới')),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    _buildLabel('ĐIỀU KHOẢN BỔ SUNG GIA HẠN'),
                    _buildTextArea(),
                    
                    const SizedBox(height: 32),
                    _buildTotalSummary(),
                    const SizedBox(height: 24),
                    _buildNextButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}