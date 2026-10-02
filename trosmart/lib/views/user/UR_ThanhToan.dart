import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/user/payment_widgets.dart';
import '../../logic/user/user_payment_controller.dart';
import '../../shared/app_theme.dart';
import 'UR_ChiTietHoaDon.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      body: Consumer<UserPaymentController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.allInvoices.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            );
          }

          if (controller.errorMessage != null && controller.allInvoices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.statusRed),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.statusRed),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.loadUserInvoices(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final unpaidInvoices = controller.unpaidInvoices;
          final paidInvoices = controller.paidInvoices;

          // Hiển thị tối đa 2 hóa đơn chưa thanh toán
          final displayUnpaid = unpaidInvoices.take(2).toList();

          return RefreshIndicator(
            onRefresh: () => controller.loadUserInvoices(),
            color: AppTheme.primaryPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  // 1. Phần hóa đơn chưa thanh toán
                  if (displayUnpaid.isEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green),
                          const SizedBox(height: 16),
                          const Text(
                            'Không có hóa đơn thanh toán',
                            style: TextStyle(
                              color: AppTheme.textPrimary, 
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tất cả các hóa đơn của bạn đã được thanh toán đầy đủ.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    ...displayUnpaid.map((inv) {
                      final index = displayUnpaid.indexOf(inv);
                      return Column(
                        children: [
                          if (displayUnpaid.length > 1) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Hóa đơn chưa thanh toán #${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.deepPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          BillBanner(invoice: inv),
                          const SizedBox(height: 24),
                          const SectionHeader(title: "CHI TIẾT HÓA ĐƠN"),
                          const SizedBox(height: 16),
                          BillDetailList(invoice: inv),
                          const SizedBox(height: 24),
                          SharedCostSection(invoice: inv),
                          const SizedBox(height: 32),
                        ],
                      );
                    }),
                  ],

                  // 2. Phần lịch sử thanh toán
                  const SectionHeader(title: "LỊCH SỬ THANH TOÁN"),
                  const SizedBox(height: 16),
                  if (paidInvoices.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Chưa có lịch sử thanh toán.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    ...paidInvoices.map((inv) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => URChiTietHoaDonPage(invoice: inv),
                            ),
                          );
                        },
                        child: PaymentHistoryItem(
                          month: '${inv.thang.toString().padLeft(2, '0')}/${inv.nam}',
                          amount: formatCurrency(inv.tongTien),
                          date: inv.ngayThanhToan ?? inv.ngayLapDisplay,
                          status: inv.trangThai,
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}