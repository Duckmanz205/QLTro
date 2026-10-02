import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/app_colors.dart';
import '../../models/su_co.dart';
import '../../services/su_co_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/api_constants.dart';
import '../../logic/auth/auth_service.dart';

/// --- TIÊU ĐỀ TRANG VÀ NÚT TẠO YÊU CẦU ---
class ActionHeader extends StatelessWidget {
  final VoidCallback onTapCreate;
  const ActionHeader({super.key, required this.onTapCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Báo cáo sự cố',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('Issue Reporting', style: TextStyle(color: Colors.grey)),
            ],
          ),
          GestureDetector(
            onTap: onTapCreate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.userPurpleLight, AppColors.userPurple],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.userPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Tạo yêu cầu',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewRequestForm extends StatefulWidget {
  final VoidCallback? onSubmitSuccess;
  final VoidCallback? onCancel;
  const NewRequestForm({super.key, this.onSubmitSuccess, this.onCancel});

  @override
  State<NewRequestForm> createState() => _NewRequestFormState();
}

class _NewRequestFormState extends State<NewRequestForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.tealDark),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.tealDark),
                title: const Text('Chụp ảnh mới'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final file = File(pickedFile.path);
      final fileName = 'su_co_${DateTime.now().millisecondsSinceEpoch}.png';

      final supabase = Supabase.instance.client;
      await supabase.storage
          .from('SuCo')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = supabase.storage
          .from('SuCo')
          .getPublicUrl(fileName);

      setState(() {
        _uploadedImageUrl = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tải hình ảnh lên thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Supabase Upload Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh lên Supabase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ tiêu đề và mô tả sự cố')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final maKhach = prefs.getInt('ma_khach') ?? 1;

      int? maPhong;
      try {
        final token = await AuthService().getToken();
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/HopDong'),
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        );
        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);
          List<dynamic> contracts = [];
          if (decoded is List) {
            contracts = decoded;
          } else if (decoded is Map) {
            if (decoded.containsKey('data') && decoded['data'] is List) {
              contracts = decoded['data'];
            } else if (decoded.containsKey('value') && decoded['value'] is List) {
              contracts = decoded['value'];
            } else {
              contracts = [decoded];
            }
          }

          // 1. Search for active contract ("Đang hiệu lực")
          for (var hd in contracts) {
            if (hd == null || hd is! Map) continue;
            var dynamicMaKhach = hd['maKhach'] ?? hd['MaKhach'] ?? hd['MAKHACH'] ?? hd['ma_khach'];
            if (dynamicMaKhach != null && dynamicMaKhach.toString() == maKhach.toString()) {
              final status = (hd['trangThai'] ?? hd['TrangThai'] ?? '').toString().trim();
              if (status == 'Đang hiệu lực') {
                maPhong = int.tryParse((hd['maPhong'] ?? hd['MaPhong']).toString());
                break;
              }
            }
          }
          // 2. Fallback to any contract matching maKhach
          if (maPhong == null) {
            for (var hd in contracts) {
              if (hd == null || hd is! Map) continue;
              var dynamicMaKhach = hd['maKhach'] ?? hd['MaKhach'] ?? hd['MAKHACH'] ?? hd['ma_khach'];
              if (dynamicMaKhach != null && dynamicMaKhach.toString() == maKhach.toString()) {
                maPhong = int.tryParse((hd['maPhong'] ?? hd['MaPhong']).toString());
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Lỗi tìm phòng của khách: $e");
      }

      if (maPhong == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy phòng thuê hoạt động của bạn để gửi báo cáo!')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final suCo = SuCo(
        maSuCo: 0, // Backend tự tạo
        maPhong: maPhong,
        maKhach: maKhach,
        tieuDe: _titleController.text,
        moTa: _descController.text,
        hinhAnh: _uploadedImageUrl,
      );

      final success = await SuCoService().sendSuCo(suCo);
      if (success) {
        _titleController.clear();
        _descController.clear();
        setState(() {
          _uploadedImageUrl = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi báo cáo thành công!')),
        );
        if (widget.onSubmitSuccess != null) {
          widget.onSubmitSuccess!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi báo cáo thất bại! Vui lòng thử lại.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.userBorder),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.userTealLightBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: AppColors.tealDark, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Request',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('Yêu cầu mới',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('MÔ TẢ SỰ CỐ'),
          _buildInput('VD: đèn trong nhà tắm bị hỏng', _titleController),
          const SizedBox(height: 20),
          _buildLabel('CHI TIẾT'),
          _buildInput('Mô tả chi tiết hơn...', _descController, maxLines: 4),
          const SizedBox(height: 16),
          if (_isUploadingImage)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.tealDark),
                    SizedBox(height: 8),
                    Text('Đang tải hình ảnh lên...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            )
          else if (_uploadedImageUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _uploadedImageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _uploadedImageUrl = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                icon: Icon(
                  _uploadedImageUrl != null ? Icons.image : Icons.camera_alt_outlined,
                  size: 18,
                ),
                label: Text(_uploadedImageUrl != null ? 'Thay đổi' : 'Chụp hình'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tealDark,
                  side: const BorderSide(color: AppColors.userTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _titleController.clear();
                      _descController.clear();
                      if (widget.onCancel != null) {
                        widget.onCancel!();
                      }
                    },
                    child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.userPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Gửi'),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: AppColors.userBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

/// --- VẠCH PHÂN CÁCH LỊCH SỬ ---
class HistoryDivider extends StatelessWidget {
  const HistoryDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.userBorder,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Lịch sử sự cố',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class IssueHistoryList extends StatefulWidget {
  const IssueHistoryList({super.key});

  @override
  State<IssueHistoryList> createState() => _IssueHistoryListState();
}

class _IssueHistoryListState extends State<IssueHistoryList> {
  Future<List<SuCo>>? _futureSuCo;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final maKhach = prefs.getInt('ma_khach') ?? 1;
    setState(() {
      _futureSuCo = SuCoService().getSuCoForUser(maKhach);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _futureSuCo == null
          ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            )
          : FutureBuilder<List<SuCo>>(
              future: _futureSuCo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bạn chưa báo cáo sự cố nào.'));
          }

          return Column(
            children: snapshot.data!.map((suCo) {
              final statusLower = (suCo.trangThai ?? 'chờ xử lý').toLowerCase().trim();
              Color statusColor = AppColors.statusPending;
              Widget detailWidget = const PendingStatusDetails();

              if (statusLower == 'đang xử lý') {
                statusColor = AppColors.statusProcessing;
                detailWidget = const ProcessingStatusDetails();
              } else if (statusLower == 'đã hoàn thành' || statusLower == 'hoàn thành') {
                statusColor = AppColors.tealDark;
                detailWidget = const CompletedStatusDetails();
              } else if (statusLower == 'từ chối') {
                statusColor = AppColors.statusUrgent;
                detailWidget = const RejectedStatusDetails();
              } else {
                statusColor = AppColors.statusPending;
                detailWidget = const PendingStatusDetails();
              }

              final dateStr = suCo.ngayBao != null ? '${suCo.ngayBao!.day}/${suCo.ngayBao!.month}/${suCo.ngayBao!.year}' : '';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: HistoryCard(
                  title: suCo.tieuDe,
                  date: dateStr,
                  status: suCo.trangThai ?? 'Chờ xử lý',
                  statusColor: statusColor,
                  child: detailWidget,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final Widget child;

  const HistoryCard({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.userBorder),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(status == 'Hoàn thành' ? Icons.check : Icons.person_outline,
                        size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                          color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class PendingStatusDetails extends StatelessWidget {
  const PendingStatusDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.userBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.userBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.statusPending.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.hourglass_empty_rounded, color: AppColors.statusPending, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Đang chờ xử lý...',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Yêu cầu đã được gửi đến Admin',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz, color: Colors.grey),
        ],
      ),
    );
  }
}

class ProcessingStatusDetails extends StatelessWidget {
  const ProcessingStatusDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.userBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.userBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.engineering_outlined, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nhân viên đang đến...',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dự kiến: ~30 phút nữa',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz, color: Colors.grey),
        ],
      ),
    );
  }
}

class RejectedStatusDetails extends StatelessWidget {
  const RejectedStatusDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.userBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.userBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.statusUrgent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cancel_outlined, color: AppColors.statusUrgent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Yêu cầu bị từ chối',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.statusUrgent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Vui lòng liên hệ Admin để biết thêm chi tiết',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz, color: Colors.grey),
        ],
      ),
    );
  }
}

class CompletedStatusDetails extends StatelessWidget {
  const CompletedStatusDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.userTealBorder.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.userTealBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: AppColors.tealDark, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đánh giá của bạn',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.tealDark)),
                  Text('Cảm ơn bạn đã phản hồi!',
                      style: TextStyle(color: AppColors.userTeal, fontSize: 11)),
                ],
              ),
            ],
          ),
          Row(
            children: List.generate(
                5, (index) => const Icon(Icons.star, color: AppColors.userStarGold, size: 14)),
          )
        ],
      ),
    );
  }
}

class FooterIndicator extends StatelessWidget {
  const FooterIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: Colors.grey.shade200),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'HẾT LỊCH SỬ',
            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        Container(width: 40, height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}