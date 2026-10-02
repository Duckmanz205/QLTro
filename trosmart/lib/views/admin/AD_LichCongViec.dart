import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/api_constants.dart'; // 
import '../../logic/auth/auth_service.dart';
import 'AD_AddLich.dart';
import 'AD_DetailLich.dart';

class AdLichCongViec extends StatefulWidget {
  const AdLichCongViec({super.key});

  @override
  State<AdLichCongViec> createState() => _AdLichCongViecState();
}

class _AdLichCongViecState extends State<AdLichCongViec> {
  List<dynamic> _allLichHens = [];
  List<dynamic> _filteredLichHens = [];
  List<int> _calendarHighlights = [];
  String _selectedTab = 'Tất cả'; // Các lựa chọn lọc: 'Tất cả', 'Gặp mặt', 'Thu tiền', 'Bảo trì', 'Khác'
  bool _isLoading = true;

  int _focusedMonth = DateTime.now().month;
  int _focusedYear = DateTime.now().year;

  // Bộ đếm số công việc động hiển thị dưới chân lịch biểu
  int _countQuaHan = 0;
  int _countDangXuLy = 0;
  int _countHoanThanh = 0;

  @override
  void initState() {
    super.initState();
    _fetchLichHens();
  }

  // Lấy toàn bộ danh sách lịch hẹn tổng cục của phân hệ Admin
  Future<void> _fetchLichHens() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final maQuanLy = prefs.getInt('ma_quan_ly') ?? 1;

      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/LichHen?maQuanLy=$maQuanLy'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _allLichHens = data;
            _applyFilter(); 
            _calculateCalendarHighlights();
            _calculateMonthlyStatusCounts(); 
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Lỗi tải lịch: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Tách loại sự kiện ngầm bọc trong chuỗi ghi chú nội bộ để phân loại màu sắc card
  String _extractEventType(String ghiChu) {
    if (ghiChu.isEmpty) return 'Gặp mặt';
    String ghiChuLower = ghiChu.toLowerCase();
    
    try {
      if (ghiChu.contains('Loại sự kiện:')) {
        String sauSuKien = ghiChu.split('Loại sự kiện:')[1];
        if (sauSuKien.contains('Lưu ý:')) {
          return sauSuKien.split('Lưu ý:')[0].replaceAll('.', '').trim();
        }
        return sauSuKien.replaceAll('.', '').trim();
      }
    } catch (_) {}

    if (ghiChuLower.contains('thu tiền') || ghiChuLower.contains('tiền')) return 'Thu tiền';
    if (ghiChuLower.contains('bảo trì') || ghiChuLower.contains('sửa chữa') || ghiChuLower.contains('hư')) return 'Bảo trì';
    return 'Gặp mặt';
  }

  // Thực thi bộ lọc danh mục sự kiện theo chip được Admin nhấn chọn
  void _applyFilter() {
    setState(() {
      if (_selectedTab == 'Tất cả') {
        _filteredLichHens = _allLichHens;
      } else {
        _filteredLichHens = _allLichHens.where((item) {
          final ghiChu = (item['GhiChu'] ?? item['ghiChu'] ?? '').toString();
          String type = _extractEventType(ghiChu);

          if (_selectedTab == 'Khác') {
            return type != 'Thu tiền' && type != 'Bảo trì' && type != 'Gặp mặt';
          }
          return type.toLowerCase().trim() == _selectedTab.toLowerCase().trim();
        }).toList();
      }
    });
  }

  // Đánh dấu các ngày có sự kiện trong tháng hiện tại lên ô lịch biểu
  void _calculateCalendarHighlights() {
    _calendarHighlights.clear();
    for (var item in _allLichHens) {
      final timeVal = item['ThoiGianHen'] ?? item['thoiGianHen'];
      if (timeVal != null) {
        DateTime date = DateTime.parse(timeVal);
        if (date.month == _focusedMonth && date.year == _focusedYear) {
          if (!_calendarHighlights.contains(date.day)) {
            _calendarHighlights.add(date.day);
          }
        }
      }
    }
  }

