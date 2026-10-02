import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_colors.dart';
import '../../widgets/admin/invoice_detail_widgets.dart';
import '../../models/admin/invoice_model.dart';
import '../../logic/admin/invoice_controller.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InvoiceController>();
    final currentInvoice = controller.invoices.firstWhere(
      (inv) => inv.maHoaDon == invoice.maHoaDon,
      orElse: () => invoice,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                InvoiceDetailHeader(invoice: currentInvoice),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      InvoiceSummaryCard(invoice: currentInvoice),
                      const SizedBox(height: 16),
                      InvoiceDetailsCard(invoice: currentInvoice),
                      const SizedBox(height: 16),
                      BankTransferCard(invoice: currentInvoice),
                      const SizedBox(height: 24),
                      ActionButtons(invoice: currentInvoice),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
