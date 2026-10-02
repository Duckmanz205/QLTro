import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_colors.dart';

import '../../widgets/admin/incident_management_widgets.dart';

import '../../models/su_co.dart';
import '../../services/su_co_service.dart';
import '../../logic/auth/auth_service.dart';

class AD_SuCo extends StatefulWidget {
  const AD_SuCo({super.key});

  @override
  State<AD_SuCo> createState() => _AD_SuCoState();
}

class _AD_SuCoState extends State<AD_SuCo> {
  List<SuCo>? _allSuCos;
  bool _isLoading = false;
  String? _errorMessage;

  String _searchText = "";
  String _selectedStatus = "Tất cả";

  @override
  void initState() {
    super.initState();
    _loadSuCos();
  }

  Future<void> _loadSuCos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final maQuanLy = await AuthService().getMaQuanLy();
      final list = await SuCoService().getAllSuCo(maQuanLy: maQuanLy);
      setState(() {
        _allSuCos = list;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final success = await SuCoService().updateSuCoStatus(id, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái thành: $status')),
        );
        _loadSuCos(); // Tải lại danh sách
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  List<SuCo> get _filteredSuCo {
    if (_allSuCos == null) return [];
    return _allSuCos!.where((suCo) {
      // 1. Lọc theo trạng thái
      if (_selectedStatus != "Tất cả") {
        if ((suCo.trangThai?.toLowerCase() ?? '') !=
            _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // 2. Lọc theo thanh tìm kiếm
      if (_searchText.isNotEmpty) {
        final query = _searchText.toLowerCase();
        final matchTitle = suCo.tieuDe.toLowerCase().contains(query);
        final matchDesc = (suCo.moTa?.toLowerCase() ?? '').contains(query);
        final matchRoom =
            'phòng ${suCo.maPhong}'.contains(query) ||
            suCo.maPhong.toString().contains(query);
        final matchRequester =
            'khách ${suCo.maKhach}'.contains(query) ||
            suCo.maKhach.toString().contains(query);
        return matchTitle || matchDesc || matchRoom || matchRequester;
      }
      return true;
    }).toList();
  }

  void _showIncidentDetailDialog(SuCo suCo) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi tiết sự cố',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  label: 'Mã sự cố',
                  value: 'SC${suCo.maSuCo.toString().padLeft(3, '0')}',
                  isHighlight: true,
                ),
                _buildDetailRow(
                  label: 'Tiêu đề',
                  value: suCo.tieuDe,
                  boldValue: true,
                ),
                _buildDetailRow(
                  label: 'Nơi báo cáo',
                  value: suCo.soPhong != null && suCo.tenCoSo != null
                      ? 'P.${suCo.soPhong} - ${suCo.tenCoSo}'
                      : 'Phòng ${suCo.maPhong}',
                ),
                _buildDetailRow(
                  label: 'Người báo cáo',
                  value: suCo.hoTenKhach ?? 'Khách ${suCo.maKhach}',
                ),
                _buildDetailRow(
                  label: 'Trạng thái',
                  value: (suCo.trangThai ?? 'Chờ xử lý').toUpperCase(),
                  statusColor: _getIncidentStatusColor(
                    suCo.trangThai ?? 'Chờ xử lý',
                  ),
                ),
                _buildDetailRow(
                  label: 'Ngày báo',
                  value: suCo.ngayBao != null
                      ? '${suCo.ngayBao!.hour.toString().padLeft(2, '0')}:${suCo.ngayBao!.minute.toString().padLeft(2, '0')} - ${suCo.ngayBao!.day}/${suCo.ngayBao!.month}/${suCo.ngayBao!.year}'
                      : 'Chưa xác định',
                ),
                if (suCo.ngayXuLy != null)
                  _buildDetailRow(
                    label: 'Ngày xử lý',
                    value:
                        '${suCo.ngayXuLy!.hour.toString().padLeft(2, '0')}:${suCo.ngayXuLy!.minute.toString().padLeft(2, '0')} - ${suCo.ngayXuLy!.day}/${suCo.ngayXuLy!.month}/${suCo.ngayXuLy!.year}',
                  ),
                const SizedBox(height: 12),
                Text(
                  'Mô tả chi tiết:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    suCo.moTa ?? 'Không có mô tả chi tiết từ khách thuê.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
                if (suCo.hinhAnh != null && suCo.hinhAnh!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Hình ảnh minh chứng:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      suCo.hinhAnh!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[100],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              SizedBox(height: 8),
                              Text('Không thể tải hình ảnh', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Đóng',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6E589E),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getIncidentStatusColor(String status) {
    status = status.toUpperCase();
    if (status == 'CHỜ XỬ LÝ') return AppColors.statusPending;
    if (status == 'ĐANG XỬ LÝ') return AppColors.statusProcessing;
    if (status == 'ĐÃ HOÀN THÀNH' || status == 'HOÀN THÀNH')
      return AppColors.accentTeal;
    if (status == 'TỪ CHỐI') return AppColors.statusUrgent;
    return Colors.black54;
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isHighlight = false,
    bool boldValue = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isHighlight || boldValue || statusColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
                color:
                    statusColor ??
                    (isHighlight ? const Color(0xFF6E589E) : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán thống kê động từ API
    final pendingCount =
        _allSuCos?.where((sc) => sc.trangThai == 'Chờ xử lý').length ?? 0;
    final processingCount =
        _allSuCos?.where((sc) => sc.trangThai == 'Đang xử lý').length ?? 0;
    final completedCount =
        _allSuCos?.where((sc) => sc.trangThai == 'Đã hoàn thành').length ?? 0;
    final urgentCount =
        _allSuCos?.where((sc) => sc.trangThai == 'Đang xử lý').length ?? 0;

    final filteredList = _filteredSuCo;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý sự cố',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theo dõi và xử lý yêu cầu sửa chữa từ khách thuê',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              IncidentStatsGrid(
                pendingCount: pendingCount,
                processingCount: processingCount,
                completedCount: completedCount,
                urgentCount: urgentCount,
              ),
              const SizedBox(height: 24),

              IncidentSearchAndFilter(
                searchText: _searchText,
                onSearchChanged: (val) {
                  setState(() {
                    _searchText = val;
                  });
                },
                selectedStatus: _selectedStatus,
                onStatusChanged: (val) {
                  setState(() {
                    _selectedStatus = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách yêu cầu',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    '${filteredList.length} sự cố',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: Color(0xFF6A3092)),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Text(
                          'Lỗi: $_errorMessage',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadSuCos,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy sự cố nào phù hợp.',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final suCo = filteredList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: IncidentCard(
                        code: 'SC${suCo.maSuCo.toString().padLeft(3, '0')}',
                        title: suCo.tieuDe,
                        status: (suCo.trangThai?.toUpperCase()) ?? 'CHỜ XỬ LÝ',
                        type: 'SỰ CỐ',
                        room: suCo.soPhong != null && suCo.tenCoSo != null
                            ? 'P.${suCo.soPhong} - ${suCo.tenCoSo}'
                            : 'Phòng ${suCo.maPhong}',
                        requester: suCo.hoTenKhach ?? 'Khách ${suCo.maKhach}',
                        date: suCo.ngayBao != null
                            ? '${suCo.ngayBao!.day}/${suCo.ngayBao!.month}/${suCo.ngayBao!.year}'
                            : '',
                        imagesCount: (suCo.hinhAnh != null && suCo.hinhAnh!.isNotEmpty) ? 1 : 0,
                        isUrgent: suCo.trangThai == 'Đang xử lý',
                        bgColor: AppColors.incidentBg1,
                        onAccept: () =>
                            _updateStatus(suCo.maSuCo, 'Đang xử lý'),
                        onReject: () => _updateStatus(suCo.maSuCo, 'Từ chối'),
                        onComplete: () =>
                            _updateStatus(suCo.maSuCo, 'Đã hoàn thành'),
                        onTap: () => _showIncidentDetailDialog(suCo),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 100), // Padding cho bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
