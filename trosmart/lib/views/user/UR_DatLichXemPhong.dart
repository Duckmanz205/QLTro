import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart'; //
import '../../views/user/UR_HoanTatDatLich.dart';
import '../../logic/auth/auth_service.dart';

class UrDatLichXemPhong extends StatefulWidget {
  final int? maPhong; // Nhận từ trang Chi tiết phòng xem
  final int maKhach; // Nhận từ tài khoản đang đăng nhập (Ví dụ: khach1 là 1)
  final String soPhong; // Tên hiển thị phòng (Ví dụ: "A101")
  final String tenCoSo; // Tên cơ sở trọ (Ví dụ: "KTX Sinh Viên A")

  const UrDatLichXemPhong({
    super.key,
    this.maPhong,
    required this.maKhach,
    this.soPhong = "Chưa chọn",
    this.tenCoSo = "Chưa rõ cơ sở",
  });

  @override
  State<UrDatLichXemPhong> createState() => _UrDatLichXemPhongState();
}

class _UrDatLichXemPhongState extends State<UrDatLichXemPhong> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  List<dynamic> _appointments = [];
  bool _isLoadingForm = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _fetchThongTinKhach();
    _fetchLichSuHen();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  //  1. TỰ ĐỘNG ĐIỀN THÔNG TIN TÀI KHOẢN TỪ DATABASE SQL SERVER
  Future<void> _fetchThongTinKhach() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/KhachThue/${widget.maKhach}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nameController.text = data['hoTen'] ?? data['HoTen'] ?? "";
            _phoneController.text = data['sdt'] ?? data['Sdt'] ?? "";
          });
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        String? savedName = prefs.getString('hoTen') ?? prefs.getString('fullName');
        String? savedPhone = prefs.getString('sdt') ?? prefs.getString('phoneNumber');

        if (savedName != null && savedPhone != null) {
          if (mounted) {
            setState(() {
              _nameController.text = savedName;
              _phoneController.text = savedPhone;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi xử lý luồng profile linh hoạt: $e");
    }
  }

  //  2. LẤY LỊCH SỬ HẸN CỦA CHÍNH KHÁCH NÀY
  Future<void> _fetchLichSuHen() async {
    try {
      setState(() => _isLoadingHistory = true);
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/lich-su/${widget.maKhach}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _appointments = jsonDecode(response.body);
          _isLoadingHistory = false;
        });
      } else {
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      setState(() => _isLoadingHistory = false);
      debugPrint("Lỗi không lấy được lịch sử đặt lịch: $e");
    }
  }

  //  3. XỬ LÝ GỬI YÊU CẦU ĐẶT LỊCH LÊN BACKEND C#
  Future<void> _handleConfirmBooking() async {
    if (widget.maPhong == null || widget.maPhong == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một phòng cụ thể để đặt lịch!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoadingForm = true);

    final DateTime targetDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final Map<String, dynamic> requestBody = {
      "maKhach": widget.maKhach,
      "hoTenKhach": _nameController.text.trim(),
      "sdtKhach": _phoneController.text.trim(),
      "maPhong": widget.maPhong,
      "thoiGianHen": targetDateTime.toIso8601String(),
      "ghiChu": _noteController.text.trim(),
    };

    try {
      // Gọi lên Endpoint /dat-lich đã cấu hình chuẩn dưới API C#
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/LichHen/dat-lich'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _noteController.clear();
        _fetchLichSuHen(); // Làm mới danh sách phía dưới

        if (mounted) {
          // Chuyển sang màn hình hoàn tất và truyền tham số động sang để hiển thị tóm tắt
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UrHoanTatDatLich(
                maKhach: widget.maKhach,
                soPhong: widget.soPhong,
                tenCoSo: widget.tenCoSo,
                thoiGianHenFormatted:
                    "${_selectedTime.format(context)} - ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
              ),
            ),
          ).then(
            (_) => _fetchLichSuHen(),
          ); // Tự động làm mới dữ liệu lịch sử khi quay về
        }
      } else {
        throw Exception('Server phản hồi mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt lịch thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingForm = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case "Chờ xác nhận":
        return const Color(0xFFD97706);
      case "Đã xác nhận":
        return const Color(0xFF2563EB);
      case "Đã xem":
        return const Color(0xFF059669);
      case "Đã hủy":
        return const Color(0xFF64748B);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.trim()) {
      case "Chờ xác nhận":
        return const Color(0xFFFEF3C7);
      case "Đã xác nhận":
        return const Color(0xFFDBEAFE);
      case "Đã xem":
        return const Color(0xFFD1FAE5);
      case "Đã hủy":
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        Icons.calendar_today_outlined,
                        'Đặt lịch mới',
                      ),
                      const SizedBox(height: 16),
                      _buildRoomPreviewCard(),
                      const SizedBox(height: 20),
                      _buildInputField(
                        'Họ và tên',
                        Icons.person_outline,
                        'Nhập họ tên của bạn',
                        controller: _nameController,
                      ),
                      _buildInputField(
                        'Số điện thoại',
                        Icons.phone_outlined,
                        '090 123 4567',
                        controller: _phoneController,
                        isPhone: true,
                      ),
                      _buildClickableField(
                        'Ngày xem',
                        Icons.calendar_month_outlined,
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        onTap: _pickDate,
                      ),
                      _buildClickableField(
                        'Khung giờ',
                        Icons.access_time_outlined,
                        _selectedTime.format(context),
                        isDropdown: true,
                        onTap: _pickTime,
                      ),
                      _buildNoteField(),
                      const SizedBox(height: 24),
                      _isLoadingForm
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.deepPurple,
                                ),
                              ),
                            )
                          : _buildConfirmButton(context),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        Icons.list_alt_outlined,
                        'Lịch hẹn của bạn',
                        badge: _appointments.length.toString(),
                      ),
                      const SizedBox(height: 16),
                      _isLoadingHistory
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.deepPurple,
                                ),
                              ),
                            )
                          : _appointments.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Bạn chưa có lịch hẹn nào dưới DB cả.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _appointments.length,
                              itemBuilder: (context, index) {
                                final item = _appointments[index];
                                DateTime thoiGian = DateTime.parse(
                                  item['thoiGianHen'] ?? item['ThoiGianHen'],
                                );
                                String rawStatus =
                                    (item['trangThai'] ??
                                            item['TrangThai'] ??
                                            "Chờ xác nhận")
                                        .toString();
                                bool isCanceled = rawStatus == "Đã hủy";

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  key: ValueKey(
                                    item['maLichHen'] ?? item['MaLichHen'],
                                  ),
                                  child: _buildAppointmentCard(
                                    title:
                                        'Phòng ${item['soPhong'] ?? item['SoPhong'] ?? 'Trống'}',
                                    subtitle:
                                        item['tenCoSo'] ??
                                        item['TenCoSo'] ??
                                        'Chưa rõ cơ sở',
                                    date: DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(thoiGian),
                                    time: DateFormat('HH:mm').format(thoiGian),
                                    status: rawStatus,
                                    statusColor: _getStatusColor(rawStatus),
                                    statusBg: _getStatusBgColor(rawStatus),
                                    hasCancel:
                                        rawStatus == "Chờ xác nhận" ||
                                        rawStatus == "Đã xác nhận",
                                    opacity: isCanceled ? 0.6 : 1.0,
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🌟 GIỮ NGUYÊN VẸN 100% GIAO DIỆN UI ĐẸP ĐẼ BAN ĐẦU CỦA ÔNG 🌟 ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Đặt lịch xem phòng',
                style: AppTheme.titleMd.copyWith(
                  color: AppTheme.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sắp xếp thời gian đến xem trực tiếp',
            style: AppTheme.bodySm.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, {String? badge}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.deepPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: AppTheme.bodySm.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildRoomPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.bgGray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bed_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phòng số: ${widget.soPhong}',
                style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.tenCoSo,
                style: AppTheme.bodySm.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    String hint, {
    required TextEditingController controller,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodySm.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: AppTheme.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMd.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.bgGray200),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppTheme.deepPurple),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Trường này không được bỏ trống nha!'
              : null,
        ),
      ],
    );
  }

  Widget _buildClickableField(
    String label,
    IconData icon,
    String value, {
    bool isDropdown = false,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodySm.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.bgGray200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTheme.bodyMd.copyWith(color: Colors.black),
                ),
                if (isDropdown)
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Ghi chú thêm',
              style: AppTheme.bodySm.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          style: AppTheme.bodySm,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Tôi muốn xem thêm phòng ở tầng cao...',
            hintStyle: AppTheme.bodySm.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.bgGray200),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppTheme.deepPurple),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _handleConfirmBooking,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Xác nhận đặt lịch',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String title,
    required String subtitle,
    required String date,
    String? time,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required bool hasCancel,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.bodySm.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 13,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(date, style: AppTheme.bodySm),
                if (time != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(time, style: AppTheme.bodySm),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