  // Phân tích trạng thái để tính toán bộ số tròn xanh/cam/đỏ dưới chân lịch biểu
  void _calculateMonthlyStatusCounts() {
    int quaHan = 0;
    int dangXuLy = 0;
    int hoanThanh = 0;

    for (var item in _allLichHens) {
      final timeVal = item['ThoiGianHen'] ?? item['thoiGianHen'];
      if (timeVal != null) {
        DateTime date = DateTime.parse(timeVal);
        if (date.month == _focusedMonth && date.year == _focusedYear) {
          String trangThai = item['TrangThai'] ?? item['trangThai'] ?? 'Chờ xác nhận';
          
          if (trangThai == 'Đã hoàn thành') {
            hoanThanh++;
          } else if (trangThai == 'Quá hạn' || trangThai == 'Đã hủy') {
            quaHan++;
          } else {
            dangXuLy++; 
          }
        }
      }
    }

    setState(() {
      _countQuaHan = quaHan;
      _countDangXuLy = dangXuLy;
      _countHoanThanh = hoanThanh;
    });
  }

  void _previousMonth() {
    setState(() {
      if (_focusedMonth == 1) {
        _focusedMonth = 12;
        _focusedYear--;
      } else {
        _focusedMonth--;
      }
      _calculateCalendarHighlights();
      _calculateMonthlyStatusCounts(); 
    });
  }

