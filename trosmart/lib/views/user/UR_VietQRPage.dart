import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/admin/invoice_model.dart';
import '../../shared/app_theme.dart';
import '../../logic/user/user_payment_controller.dart';
import '../../models/thong_bao.dart';
import '../../services/thong_bao_service.dart';

class UrVietQRPage extends StatefulWidget {
  final InvoiceModel invoice;
  const UrVietQRPage({super.key, required this.invoice});

  @override
  State<UrVietQRPage> createState() => _UrVietQRPageState();
}

class _UrVietQRPageState extends State<UrVietQRPage> {
  bool _isPaidMocked = false;
  bool _isUploading = false;
  String? _uploadedImagePath;

  String get _bankId => widget.invoice.maBin ?? '970415';
  String get _accountNo => widget.invoice.soTaiKhoan ?? '102876543210';
  String get _accountName => widget.invoice.tenTaiKhoan ?? 'TROSMART ACADEMY';

  String get _vietQRUrl {
    final amount = widget.invoice.tongTien.toInt();
    final addInfo = Uri.encodeComponent(
      'TROSMART T${widget.invoice.thang} P${widget.invoice.tenPhong}',
    );
    final accountNameEncoded = Uri.encodeComponent(_accountName);
    return 'https://img.vietqr.io/image/$_bankId-$_accountNo-compact2.png?amount=$amount&addInfo=$addInfo&accountName=$accountNameEncoded';
  }

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label!'),
        backgroundColor: AppTheme.accentTealDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _actualImageUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final fileName = 'proof_${widget.invoice.maHoaDon}.png';

      final supabase = Supabase.instance.client;
      await supabase.storage
          .from('payment_proofs')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = supabase.storage
          .from('payment_proofs')
          .getPublicUrl(fileName);

      setState(() {
        _uploadedImagePath = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tải lên minh chứng thanh toán thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final totalStr = formatCurrency(inv.tongTien);
    final description = 'TROSMART T${inv.thang} P${inv.tenPhong}';

    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thanh toán VietQR',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            // Cảnh báo & hướng dẫn quét mã
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.info,
                    color: AppTheme.deepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vui lòng quét mã QR dưới đây hoặc chuyển khoản theo đúng thông tin để thanh toán hóa đơn.',
                      style: GoogleFonts.inter(
                        color: AppTheme.textBody,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thẻ chứa mã VietQR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo VietQR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.network(
                        'https://vietqr.net/portal-service/resources/images/logo-vietqr.png',
                        height: 28,
                        errorBuilder: (_, __, ___) => Text(
                          'VietQR',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MÃ ĐỘNG',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hình ảnh mã QR sinh tự động
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        _vietQRUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.wifiOff,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Không thể tải mã QR',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Số tiền
                  Text(
                    totalStr,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tự động điền số tiền & nội dung chuyển khoản',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thông tin chuyển khoản chi tiết (hỗ trợ copy)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'THÔNG TIN CHUYỂN KHOẢN HỘP',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildTransferDetailRow(
                    'Ngân hàng',
                    widget.invoice.tenVietTat != null &&
                            widget.invoice.tenVietTat!.isNotEmpty
                        ? widget.invoice.tenVietTat!
                        : 'VietinBank (ICB)',
                    trailing: const Icon(
                      LucideIcons.externalLink,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildTransferDetailRow(
                    'Số tài khoản',
                    _accountNo,
                    onCopy: () => _copyToClipboard(_accountNo, 'Số tài khoản'),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildTransferDetailRow('Chủ tài khoản', _accountName),
                  const Divider(height: 24, thickness: 0.5),
                  _buildTransferDetailRow(
                    'Số tiền',
                    totalStr,
                    onCopy: () => _copyToClipboard(
                      inv.tongTien.toInt().toString(),
                      'Số tiền',
                    ),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildTransferDetailRow(
                    'Nội dung',
                    description,
                    onCopy: () =>
                        _copyToClipboard(description, 'Nội dung chuyển khoản'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mục tải lên xác nhận chuyển khoản
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MINH CHỨNG CHUYỂN KHOẢN',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _isUploading ? null : _actualImageUpload,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _uploadedImagePath != null
                        ? AppTheme.accentTeal.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _isUploading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _uploadedImagePath != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _uploadedImagePath!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 160,
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Icon(
                                LucideIcons.checkCircle,
                                color: AppTheme.accentTeal,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Đã đính kèm ảnh minh chứng chuyển khoản!',
                            style: GoogleFonts.inter(
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chạm để thay đổi hình ảnh',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 8),
                          Icon(
                            LucideIcons.image,
                            color: Colors.grey[400],
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tải lên ảnh chụp màn hình chuyển khoản',
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Giúp chủ nhà kiểm tra và xác nhận hóa đơn nhanh hơn.',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Nút bấm xác nhận hoàn tất thanh toán
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final controller = context.read<UserPaymentController>();
                  final ok = await controller.submitPaymentProof(inv.maHoaDon);
                  if (mounted) {
                    if (ok) {
                      // Send notification to Admin
                      try {
                        await ThongBaoService().sendThongBao(ThongBao(
                          maThongBao: 0,
                          maKhach: inv.maKhach ?? 1,
                          tieuDe: 'Thanh toán tiền phòng',
                          noiDung: '${inv.tenKhachThue.isNotEmpty ? inv.tenKhachThue : "Khách thuê"} đã tải lên minh chứng thanh toán cho phòng ${inv.tenPhong.isNotEmpty ? inv.tenPhong : inv.maPhong} với số tiền ${inv.tongTien.toInt()}đ.',
                          daDoc: false,
                          loaiThongBao: 'Hệ thống',
                        ));
                      } catch (e) {
                        debugPrint("Error sending thong bao: $e");
                      }
                      _showSuccessDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${controller.errorMessage}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Tôi đã chuyển khoản',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDetailRow(
    String label,
    String value, {
    VoidCallback? onCopy,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (onCopy != null)
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.copy,
                    size: 12,
                    color: AppTheme.deepPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sao chép',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (trailing != null)
          trailing,
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Thanh toán hoàn tất!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Yêu cầu thanh toán của bạn đã được ghi nhận. Hệ thống đang chờ chủ trọ phê duyệt.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppTheme.textBody,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      Navigator.pop(context); // Quay lại trang trước
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Quay lại',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
