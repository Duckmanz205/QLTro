import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../logic/admin/invoice_controller.dart';
import '../../models/admin/invoice_model.dart';
import '../../shared/app_colors.dart';
import '../../models/thong_bao.dart';
import '../../services/thong_bao_service.dart';

class ApprovePaymentScreen extends StatefulWidget {
  const ApprovePaymentScreen({super.key});

  @override
  State<ApprovePaymentScreen> createState() => _ApprovePaymentScreenState();
}

class _ApprovePaymentScreenState extends State<ApprovePaymentScreen> {
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  void initState() {
    super.initState();
    // Fetch latest invoices in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<InvoiceController>(context, listen: false);
      controller.fetchInvoices(controller.selectedMonth, controller.selectedYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InvoiceController>();
    // Lấy danh sách các hóa đơn có trạng thái "Chờ duyệt"
    final pendingInvoices = controller.invoices
        .where((inv) => inv.trangThai == 'Chờ duyệt')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF111827), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Duyệt thanh toán',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6E589E),
              ),
            )
          : pendingInvoices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingInvoices.length,
                  itemBuilder: (context, index) {
                    final inv = pendingInvoices[index];
                    return _buildPendingCard(inv, controller);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFECE7F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              size: 64,
              color: Color(0xFF6E589E),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hộp thư duyệt trống',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Hiện không có giao dịch nào đang ở trạng thái Chờ duyệt.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(InvoiceModel inv, InvoiceController controller) {
    final proofUrl = Supabase.instance.client.storage.from('payment_proofs').getPublicUrl('proof_${inv.maHoaDon}.png');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE7F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.meeting_room_rounded,
                        color: Color(0xFF6E589E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv.tenPhong.isNotEmpty ? 'Phòng ${inv.tenPhong}' : 'Phòng ${inv.maPhong}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          inv.tenKhachThue.isNotEmpty ? inv.tenKhachThue : 'Khách thuê ẩn danh',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'CHỜ PHÊ DUYỆT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Info & Mock Image section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hóa đơn tháng:',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF4B5563)),
                    ),
                    Text(
                      'Tháng ${inv.thang}/${inv.nam}',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Số tiền chuyển:',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF4B5563)),
                    ),
                    Text(
                      formatCurrency(inv.tongTien),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // MOCK IMAGE PROOF PREVIEW
                Text(
                  'Ảnh minh chứng thanh toán:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Beautiful Real Receipt Container from Supabase Storage
                
                GestureDetector(
                  onTap: () => _showReceiptPreviewDialog(context, inv),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        proofUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF6E589E)));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback container when no actual image upload is found
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.no_photography_outlined,
                                  size: 36,
                                  color: Colors.orangeAccent,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Chưa có ảnh minh chứng thanh toán',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Click để xem thông tin chi tiết',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleApproval(context, inv, controller, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApproval(context, inv, controller, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Phê duyệt', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleApproval(BuildContext context, InvoiceModel inv, InvoiceController controller, bool isApproved) async {
    final status = isApproved ? 'Đã thanh toán' : 'Chưa thanh toán';
    final actionText = isApproved ? 'phê duyệt' : 'từ chối';
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xác nhận $actionText'),
        content: Text(
          'Bạn có chắc chắn muốn $actionText yêu cầu thanh toán phòng ${inv.tenPhong.isNotEmpty ? inv.tenPhong : inv.maPhong} với số tiền ${formatCurrency(inv.tongTien)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isApproved ? 'Phê duyệt' : 'Từ chối',
              style: TextStyle(
                color: isApproved ? const Color(0xFF10B981) : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await controller.updateStatus(inv.maHoaDon, status);
      if (mounted) {
        if (ok) {
          // Send notification about approval/rejection
          try {
            await ThongBaoService().sendThongBao(ThongBao(
              maThongBao: 0,
              maKhach: inv.maKhach ?? 1,
              tieuDe: isApproved ? 'Thanh toán được phê duyệt' : 'Thanh toán bị từ chối',
              noiDung: isApproved 
                ? 'Yêu cầu thanh toán hóa đơn phòng ${inv.tenPhong.isNotEmpty ? inv.tenPhong : inv.maPhong} tháng ${inv.thang}/${inv.nam} đã được phê duyệt thành công.'
                : 'Yêu cầu thanh toán hóa đơn phòng ${inv.tenPhong.isNotEmpty ? inv.tenPhong : inv.maPhong} tháng ${inv.thang}/${inv.nam} bị từ chối do minh chứng không chính xác. Vui lòng thử lại.',
              daDoc: false,
              loaiThongBao: 'Hệ thống',
            ));
          } catch (e) {
            debugPrint("Error sending thong bao: $e");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã $actionText giao dịch thành công!'),
              backgroundColor: isApproved ? const Color(0xFF10B981) : Colors.orange,
            ),
          );
          // Refresh list
          controller.fetchInvoices(controller.selectedMonth, controller.selectedYear);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${controller.errorMessage ?? "Không thể xử lý yêu cầu"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showReceiptPreviewDialog(BuildContext context, InvoiceModel inv) {
    final proofUrl = Supabase.instance.client.storage.from('payment_proofs').getPublicUrl('proof_${inv.maHoaDon}.png');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Chi tiết chứng từ thanh toán',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                  ),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                
                // Hiển thị ảnh chụp hóa đơn giao dịch thực tế từ Supabase Storage
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      proofUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF6E589E)));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Không tìm thấy ảnh chụp hóa đơn tải lên',
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Thông tin hóa đơn đối soát',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF111827)),
                      ),
                      const SizedBox(height: 12),
                      _buildPopupRow('Nội dung:', 'TROSMART T${inv.thang} P${inv.tenPhong}'),
                      const SizedBox(height: 8),
                      _buildPopupRow('Tổng tiền hóa đơn:', formatCurrency(inv.tongTien)),
                      const SizedBox(height: 8),
                      _buildPopupRow('Phòng:', inv.tenPhong.isNotEmpty ? 'Phòng ${inv.tenPhong}' : 'Phòng ${inv.maPhong}'),
                      const SizedBox(height: 8),
                      _buildPopupRow('Khách thuê:', inv.tenKhachThue.isNotEmpty ? inv.tenKhachThue : 'Ẩn danh'),
                      const SizedBox(height: 8),
                      _buildPopupRow('Hạn thanh toán:', inv.hanThanhToanDisplay),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
      ],
    );
  }
}