  void _nextMonth() {
    setState(() {
      if (_focusedMonth == 12) {
        _focusedMonth = 1;
        _focusedYear++;
      } else {
        _focusedMonth++;
      }
      _calculateCalendarHighlights();
      _calculateMonthlyStatusCounts(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredLichHens;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchLichHens,
        color: const Color(0xFF8A56AC),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch & Công Việc',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A0D2D)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8A56AC), size: 28),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdAddLich())).then((_) => _fetchLichHens()),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Thanh điều hướng phân loại danh mục sự kiện bằng Chip bấm động
              _buildCategoryTabs(),
              const SizedBox(height: 16),

              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF8A56AC))))
                  : filteredData.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: const Color(0xFFF3EAF8), borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text('Không có lịch trình nào ở mục này', style: TextStyle(color: Colors.purple, fontSize: 13, fontStyle: FontStyle.italic))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) => _buildTaskCard(filteredData[index]),
                        ),
              const SizedBox(height: 24),
              
              _buildCalendarSection(),
              const SizedBox(height: 24),

              _buildLegendSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Giao diện thanh ChoiceChip ngang gạt chọn phân loại danh mục lịch hẹn
  Widget _buildCategoryTabs() {
    final List<String> tabs = ['Tất cả', 'Gặp mặt', 'Thu tiền', 'Bảo trì', 'Khác'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          bool isSelected = _selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(tab),
              selected: isSelected,
              selectedColor: const Color(0xFF8A56AC),
              backgroundColor: const Color(0xFFF1F5F9),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedTab = tab;
                    _applyFilter(); 
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget thẻ Card màu tím hiển thị tóm tắt thông tin lịch hẹn Admin
  Widget _buildTaskCard(dynamic item) {
    String hoTen = item['HoTenKhach'] ?? item['hoTenKhach'] ?? 'Khách xem phòng';
    String ghiChu = item['GhiChu'] ?? item['ghiChu'] ?? '';
    String trangThai = item['TrangThai'] ?? item['trangThai'] ?? 'Chờ xác nhận';
    String soPhong = (item['SoPhong'] ?? item['soPhong'] ?? '').toString();
    
    String labelTag = _extractEventType(ghiChu);

    Color tagBgColor = const Color(0xFFEAF9F5);  
    Color tagTextColor = const Color(0xFF26C6DA);
    
    String cleanTag = labelTag.trim();
    if (cleanTag == 'Thu tiền') {
      tagBgColor = const Color(0xFFE2F9F3);     
      tagTextColor = const Color(0xFF2DDCB1);   
    } else if (cleanTag == 'Bảo trì') {
      tagBgColor = const Color(0xFFE6F0FF);     
      tagTextColor = const Color(0xFF4A90E2);   
    }

    Color statusDotColor = const Color(0xFF2DDCB1); 
    if (trangThai == 'Chờ xác nhận' || trangThai == 'Đang xử lý') statusDotColor = const Color(0xFFFF9F43); 
    if (trangThai == 'Quá hạn' || trangThai == 'Đã hủy') statusDotColor = const Color(0xFFFF5252); 

    DateTime date = DateTime.now();
    try {
      String rawTime = (item['ThoiGianHen'] ?? item['thoiGianHen'] ?? '').toString();
      if (rawTime.isNotEmpty) date = DateTime.parse(rawTime);
    } catch (_) {}

    String dayStr = date.day.toString().padLeft(2, '0');
    String monthStr = "Thg ${date.month.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF9B63B6), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            //  ĐÃ FIX TRIỆT ĐỂ LỖI GẠCH ĐỎ: Ép kiểu dữ liệu an toàn tránh lỗi kẹt kiểu String từ JSON
            final rawId = item['MaLichHen'] ?? item['maLichHen'] ?? 0;
            int idLich = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

            if (idLich > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //  Truyền chuẩn mã khóa chính sang trang AdDetailLich của Thái hứng
                  builder: (context) => AdDetailLich(maLichHen: idLich), 
                ),
              ).then((_) => _fetchLichHens()); // F5 cập nhật lại danh sách khi Admin lùi trang quay về
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không thể đọc mã định danh của lịch hẹn này!'), backgroundColor: Colors.orange),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(dayStr, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(monthStr, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$labelTag P.$soPhong',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tên khách: $hoTen',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: tagBgColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(labelTag, style: TextStyle(color: tagTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: statusDotColor, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cấu trúc khối GridView hiển thị ma trận ô lịch biểu mini của tháng
  Widget _buildCalendarSection() {
    int weekdayOfFirstDay = DateTime(_focusedYear, _focusedMonth, 1).weekday;
    int blankSpaces = weekdayOfFirstDay == 7 ? 0 : weekdayOfFirstDay; 
    int daysInMonth = DateTime(_focusedYear, _focusedMonth + 1, 0).day;
    
    List<String> allDays = [];
    for (int i = 0; i < blankSpaces; i++) { allDays.add(''); }
    for (int i = 1; i <= daysInMonth; i++) { allDays.add(i.toString()); }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF915FB5), 
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16), onPressed: _previousMonth),
              Text('Tháng $_focusedMonth, $_focusedYear', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16), onPressed: _nextMonth),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('CN', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('T2', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('T3', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('T4', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('T5', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('T6', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('T7', style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemBuilder: (context, index) {
              String dayText = allDays[index];
              int? dayInt = int.tryParse(dayText);
              bool isHighlighted = dayInt != null && _calendarHighlights.contains(dayInt);

              return Container(
                alignment: Alignment.center,
                decoration: isHighlighted ? BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)) : null,
                child: Text(
                  dayText,
                  style: TextStyle(color: isHighlighted ? const Color(0xFF2DDCB1) : Colors.white, fontSize: 13, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white12, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Số công việc trong tháng:', style: TextStyle(color: Colors.white70, fontSize: 11)),
              Row(
                children: [
                  _buildMiniDot(const Color(0xFFFF5252), '$_countQuaHan'),
                  _buildMiniDot(const Color(0xFFFF9F43), '$_countDangXuLy'),
                  _buildMiniDot(const Color(0xFF2DDCB1), '$_countHoanThanh'),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniDot(Color color, String count) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLegendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.info_outline, size: 14, color: Colors.teal),
            SizedBox(width: 4),
            Text('Danh mục công việc', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendBox('Thu tiền', const Color(0xFFE2F9F3), const Color(0xFF2DDCB1), 'Emerald'),
            _buildLegendBox('Bảo trì', const Color(0xFFE6F0FF), const Color(0xFF4A90E2), 'Light Blue'),
            _buildLegendBox('Gặp mặt', const Color(0xFFEAF9F5), const Color(0xFF26C6DA), 'Mint'),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Trạng thái', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusBox(const Color(0xFFFF5252), 'Quá hạn'),
            _buildStatusBox(const Color(0xFFFF9F43), 'Đang xử lý'),
            _buildStatusBox(const Color(0xFF2DDCB1), 'Hoàn thành'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendBox(String label, Color bg, Color textStyleColor, String subText) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Text(label, style: TextStyle(color: textStyleColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text(subText, style: const TextStyle(color: Colors.black26, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBox(Color dotColor, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}