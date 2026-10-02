import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/admin/invoice_model.dart';
import '../../shared/app_theme.dart';

class URChiTietHoaDonPage extends StatelessWidget {
  final InvoiceModel invoice;

  const URChiTietHoaDonPage({super.key, required this.invoice});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final soDien = invoice.soDienMoi - invoice.soDienCu;
    final soNuoc = invoice.soNuocMoi - invoice.soNuocCu;

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
        title: const Text(
          'Chi tiết hóa đơn',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // E-Receipt Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Success Header Gradient
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF68D391), Color(0xFF48BB78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.check,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'THANH TOÁN THÀNH CÔNG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatCurrency(invoice.tongTien),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã giao dịch: #INV-${invoice.maHoaDon}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Receipt Body
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room & Tenant Info Section
                        const Text(
                          'THÔNG TIN CHUNG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReceiptInfoRow(
                          'Khách thuê',
                          invoice.tenKhachThue.isNotEmpty
                              ? invoice.tenKhachThue
                              : 'Chưa cập nhật',
                        ),
                        _buildReceiptInfoRow(
                          'Phòng trọ',
                          invoice.tenPhong.isNotEmpty
                              ? 'Phòng ${invoice.tenPhong}'
                              : 'Chưa cập nhật',
                        ),
                        _buildReceiptInfoRow(
                          'Cơ sở',
                          invoice.tenCoSo.isNotEmpty
                              ? invoice.tenCoSo
                              : 'Chưa cập nhật',
                        ),
                        _buildReceiptInfoRow(
                          'Chu kỳ hóa đơn',
                          'Tháng ${invoice.thang.toString().padLeft(2, '0')}/${invoice.nam}',
                        ),
                        if (invoice.ngayThanhToan != null)
                          _buildReceiptInfoRow(
                            'Ngày thanh toán',
                            invoice.ngayThanhToan.toString(),
                          ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(thickness: 0.5),
                        ),

                        // Pricing Details Breakdown
                        const Text(
                          'CHI TIẾT DỊCH VỤ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReceiptCostRow(
                          'Tiền phòng trọ',
                          formatCurrency(invoice.tienPhong),
                        ),
                        _buildReceiptCostRow(
                          'Tiền điện (${soDien.toInt()} kWh)',
                          formatCurrency(invoice.tienDien),
                          subText:
                              '${invoice.soDienCu.toInt()} kWh -> ${invoice.soDienMoi.toInt()} kWh | ${formatCurrency(invoice.donGiaDien)}/kWh',
                        ),
                        _buildReceiptCostRow(
                          'Tiền nước (${soNuoc.toInt()} m³)',
                          formatCurrency(invoice.tienNuoc),
                          subText:
                              '${invoice.soNuocCu.toInt()} m³ -> ${invoice.soNuocMoi.toInt()} m³ | ${formatCurrency(invoice.donGiaNuoc)}/m³',
                        ),
                        if (invoice.phuPhi > 0)
                          _buildReceiptCostRow(
                            invoice.moTaPhuPhi?.isNotEmpty == true
                                ? invoice.moTaPhuPhi!
                                : 'Phí phát sinh',
                            formatCurrency(invoice.phuPhi),
                          ),
                        _buildReceiptCostRow(
                          'Dịch vụ & cố định',
                          formatCurrency(invoice.tienDichVu),
                          subText: invoice.moTaDichVu,
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(thickness: 0.5),
                        ),

                        // Total Row inside receipt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TỔNG TIỀN ĐÃ TRẢ',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              formatCurrency(invoice.tongTien),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Print / Download PDF Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã tải hóa đơn điện tử PDF thành công!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(LucideIcons.download, size: 20),
                label: const Text(
                  'Tải hóa đơn PDF',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCostRow(String label, String value, {String? subText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (subText != null && subText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subText,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
