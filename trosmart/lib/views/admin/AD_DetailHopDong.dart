import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:trosmart/views/admin/AD_EditHopDong.dart';
import 'package:trosmart/views/admin/AD_GiaHanHopDong.dart';
import '../../shared/app_theme.dart';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';

class AdDetailHopDong extends StatefulWidget {
  final int maHopDong;
  const AdDetailHopDong({super.key, required this.maHopDong});

  @override
  State<AdDetailHopDong> createState() => _AdDetailHopDongState();
}

class _AdDetailHopDongState extends State<AdDetailHopDong> {
  bool _isLoading = true;
  Map<String, dynamic>? _contractData;

  @override
  void initState() {
    super.initState();
    _fetchContractDetail();
  }

  Future<void> _fetchContractDetail() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        setState(() {
          _contractData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception("Lỗi tải chi tiết");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  //  NÚT SỬA BÊN TRONG TRANG CHI TIẾT
  Future<void> _handleEdit() async {
    if (_contractData?['trangThai'] == 'Đang hiệu lực' ||
        _contractData?['trangThai'] == 'Đã ký') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hợp đồng đã ký kết, không thể sửa!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool? isEdited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdEditHopDong(maHopDong: widget.maHopDong),
      ),
    );

    if (isEdited == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isLoading = true);
      _fetchContractDetail(); // Load lại dữ liệu mới nhất
    }
  }

  // NÚT GIA HẠN HỢP ĐỒNG
  Future<void> _handleGiaHan() async {
    bool? isExtended = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdGiaHanHopDong(maHopDong: widget.maHopDong),
      ),
    );

    if (isExtended == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gia hạn hợp đồng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isLoading = true);
      _fetchContractDetail(); // Load lại dữ liệu mới nhất
    }
  }

  Future<void> _handleTuChoiGiaHan() async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận từ chối'),
            content: const Text(
              'Bạn có chắc chắn muốn từ chối yêu cầu gia hạn hợp đồng này?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Từ chối',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}/tu-choi-gia-han',
        ),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối yêu cầu gia hạn!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isLoading = true);
          _fetchContractDetail();
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Đang hiệu lực":
      case "Đã ký":
        return Colors.green;
      case "Chờ kết thúc sớm":
        return const Color(0xFFDC2626);
      case "Đã kết thúc sớm":
        return const Color(0xFF9CA3AF);
      case "Chờ gia hạn":
        return const Color(0xFFF97316);
      case "Chờ khách ký":
      case "Chờ ký":
        return const Color(0xFF60A5FA);
      case "Đã hết hạn":
      case "Đã hủy":
        return const Color(0xFFF87171);
      default:
        return Colors.orange;
    }
  }

  Future<void> _handleTuChoiKetThucSom() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text(
          'Bạn có chắc chắn muốn từ chối yêu cầu kết thúc sớm hợp đồng này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Từ chối',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}/tu-choi-ket-thuc-som',
        ),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối yêu cầu kết thúc sớm!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isLoading = true);
          _fetchContractDetail();
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDuyetKetThucSom() async {
    DateTime selectedDate = DateTime.now();
    if (_contractData?['ngayMuonKetThuc'] != null) {
      try {
        selectedDate = DateTime.parse(_contractData!['ngayMuonKetThuc'].toString());
      } catch (_) {}
    }
    
    final noteController = TextEditingController();

    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Duyệt kết thúc sớm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn ngày kết thúc hợp đồng thực tế và nhập ghi chú nếu có.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ngày kết thúc thực tế *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDlgState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ghi chú (Tùy chọn)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Nhập ghi chú...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Xác nhận duyệt',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final token = await AuthService().getToken();
      final body = {
        'ngayKetThucThucTe': selectedDate.toIso8601String().substring(0, 10),
        'ghiChu': noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      };
      
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}/duyet-ket-thuc-som',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã duyệt yêu cầu kết thúc sớm!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isLoading = true);
          _fetchContractDetail();
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // KIỂM TRA HỢP ĐỒNG CÓ PHẢI LÀ SẮP HẾT HOẶC ĐÃ HẾT KHÔNG
  bool _isContractExpiredOrNearExpiry() {
    if (_contractData?['ngayKetThuc'] == null) return false;

    try {
      DateTime endDate = DateTime.parse(
        _contractData!['ngayKetThuc'].toString(),
      );
      DateTime today = DateTime.now();
      Duration difference = endDate.difference(today);

      // Nếu hợp đồng đã hết (hôm nay sau ngày kết thúc) hoặc sắp hết (trong 30 ngày)
      return difference.inDays <= 30; // 30 ngày là "sắp hết"
    } catch (e) {
      return false;
    }
  }

  // LẤY THÔNG TIN TRẠNG THÁI HỢP ĐỒNG CHO NÚT GIA HẠN
  String _getGiaHanButtonStatus() {
    if (_contractData?['ngayKetThuc'] == null) {
      return 'Không có dữ liệu ngày hết hạn';
    }

    try {
      DateTime endDate = DateTime.parse(
        _contractData!['ngayKetThuc'].toString(),
      );
      DateTime today = DateTime.now();
      Duration difference = endDate.difference(today);

      if (difference.inDays <= 0) {
        return 'Hợp đồng đã hết hạn';
      } else if (difference.inDays <= 30) {
        return 'Hợp đồng sắp hết hạn (${difference.inDays} ngày)';
      } else {
        return 'Hợp đồng còn ${difference.inDays} ngày';
      }
    } catch (e) {
      return 'Không thể xác định trạng thái';
    }
  }

  Future<void> _handleDelete() async {
    //  CHẶN NGAY TỪ ĐẦU NẾU ĐANG CÓ HIỆU LỰC
    if (_contractData?['trangThai'] == 'Đang hiệu lực' ||
        _contractData?['trangThai'] == 'Đã ký') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hợp đồng đang có hiệu lực pháp lý, tuyệt đối không được xóa!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa hợp đồng này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/${widget.maHopDong}'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa hợp đồng'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Pop về danh sách và báo hiệu reload
        }
      } else {
        throw Exception("Lỗi khóa ngoại");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return "N/A";
    }
  }

  String _formatCurrency(dynamic number) {
    if (number == null) return "0đ";
    return "${NumberFormat("#,##0", "vi_VN").format(number)}đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.deepPurple,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'HD-2026-00${widget.maHopDong}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.deepPurple),
            )
          : _contractData == null
          ? const Center(child: Text("Không tìm thấy dữ liệu hợp đồng"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THÔNG TIN TRẠNG THÁI
                  _buildSectionTitle('Trạng Thái'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      _contractData!['trangThai'] ?? "N/A",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getStatusColor(_contractData!['trangThai']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // THÔNG TIN KẾT THÚC SỚM (NẾU CÓ)
                  if (_contractData!['lyDoKetThucSom'] != null ||
                      _contractData!['ngayMuonKetThuc'] != null) ...[
                    _buildSectionTitle('Thông Tin Kết Thúc Sớm'),
                    _buildInfoCard([
                      if (_contractData!['ngayMuonKetThuc'] != null)
                        _buildInfoRow(
                          'Ngày muốn kết thúc:',
                          _formatDate(_contractData!['ngayMuonKetThuc']),
                        ),
                      if (_contractData!['lyDoKetThucSom'] != null)
                        _buildInfoRow(
                          'Lý do kết thúc:',
                          _contractData!['lyDoKetThucSom'] ?? "N/A",
                        ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // THÔNG TIN KHÁCH & PHÒNG
                  _buildSectionTitle('Bên Thuê (Khách)'),
                  _buildInfoCard([
                    _buildInfoRow(
                      'Họ tên:',
                      _contractData!['tenKhach'] ?? "N/A",
                    ),
                    _buildInfoRow('SĐT:', _contractData!['sdt'] ?? "N/A"),
                    _buildInfoRow('CCCD:', _contractData!['cccd'] ?? "N/A"),
                    const Divider(),
                    _buildInfoRow(
                      'Phòng:',
                      'Phòng ${_contractData!['soPhong']} - ${_contractData!['tenCoSo']}',
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // THÔNG TIN TÀI CHÍNH & THỜI HẠN
                  _buildSectionTitle('Điều Khoản Cơ Bản'),
                  _buildInfoCard([
                    _buildInfoRow(
                      'Giá thuê:',
                      _formatCurrency(_contractData!['giaThue']),
                    ),
                    _buildInfoRow(
                      'Tiền cọc:',
                      _formatCurrency(_contractData!['tienCoc']),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Ngày bắt đầu:',
                      _formatDate(_contractData!['ngayBatDau']),
                    ),
                    _buildInfoRow(
                      'Ngày kết thúc:',
                      _formatDate(_contractData!['ngayKetThuc']),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // MINH CHỨNG CHỮ KÝ (NẾU CÓ)
                  if (_contractData!['urlChuKySupabase'] != null &&
                      _contractData!['urlChuKySupabase']
                          .toString()
                          .isNotEmpty) ...[
                    _buildSectionTitle('Minh Chứng Ký Số'),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _contractData!['urlChuKySupabase'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Text("Lỗi tải ảnh minh chứng"),
                              ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  // THANH CÔNG CỤ XỬ LÝ (SỬA / GIA HẠN / XÓA)
                  if (_contractData!['trangThai'] == 'Chờ gia hạn') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleTuChoiGiaHan,
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              'Từ chối',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleGiaHan,
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              'Chấp nhận',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_contractData!['trangThai'] == 'Chờ kết thúc sớm') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleTuChoiKetThucSom,
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              'Từ chối',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleDuyetKetThucSom,
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              'Duyệt kết thúc',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // NÚT GIA HẠN (LUÔN HIỂN THỊ, NHƯNG DISABLE NẾU KHÔNG PHẢI HỢP ĐỒNG SẮP HẾT HOẶC ĐÃ HẾT)
                    ElevatedButton(
                      onPressed: _isContractExpiredOrNearExpiry()
                          ? _handleGiaHan
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isContractExpiredOrNearExpiry()
                            ? Colors.blue
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 0),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        _getGiaHanButtonStatus(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isContractExpiredOrNearExpiry()
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // NÚT EDIT VÀ XÓA
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleDelete,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Xóa bỏ',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleEdit,
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Sửa HĐ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
