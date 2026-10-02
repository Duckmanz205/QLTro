import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/admin/invoice_controller.dart';
import '../../models/admin/invoice_model.dart';
import '../../widgets/admin/add_invoice_widgets.dart';
import '../../logic/auth/auth_service.dart';
import '../../logic/admin/manager_bank_service.dart';

class EditInvoiceScreen extends StatefulWidget {
  final InvoiceModel invoice;
  const EditInvoiceScreen({super.key, required this.invoice});

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  late TextEditingController _dienMoiCtrl;
  late TextEditingController _nuocMoiCtrl;
  late TextEditingController _phuPhiCtrl;
  late TextEditingController _tenPhuPhiCtrl;
  bool sendNotify = true;

  int? maQuanLy;
  ManagerBankInfo? bankInfo;
  List<BankModel> banks = [];
  bool isLoadingBank = false;

  List<IncidentalFeeItem> parseIncidentalFees(String? description, double totalAmount) {
    if (description == null || description.isEmpty) {
      if (totalAmount > 0) {
        return [IncidentalFeeItem(name: 'Phí phát sinh', amount: totalAmount)];
      }
      return [IncidentalFeeItem()];
    }
    
    try {
      final items = <IncidentalFeeItem>[];
      final parts = description.split(',');
      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;
        
        final regex = RegExp(r'^(.*?)\s*\(([\d\.]+)[đVNDvnd\s]*\)$');
        final match = regex.firstMatch(part);
        if (match != null) {
          final name = match.group(1)?.trim() ?? '';
          final amtStr = (match.group(2) ?? '0').replaceAll('.', '');
          final amount = double.tryParse(amtStr) ?? 0.0;
          items.add(IncidentalFeeItem(name: name, amount: amount));
        } else {
          items.add(IncidentalFeeItem(name: part, amount: 0.0));
        }
      }
      if (items.isEmpty) {
        return [IncidentalFeeItem(name: description, amount: totalAmount)];
      }
      return items;
    } catch (_) {
      return [IncidentalFeeItem(name: description, amount: totalAmount)];
    }
  }

  @override
  void initState() {
    super.initState();
    _dienMoiCtrl = TextEditingController(
      text: widget.invoice.soDienMoi.toInt().toString(),
    );
    _nuocMoiCtrl = TextEditingController(
      text: widget.invoice.soNuocMoi.toInt().toString(),
    );
    _phuPhiCtrl = TextEditingController(
      text: widget.invoice.phuPhi > 0
          ? widget.invoice.phuPhi.toStringAsFixed(0)
          : '',
    );
    _tenPhuPhiCtrl = TextEditingController(
      text: widget.invoice.moTaPhuPhi ?? '',
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = Provider.of<InvoiceController>(context, listen: false);
      controller.incidentalItems = parseIncidentalFees(widget.invoice.moTaPhuPhi, widget.invoice.phuPhi);
      setState(() {});
    });

    _loadManagerAndBankInfo();
  }

  @override
  void dispose() {
    _dienMoiCtrl.dispose();
    _nuocMoiCtrl.dispose();
    _phuPhiCtrl.dispose();
    _tenPhuPhiCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadManagerAndBankInfo() async {
    if (!mounted) return;
    setState(() => isLoadingBank = true);
    try {
      maQuanLy = await AuthService().getMaQuanLy();
      if (maQuanLy != null) {
        bankInfo = await ManagerBankService().getManagerBankInfo(maQuanLy!);
      }
      banks = await ManagerBankService().getBanks();
    } catch (e) {
      debugPrint("Error loading bank info: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingBank = false);
      }
    }
  }

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  double _calculatedTotal(BuildContext ctx) {
    final dienMoi =
        double.tryParse(_dienMoiCtrl.text) ?? widget.invoice.soDienMoi;
    final nuocMoi =
        double.tryParse(_nuocMoiCtrl.text) ?? widget.invoice.soNuocMoi;
    
    final controller = ctx.read<InvoiceController>();
    final phuPhi = controller.incidentalItems.fold<double>(0, (sum, item) => sum + item.amount);

    final tienDien =
        (dienMoi - widget.invoice.soDienCu) * widget.invoice.donGiaDien;
    final tienNuoc =
        (nuocMoi - widget.invoice.soNuocCu) * widget.invoice.donGiaNuoc;
    return widget.invoice.tienPhong +
        tienDien +
        tienNuoc +
        phuPhi +
        widget.invoice.tienDichVu;
  }

  void _showEditBankSheet() {
    if (maQuanLy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin Quản lý. Hãy đăng nhập lại!'),
        ),
      );
      return;
    }

    final stkController = TextEditingController(
      text: bankInfo?.soTaiKhoan ?? '',
    );
    final tenTkController = TextEditingController(
      text: bankInfo?.tenTaiKhoan ?? '',
    );
    BankModel? selectedBank;

    if (bankInfo?.maNganHang != null && banks.isNotEmpty) {
      selectedBank = banks.firstWhere(
        (b) => b.maNganHang == bankInfo!.maNganHang,
        orElse: () => banks.first,
      );
    } else if (banks.isNotEmpty) {
      selectedBank = banks.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tài khoản chuyển nhận tiền',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A3092),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thông tin này dùng để sinh mã QR hóa đơn chuyển khoản cho khách thuê.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown chọn ngân hàng
                  const Text(
                    'Ngân hàng',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BankModel>(
                        value: selectedBank,
                        isExpanded: true,
                        hint: const Text('Chọn ngân hàng'),
                        items: banks.map((bank) {
                          return DropdownMenuItem<BankModel>(
                            value: bank,
                            child: Text(
                              '${bank.tenVietTat} - ${bank.tenNganHang}',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedBank = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số tài khoản
                  const Text(
                    'Số tài khoản',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: stkController,
                    decoration: InputDecoration(
                      hintText: 'Nhập số tài khoản ngân hàng',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Tên tài khoản
                  const Text(
                    'Tên tài khoản (Chủ thẻ)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tenTkController,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: NGUYEN VAN A',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 24),

                  // Nút Lưu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          selectedBank == null ||
                              stkController.text.trim().isEmpty ||
                              tenTkController.text.trim().isEmpty
                          ? null
                          : () async {
                              Navigator.pop(context);
                              setState(() => isLoadingBank = true);

                              final success = await ManagerBankService()
                                  .updateManagerBankInfo(
                                    maQuanLy!,
                                    soTaiKhoan: stkController.text.trim(),
                                    tenTaiKhoan: tenTkController.text
                                        .trim()
                                        .toUpperCase(),
                                    maNganHang: selectedBank!.maNganHang,
                                  );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cập nhật thông tin tài khoản thành công!',
                                    ),
                                  ),
                                );
                                await _loadManagerAndBankInfo();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Không thể cập nhật thông tin tài khoản',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                if (mounted) {
                                  setState(() => isLoadingBank = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3092),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          const HeaderSection(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Title Back Row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chỉnh sửa hóa đơn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Mã: #INV-${inv.maHoaDon} | Phòng ${inv.tenPhong}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: StatefulBuilder(
                      builder: (context, setInnerState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Phòng (ReadOnly)
                            const FormLabel(label: 'PHÒNG'),
                            const SizedBox(height: 8),
                            FeeDisplay(
                              text: 'Phòng ${inv.tenPhong} - ${inv.tenCoSo}',
                            ),

                            const SizedBox(height: 20),

                            // Tháng/Năm (ReadOnly)
                            const FormLabel(label: 'KỲ HÓA ĐƠN'),
                            const SizedBox(height: 8),
                            FeeDisplay(text: 'Tháng ${inv.thang}/${inv.nam}'),

                            const SizedBox(height: 24),
                            FormLabel(
                              label: 'CHỈ SỐ ĐIỆN',
                              subLabel:
                                  '(⚡ ${formatCurrency(inv.donGiaDien)}/kWh)',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ReadingInput(
                                    label: 'Cũ: ${inv.soDienCu.toInt()}',
                                    value: inv.soDienCu.toInt().toString(),
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ReadingInput(
                                    label: 'Mới *',
                                    value: _dienMoiCtrl.text,
                                    controller: _dienMoiCtrl,
                                    onChanged: (val) {
                                      setInnerState(() {
                                        _dienMoiCtrl.text = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            FormLabel(
                              label: 'CHỈ SỐ NƯỚC',
                              subLabel:
                                  '(💧 ${formatCurrency(inv.donGiaNuoc)}/m³)',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ReadingInput(
                                    label: 'Cũ: ${inv.soNuocCu.toInt()}',
                                    value: inv.soNuocCu.toInt().toString(),
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ReadingInput(
                                    label: 'Mới *',
                                    value: _nuocMoiCtrl.text,
                                    controller: _nuocMoiCtrl,
                                    onChanged: (val) {
                                      setInnerState(() {
                                        _nuocMoiCtrl.text = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                              const FormLabel(label: 'TIỀN PHÒNG & DỊCH VỤ'),
                            const SizedBox(height: 8),
                            FeeDisplay(
                              text:
                                  'Phòng: ${formatCurrency(inv.tienPhong)}' +
                                  (inv.tienDichVu > 0
                                      ? ' | Dịch vụ: ${formatCurrency(inv.tienDichVu)}'
                                      : ''),
                            ),

                            const SizedBox(height: 16),
                            const FormLabel(label: 'PHÍ PHÁT SINH'),
                            const SizedBox(height: 8),
                            
                            // Retrieve the shared controller instance
                            Builder(
                              builder: (childCtx) {
                                final controller = Provider.of<InvoiceController>(childCtx);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...List.generate(controller.incidentalItems.length, (index) {
                                      final item = controller.incidentalItems[index];
                                      return Padding(
                                        key: ValueKey('incidental_edit_${index}_${controller.incidentalItems.length}'),
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: TextFormField(
                                                initialValue: item.name,
                                                onChanged: (val) {
                                                  controller.updateIncidentalItemName(index, val);
                                                  setInnerState(() {});
                                                },
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
                                                onChanged: (val) {
                                                  controller.updateIncidentalItemAmount(index, val);
                                                  setInnerState(() {});
                                                },
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
                                                onPressed: () {
                                                  controller.removeIncidentalItem(index);
                                                  setInnerState(() {});
                                                },
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }),
                                    GestureDetector(
                                      onTap: () {
                                        controller.addIncidentalItem();
                                        setInnerState(() {});
                                      },
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
                                  ],
                                );
                              }
                            ),

                            const SizedBox(height: 24),

                            // Tổng cộng
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 16,
                              ),
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
                                    formatCurrency(_calculatedTotal(context)),
                                    style: const TextStyle(
                                      color: Color(0xFF6A3092),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '(Bao gồm: Phòng, Điện, Nước, Dịch vụ, Phụ phí)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Textbox chỉnh sửa tài khoản chuyển khoản
                  InkWell(
                    onTap: isLoadingBank ? null : _showEditBankSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F2F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isLoadingBank
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF6A3092),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 36,
                                    color: Color(0xFF6A3092),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tài khoản thanh toán',
                                  style: TextStyle(
                                    color: Color(0xFF6A3092),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bankInfo != null &&
                                          bankInfo!.tenVietTat.isNotEmpty
                                      ? 'Ngân hàng: ${bankInfo!.tenVietTat}'
                                      : 'Ngân hàng: Chưa thiết lập',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bankInfo != null &&
                                          bankInfo!.soTaiKhoan.isNotEmpty
                                      ? 'STK: ${bankInfo!.soTaiKhoan}'
                                      : 'STK: Chưa thiết lập',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notify toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gửi thông báo cập nhật cho khách',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: sendNotify,
                        onChanged: (val) => setState(() => sendNotify = val),
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF6A3092),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Save button
                  Builder(
                    builder: (btnCtx) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            final controller = Provider.of<InvoiceController>(
                              btnCtx,
                              listen: false,
                            );
                            final calculatedPhuPhi = controller.incidentalItems.fold<double>(0, (sum, item) => sum + item.amount);
                            final calculatedMoTa = controller.concatenatedIncidentalDescription;

                            final success = await controller.updateInvoice(
                              maHoaDon: inv.maHoaDon,
                              soDienMoi:
                                  double.tryParse(_dienMoiCtrl.text) ??
                                  inv.soDienMoi,
                              soNuocMoi:
                                  double.tryParse(_nuocMoiCtrl.text) ??
                                  inv.soNuocMoi,
                              phuPhi: calculatedPhuPhi,
                              moTaPhuPhi: calculatedMoTa,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật hóa đơn thành công!'),
                                ),
                              );
                              controller.fetchInvoices(
                                controller.selectedMonth,
                                controller.selectedYear,
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi: ${controller.errorMessage ?? "Không thể cập nhật hóa đơn"}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A3092),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
