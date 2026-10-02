import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/admin/invoice_controller.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C3EBE), Color(0xFF7A28A8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class PageTitleSection extends StatelessWidget {
  const PageTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lập hóa đơn tháng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tháng ${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} - Cơ sở Quận 7',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class InvoiceFormCard extends StatefulWidget {
  const InvoiceFormCard({super.key});

  @override
  State<InvoiceFormCard> createState() => _InvoiceFormCardState();
}

class _InvoiceFormCardState extends State<InvoiceFormCard> {
  late TextEditingController _dienMoiController;
  late TextEditingController _nuocMoiController;
  late FocusNode _dienMoiFocusNode;
  late FocusNode _nuocMoiFocusNode;

  @override
  void initState() {
    super.initState();
    _dienMoiController = TextEditingController();
    _nuocMoiController = TextEditingController();
    _dienMoiFocusNode = FocusNode();
    _nuocMoiFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _dienMoiController.dispose();
    _nuocMoiController.dispose();
    _dienMoiFocusNode.dispose();
    _nuocMoiFocusNode.dispose();
    super.dispose();
  }

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InvoiceController>();

    // Đồng bộ hóa văn bản khi dữ liệu thay đổi từ InvoiceController (Hỗ trợ autofill)
    final dienText = controller.soDienMoi > 0 ? controller.soDienMoi.toInt().toString() : '';
    if (_dienMoiController.text != dienText && !_dienMoiFocusNode.hasFocus) {
      _dienMoiController.text = dienText;
    }

    final nuocText = controller.soNuocMoi > 0 ? controller.soNuocMoi.toInt().toString() : '';
    if (_nuocMoiController.text != nuocText && !_nuocMoiFocusNode.hasFocus) {
      _nuocMoiController.text = nuocText;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormLabel(label: 'ĐỐI TƯỢNG THANH TOÁN'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6A3092)),
              ),
            ),
            hint: const Text('Chọn phòng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            value: controller.selectedRoomId,
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6A3092)),
            items: controller.availableRooms.map((room) {
              return DropdownMenuItem<int>(
                value: room['id'],
                child: Text(room['name'].toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.selectRoom(value);
            },
          ),
          const SizedBox(height: 32),
          FormLabel(label: 'CHỈ SỐ ĐIỆN', subLabel: '(⚡ ${formatCurrency(controller.donGiaDien)}/kWh)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ReadingInput(label: 'Cũ: ${controller.soDienCu.toInt()}', value: controller.soDienCu.toInt().toString(), isReadOnly: true)),
              const SizedBox(width: 12),
              Expanded(child: ReadingInput(label: 'Mới *', value: '', controller: _dienMoiController, onChanged: controller.updateDienMoi, focusNode: _dienMoiFocusNode)),
            ],
          ),
          
          const SizedBox(height: 24),
          FormLabel(label: 'CHỈ SỐ NƯỚC', subLabel: '(💧 ${formatCurrency(controller.donGiaNuoc)}/m3)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ReadingInput(label: 'Cũ: ${controller.soNuocCu.toInt()}', value: controller.soNuocCu.toInt().toString(), isReadOnly: true)),
              const SizedBox(width: 12),
              Expanded(child: ReadingInput(label: 'Mới *', value: '', controller: _nuocMoiController, onChanged: controller.updateNuocMoi, focusNode: _nuocMoiFocusNode)),
            ],
          ),
          
          const SizedBox(height: 24),
          const FormLabel(label: 'TIỀN PHÒNG & DỊCH VỤ CỐ ĐỊNH'),
          const SizedBox(height: 12),
          FeeDisplay(text: 'Phòng: ${formatCurrency(controller.tienPhong)}'),
          const SizedBox(height: 16),
          const FormLabel(label: 'PHÍ PHÁT SINH'),
          const SizedBox(height: 8),
          ...List.generate(controller.incidentalItems.length, (index) {
            final item = controller.incidentalItems[index];
            return Padding(
              key: ValueKey(index),
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: item.name,
                      onChanged: (val) => controller.updateIncidentalItemName(index, val),
                      decoration: InputDecoration(
                        hintText: 'Tên dịch vụ/phí',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF6A3092)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: item.amount > 0 ? item.amount.toStringAsFixed(0) : '',
                      keyboardType: TextInputType.number,
                      onChanged: (val) => controller.updateIncidentalItemAmount(index, val),
                      decoration: InputDecoration(
                        hintText: 'Thành tiền',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        suffixText: 'đ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF6A3092)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (controller.incidentalItems.length > 1) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => controller.removeIncidentalItem(index),
                    ),
                  ],
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: controller.addIncidentalItem,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF6A3092)),
                  SizedBox(width: 6),
                  Text(
                    'Thêm chi phí phát sinh',
                    style: TextStyle(
                      color: Color(0xFF6A3092),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const SummaryCard(),
        ],
      ),
    );
  }
}


class FormLabel extends StatelessWidget {
  final String label;
  final String? subLabel;
  const FormLabel({super.key, required this.label, this.subLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A3092),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        if (subLabel != null)
          Text(
            ' $subLabel',
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }
}

class ReadingInput extends StatelessWidget {
  final String label;
  final String value;
  final bool isReadOnly;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const ReadingInput({
    super.key,
    required this.label,
    required this.value,
    this.isReadOnly = false,
    this.onChanged,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isReadOnly ? const Color(0xFFF8F9FA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReadOnly ? Colors.transparent : const Color(0xFF6A3092),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isReadOnly ? Colors.grey : const Color(0xFF6A3092),
              fontWeight: isReadOnly ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          isReadOnly
            ? Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              )
            : TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InvoiceController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'TỔNG CỘNG THANH TOÁN',
            style: TextStyle(
              color: Color(0xFF6A3092),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(controller.tongTien),
            style: const TextStyle(
              color: Color(0xFF6A3092),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '(Bao gồm: Phòng, Điện, Nước, Phụ phí)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String text;
  const CustomDropdown({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6A3092)),
        ],
      ),
    );
  }
}

class FeeDisplay extends StatelessWidget {
  final String text;
  const FeeDisplay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }
}