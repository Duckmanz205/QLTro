import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trosmart/views/admin/AD_HoaDon.dart';
import '../../views/admin/AD_ThemHoaDon.dart';
import 'package:trosmart/views/admin/AD_SuaHoaDon.dart';
import '../../shared/app_colors.dart';
import 'package:provider/provider.dart';
import '../../logic/admin/invoice_controller.dart';

import '../../models/admin/invoice_model.dart';

// --- Component: Header Gradient ---
class InvoiceDetailHeader extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceDetailHeader({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: AppColors.adminHeaderGradient, // Tận dụng gradient có sẵn
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                onPressed: (){
                  Navigator.pop(context);
                }),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết hóa đơn',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tháng ${invoice.thang}/${invoice.nam} | Mã: #INV-${invoice.maHoaDon}',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                    ),
                    if (invoice.tenKhachThue.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Khách: ${invoice.tenKhachThue}',
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                        ),
                      ),
                    if (invoice.tenCoSo.isNotEmpty)
                      Text(
                        'Cơ sở: ${invoice.tenCoSo}',
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Component: Thẻ Tóm tắt ---
class InvoiceSummaryCard extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceSummaryCard({super.key, required this.invoice});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    // Xác định trạng thái hiển thị
    final isOverdue = invoice.trangThai == 'Quá hạn';
    final isPaid = invoice.trangThai == 'Đã thanh toán';
    
    Color statusColor;
    String statusText;
    Color statusBgColor;
    
    if (isPaid) {
      statusColor = const Color(0xFF2DDCB1);
      statusText = 'ĐÃ TRẢ';
      statusBgColor = const Color(0xFFE6F9F5);
    } else if (isOverdue) {
      statusColor = Colors.redAccent;
      statusText = 'QUÁ HẠN';
      statusBgColor = const Color(0xFFFFEBEE);
    } else {
      statusColor = AppColors.statusOrange;
      statusText = 'CHỜ TRẢ';
      statusBgColor = AppColors.warningLightBg;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TỔNG THANH TOÁN', style: GoogleFonts.inter(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(formatCurrency(invoice.tongTien), style: GoogleFonts.inter(color: AppColors.adminDarkPurple, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText, 
                      style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Thông tin ngày tháng
          Row(
            children: [
              _InfoChip(icon: Icons.calendar_today, label: 'Ngày lập: ${invoice.ngayLapDisplay}'),
              const SizedBox(width: 12),
              _InfoChip(icon: Icons.schedule, label: 'Hạn: ${invoice.hanThanhToanDisplay}'),
            ],
          ),
          if (invoice.ngayThanhToan != null) ...[
            const SizedBox(height: 8),
            _InfoChip(icon: Icons.check_circle, label: 'Thanh toán: ${invoice.ngayThanhToan}'),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textLight),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }
}

// --- Component: Thẻ Chi tiết phí ---
class InvoiceDetailsCard extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceDetailsCard({super.key, required this.invoice});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  String formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        children: [
          // Tiền phòng
          InvoiceDetailRow(
            title: 'Tiền phòng (${invoice.tenPhong.isNotEmpty ? invoice.tenPhong : 'P.${invoice.maPhong}'})', 
            amount: formatCurrency(invoice.tienPhong), 
            isBold: true,
          ),
          const Divider(height: 30, color: AppColors.backgroundGray),
          
          // Tiền điện - dùng đơn giá thực từ API
          InvoiceDetailRow(
            icon: Icons.bolt, iconColor: Colors.yellow, 
            title: 'Điện (${(invoice.soDienMoi - invoice.soDienCu).toInt()} kWh x ${formatNumber(invoice.donGiaDien)})', 
            subtitle: 'Số cũ: ${invoice.soDienCu.toInt()} - Số mới: ${invoice.soDienMoi.toInt()}', 
            amount: formatCurrency(invoice.tienDien),
          ),
          const SizedBox(height: 16),
          
          // Tiền nước - dùng đơn giá thực từ API
          InvoiceDetailRow(
            icon: Icons.water_drop, iconColor: Colors.blue, 
            title: 'Nước (${(invoice.soNuocMoi - invoice.soNuocCu).toInt()} m³ x ${formatNumber(invoice.donGiaNuoc)})', 
            subtitle: 'Số cũ: ${invoice.soNuocCu.toInt()} - Số mới: ${invoice.soNuocMoi.toInt()}', 
            amount: formatCurrency(invoice.tienNuoc),
          ),
          
          // Tiền dịch vụ
          if (invoice.tienDichVu > 0) ...[
            const SizedBox(height: 16),
            InvoiceDetailRow(
              icon: Icons.language, iconColor: Colors.lightBlueAccent, 
              title: 'Dịch vụ', 
              subtitle: invoice.moTaDichVu,
              amount: formatCurrency(invoice.tienDichVu),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const InvoiceDetailRow(icon: Icons.language, iconColor: Colors.lightBlueAccent, title: 'Dịch vụ', amount: '0đ (Free)'),
          ],
          
          // Phụ phí
          if (invoice.phuPhi > 0) ...[
            const SizedBox(height: 16),
            InvoiceDetailRow(
              icon: Icons.build, iconColor: Colors.grey, 
              title: 'Phụ phí', 
              subtitle: invoice.moTaPhuPhi,
              amount: formatCurrency(invoice.phuPhi),
            ),
          ],
        ],
      ),
    );
  }
}

class InvoiceDetailRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String amount;
  final bool isBold;

  const InvoiceDetailRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                    if (subtitle != null && subtitle!.isNotEmpty) 
                      Text(subtitle!, style: GoogleFonts.inter(color: AppColors.textLight, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Text(amount, style: GoogleFonts.inter(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}

class BankTransferCard extends StatelessWidget {
  final InvoiceModel invoice;
  const BankTransferCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purpleLightBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purpleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.qr_code_2, size: 50, color: AppColors.darkAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quét QR chuyển khoản',
                  style: GoogleFonts.inter(
                    color: AppColors.adminDarkPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice.tenVietTat != null && invoice.tenVietTat!.isNotEmpty
                      ? 'Ngân hàng: ${invoice.tenVietTat}'
                      : 'Ngân hàng: Chưa thiết lập',
                  style: GoogleFonts.inter(color: AppColors.textLight, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  invoice.soTaiKhoan != null && invoice.soTaiKhoan!.isNotEmpty
                      ? 'STK: ${invoice.soTaiKhoan}'
                      : 'STK: Chưa thiết lập',
                  style: GoogleFonts.inter(color: AppColors.textLight, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Component: Các nút hành động ---
class ActionButtons extends StatelessWidget {
  final InvoiceModel invoice;
  const ActionButtons({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chuyển sang Zalo...')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminDarkPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Gửi lại (Zalo)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: invoice.trangThai == 'Đã thanh toán'
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (routeContext) => ChangeNotifierProvider.value(
                          value: context.read<InvoiceController>(),
                          child: EditInvoiceScreen(invoice: invoice),
                        ),
                      ),
                    );
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: invoice.trangThai == 'Đã thanh toán'
                    ? Colors.grey.shade300
                    : AppColors.adminDarkPurple,
                width: 2,
              ),
              foregroundColor: invoice.trangThai == 'Đã thanh toán'
                  ? Colors.grey
                  : AppColors.adminDarkPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              invoice.trangThai == 'Đã thanh toán' ? 'Không thể sửa' : 'Sửa dữ liệu',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}