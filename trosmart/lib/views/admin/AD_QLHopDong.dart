import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:trosmart/views/admin/AD_AddHopDong.dart';
import 'package:trosmart/views/admin/AD_DetailHopDong.dart';
import 'package:trosmart/views/admin/AD_EditHopDong.dart';
import '../../shared/app_theme.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Đọc thư mục lưu trữ điện thoại
import 'package:open_filex/open_filex.dart';       // Tự động mở file PDF sau khi tải xong
import '../../shared/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/auth/auth_service.dart';

class AdQLHopDong extends StatefulWidget {
  const AdQLHopDong({super.key});

  @override
  State<AdQLHopDong> createState() => _AdQLHopDongState();
}

class _AdQLHopDongState extends State<AdQLHopDong> {
  List<dynamic> _allContracts = [];      
  List<dynamic> _filteredContracts = []; 
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'Tất cả trạng thái';

  int _countHieuLuc = 0, _countSapHetHan = 0, _countChoKy = 0, _countHetHan = 0, _countChoKetThucSom = 0;

  @override
  void initState() {
    super.initState();
    _fetchContractsAdmin();
  }

  Future<void> _fetchContractsAdmin() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final maQuanLy = prefs.getInt('ma_quan_ly') ?? 1;

      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/HopDong?maQuanLy=$maQuanLy'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _allContracts = data;
            _filteredContracts = data;
            _calculateStatusStats(); 
            _applySearchAndFilter(); 
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Server phản hồi mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Lỗi tải danh sách hợp đồng: $e");
    }
  }

  void _calculateStatusStats() {
    _countHieuLuc = _countSapHetHan = _countChoKy = _countHetHan = _countChoKetThucSom = 0;
    for (var contract in _allContracts) {
      String status = (contract['trangThai'] ?? "").toString().trim();
      if (status == "Đang hiệu lực" || status == "Đã ký") _countHieuLuc++;
      else if (status == "Chờ khách ký" || status == "Chờ ký") _countChoKy++;
      else if (status == "Sắp hết hạn") _countSapHetHan++;
      else if (status == "Đã hết hạn") _countHetHan++;
      else if (status == "Chờ kết thúc sớm") _countChoKetThucSom++;
    }
  }

  void _applySearchAndFilter() {
    String query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredContracts = _allContracts.where((contract) {
        String status = (contract['trangThai'] ?? "").toString().trim();
        bool matchesStatus = _selectedStatusFilter == 'Tất cả trạng thái' ||
            (status == _selectedStatusFilter) ||
            (_selectedStatusFilter == "Chờ ký" && status == "Chờ khách ký");

        String name = (contract['tenKhach'] ?? "").toString().toLowerCase();
        String room = (contract['soPhong'] ?? "").toString().toLowerCase();
        String coso = (contract['tenCoSo'] ?? "").toString().toLowerCase();
        String id = "hd-2026-00${contract['maHopDong']}".toLowerCase();

        bool matchesSearch = name.contains(query) || room.contains(query) || coso.contains(query) || id.contains(query);
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Future<void> _handleEditContract(int maHopDong) async {
    bool? isEdited = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdEditHopDong(maHopDong: maHopDong)),
    );
    if (isEdited == true) {
      _showSnackBar('Cập nhật hợp đồng thành công!', Colors.green);
      _fetchContractsAdmin(); 
    }
  }

  Future<void> _handleDeleteContract(int maHopDong, String tenKhach) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Chắc chắn xóa hợp đồng của "$tenKhach"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/$maHopDong'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar('Đoạn tuyệt hợp đồng thành công!', Colors.green);
        _fetchContractsAdmin(); 
      } else {
        final errorMsg = response.body.isNotEmpty ? response.body : "Ràng buộc dữ liệu không thể xóa!";
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Lỗi: $e', Colors.red);
    }
  }
  Future<void> _downloadAndOpenContractPdf(int maHopDong, String tenKhach) async {
    _showSnackBar('Đang khởi tạo tiến trình xuất file PDF...', AppTheme.deepPurple);
    
    try {
      // Gọi lên API xuất file PDF của nhóm ông dưới Backend C#
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/$maHopDong/export-pdf'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.statusCode == 200) {
        // 1. Tìm đường dẫn thư mục lưu trữ an toàn trên điện thoại (Thư mục Downloads/Documents)
        final directory = await getApplicationDocumentsDirectory();
        // Định danh tên file sạch theo Mã HD và tên người thuê phòng
        final String slugName = tenKhach.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
        final filePath = '${directory.path}/HopDong_HD2026_${maHopDong}_$slugName.pdf';
        
        // 2. Ghi mớ dữ liệu dạng Bytes nhận từ C# xuống file thực tế trong máy
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        _showSnackBar('Đã tải thành công file hợp đồng về máy!', Colors.green);

        // 3. LỆNH ĐẮT GIÁ: Tự động gọi hệ điều hành mở phốc file PDF lên xem ngay lập tức
        await OpenFilex.open(filePath);
      } else {
        _showSnackBar('Backend chưa hỗ trợ xuất mẫu PDF cho hợp đồng này! (Mã lỗi: ${response.statusCode})', Colors.orange);
      }
    } catch (e) {
      debugPrint("Lỗi tải PDF: $e");
      _showSnackBar('Thiết bị thiếu ứng dụng đọc file PDF hoặc lỗi kết nối!', Colors.red);
    }
  }
  String _formatDateRange(String? start, String? end) {
    if (start == null || end == null) return "N/A";
    try {
      DateTime s = DateTime.parse(start); DateTime e = DateTime.parse(end);
      return "${s.day.toString().padLeft(2, '0')}/${s.month.toString().padLeft(2, '0')}/${s.year} - ${e.day.toString().padLeft(2, '0')}/${e.month.toString().padLeft(2, '0')}/${e.year}";
    } catch (_) { return "N/A"; }
  }

  String _formatCurrency(dynamic number) {
    if (number == null) return "0đ";
    return "${NumberFormat("#,##0", "vi_VN").format(number)}đ";
  }

  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case "Đang hiệu lực": case "Đã ký": return const Color(0xFF2DDCB1); 
      case "Sắp hết hạn": return const Color(0xFFFBBF24); 
      case "Chờ khách ký": case "Chờ ký": return const Color(0xFF60A5FA); 
      case "Chờ gia hạn": return const Color(0xFFF97316);
      case "Chờ kết thúc sớm": return const Color(0xFFDC2626);
      case "Đã kết thúc sớm": return const Color(0xFF9CA3AF);
      default: return const Color(0xFFF87171); 
    }
  }

  void _showSnackBar(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchContractsAdmin,
        color: AppTheme.deepPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStatusGrid(),
                    const SizedBox(height: 24),
                    _buildSearchAndFilter(),
                    const SizedBox(height: 24),
                    _buildListHeader(),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: AppTheme.deepPurple)))
                        : _filteredContracts.isEmpty
                            ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("Không tìm thấy hợp đồng nào !", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredContracts.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredContracts[index];
                                  String currentStatus = (item['trangThai'] ?? "Chờ ký").toString().trim();
                                  
                                  return _buildContractCard(
                                    context: context,
                                    maHopDong: item['maHopDong'],
                                    id: 'HD-2026-00${item['maHopDong']}',
                                    name: item['tenKhach'] ?? "Khách vãng lai",
                                    room: 'Phòng ${item['soPhong']} - ${item['tenCoSo'] ?? ""}',
                                    phone: item['sdt'] ?? "Chưa bổ sung",
                                    date: _formatDateRange(item['ngayBatDau'], item['ngayKetThuc']),
                                    price: _formatCurrency(item['giaThue']),
                                    deposit: _formatCurrency(item['tienCoc']),
                                    status: currentStatus == "Chờ khách ký" ? "CHỜ KÝ" : currentStatus.toUpperCase(),
                                    statusColor: _getStatusColor(currentStatus),
                                  );
                                },
                              ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quản lý hợp đồng', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const Text('Quản lý tất cả hợp đồng thuê phòng của bạn.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              bool? added = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AdAddHopDong()));
              if (added == true) _fetchContractsAdmin();
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Tạo hợp đồng mới', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.deepPurple, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
          children: [
            _statusItem('Đang hiệu lực', _countHieuLuc.toString().padLeft(2, '0'), const Color(0x192DDCB1), const Color(0xFF2DDCB1)),
            _statusItem('Sắp hết hạn', _countSapHetHan.toString().padLeft(2, '0'), const Color(0x19FBBF24), const Color(0xFFFBBF24)),
            _statusItem('Chờ ký', _countChoKy.toString().padLeft(2, '0'), const Color(0x1960A5FA), const Color(0xFF60A5FA)),
            _statusItem('Đã hết hạn', _countHetHan.toString().padLeft(2, '0'), const Color(0x19F87171), const Color(0xFFF87171)),
          ],
        ),
        if (_countChoKetThucSom > 0) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.exit_to_app_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Yêu cầu kết thúc sớm', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text('$_countChoKetThucSom hợp đồng đang chờ duyệt', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatusFilter = 'Chờ kết thúc sớm';
                      _applySearchAndFilter();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Xem ngay', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusItem(String label, String count, Color bg, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppTheme.deepPurple.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.description_outlined, color: tint, size: 20)),
          const SizedBox(width: 12),
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController, onChanged: (_) => _applySearchAndFilter(),
          decoration: InputDecoration(
            hintText: 'Tìm theo tên, mã HD, phòng...', prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { _searchController.clear(); _applySearchAndFilter(); }) : null,
            filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatusFilter, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              items: <String>['Tất cả trạng thái', 'Đang hiệu lực', 'Chờ ký', 'Sắp hết hạn', 'Đã hết hạn', 'Chờ gia hạn', 'Chờ kết thúc sớm', 'Đã kết thúc sớm'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (String? newValue) { if (newValue != null) { setState(() { _selectedStatusFilter = newValue; _applySearchAndFilter(); }); } },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Danh sách hợp đồng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text('${_filteredContracts.length} hợp đồng', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildContractCard({required BuildContext context, required int maHopDong, required String id, required String name, required String room, required String phone, required String date, required String price, required String deposit, required String status, required Color statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppTheme.deepPurple.withOpacity(0.85), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppTheme.deepPurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () async {
            bool? isChanged = await Navigator.push(context, MaterialPageRoute(builder: (context) => AdDetailHopDong(maHopDong: maHopDong)));
            if (isChanged == true) _fetchContractsAdmin();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(id, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5)),
                      child: Row(children: [Icon(Icons.circle, color: statusColor, size: 6), const SizedBox(width: 6), Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _infoLine(Icons.door_back_door_outlined, room),
                _infoLine(Icons.phone_iphone_rounded, phone),
                _infoLine(Icons.event_available_outlined, date),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, height: 1)),
                Row(
                  children: [Expanded(child: _buildPriceInfo('THUÊ', price)), Container(width: 1, height: 30, color: Colors.white10), Expanded(child: _buildPriceInfo('CỌC', deposit))],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(Icons.edit_note_rounded, () {
                      if (status == "ĐANG HIỆU LỰC") {
                        _showSnackBar('Hợp đồng đã ký kết, không thể sửa!', Colors.orange);
                        return;
                      }
                      _handleEditContract(maHopDong);
                    }),
                    const SizedBox(width: 12),
                    _actionButton(Icons.file_download_outlined, () {
                      // Bấm phát kích hoạt luồng tải file chuẩn chỉ theo ID hợp đồng đó
                      _downloadAndOpenContractPdf(maHopDong, name);
                    }),
                    const SizedBox(width: 12),
                    _actionButton(Icons.delete_sweep_outlined, () {
                      
                      if (status == "ĐANG HIỆU LỰC" || status == "ĐÃ KÝ") {
                        _showSnackBar('Hợp đồng đang có hiệu lực pháp lý, tuyệt đối không được xóa!', Colors.orange);
                        return;
                      }
                      _handleDeleteContract(maHopDong, name);
                    }, isDelete: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))]);
  }

  Widget _actionButton(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(8),
        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDelete ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: isDelete ? Colors.redAccent : Colors.white, size: 20)),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [Icon(icon, color: Colors.white60, size: 14), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12))]),
    );
  }
}