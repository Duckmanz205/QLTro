import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/admin/invoice_model.dart';
import '../../views/user/UR_VietQRPage.dart';
import '../../shared/app_theme.dart';
import '../../logic/user/user_payment_controller.dart';

class BillBanner extends StatelessWidget {
  final InvoiceModel invoice;
  const BillBanner({super.key, required this.invoice});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final hasPaid = invoice.trangThai == 'Đã thanh toán';
    final statusColor = hasPaid ? Colors.green : const Color(0xFFB794F4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hóa đơn tháng ${invoice.thang.toString().padLeft(2, '0')}/${invoice.nam}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency(invoice.tongTien),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  invoice.trangThai.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasPaid
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (routeContext) => ChangeNotifierProvider.value(
                                value: context.read<UserPaymentController>(),
                                child: UrVietQRPage(invoice: invoice),
                              ),
                            ),
                          );
                        },
                  icon: const Icon(LucideIcons.scanLine),
                  label: Text(hasPaid ? "Đã thanh toán" : "Thanh toán QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasPaid ? Colors.grey : const Color(0xFFB794F4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã xuất hóa đơn PDF thành công!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.fileText),
                  label: const Text("PDF Bill"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFB794F4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.5, endIndent: 10)),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
        const Expanded(child: Divider(thickness: 0.5, indent: 10)),
      ],
    );
  }
}

class BillDetailList extends StatelessWidget {
  final InvoiceModel invoice;
  const BillDetailList({super.key, required this.invoice});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final soDien = invoice.soDienMoi - invoice.soDienCu;
    final soNuoc = invoice.soNuocMoi - invoice.soNuocCu;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _DetailTile(
            icon: LucideIcons.home,
            label: "Tiền phòng trọ",
            value: formatCurrency(invoice.tienPhong),
          ),
          _DetailTile(
            icon: LucideIcons.zap,
            label: "Tiền điện (${soDien.toInt()} kWh)",
            value: formatCurrency(invoice.tienDien),
          ),
          _DetailTile(
            icon: LucideIcons.droplets,
            label: "Tiền nước (${soNuoc.toInt()} m³)",
            value: formatCurrency(invoice.tienNuoc),
          ),
          if (invoice.phuPhi > 0)
            _DetailTile(
              icon: LucideIcons.alertTriangle,
              label: invoice.moTaPhuPhi?.isNotEmpty == true ? invoice.moTaPhuPhi! : "Phí phát sinh",
              value: formatCurrency(invoice.phuPhi),
            ),
          _DetailTile(
            icon: LucideIcons.settings,
            label: "Dịch vụ & cố định",
            value: formatCurrency(invoice.tienDichVu),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailTile({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class SharedCostSection extends StatelessWidget {
  final InvoiceModel invoice;
  const SharedCostSection({super.key, required this.invoice});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final costStr = formatCurrency(invoice.tongTien);
    final statusStr = invoice.trangThai == 'Đã thanh toán' ? 'ĐÃ THANH TOÁN' : 'ĐANG CHỜ';
    final tenantName = invoice.tenKhachThue.isNotEmpty ? invoice.tenKhachThue : 'Khách thuê';
    final roomInfo = invoice.tenPhong.isNotEmpty ? 'Phòng ${invoice.tenPhong}' : '';
    final facilityInfo = invoice.tenCoSo.isNotEmpty ? invoice.tenCoSo : '';

    return Column(
      children: [
        Row(
          children: [
            const Icon(LucideIcons.user, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            const Text("Thông tin người thuê", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFB794F4).withOpacity(0.15),
                    child: Text(
                      tenantName.isNotEmpty ? tenantName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB794F4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenantName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        if (roomInfo.isNotEmpty || facilityInfo.isNotEmpty)
                          Text(
                            [roomInfo, facilityInfo].where((s) => s.isNotEmpty).join(' • '),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng thanh toán', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        costStr,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB794F4)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (invoice.trangThai == 'Đã thanh toán' ? Colors.green : const Color(0xFFB794F4)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusStr,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: invoice.trangThai == 'Đã thanh toán' ? Colors.green : const Color(0xFFB794F4),
                      ),
                    ),
                  ),
                ],
              ),
              if (invoice.hanThanhToan != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Hạn thanh toán: ${invoice.hanThanhToanDisplay}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentHistoryItem extends StatelessWidget {
  final String month;
  final String amount;
  final String date;
  final String status;
  const PaymentHistoryItem({super.key, required this.month, required this.amount, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'Đã thanh toán';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : const Color(0xFFB794F4)).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? LucideIcons.checkCircle2 : LucideIcons.clock,
                  color: isPaid ? Colors.green : const Color(0xFFB794F4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tháng $month", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    isPaid ? "$date • Đã thanh toán" : "$date • Chờ phê duyệt",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}