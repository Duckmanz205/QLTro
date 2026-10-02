import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/admin/add_invoice_widgets.dart';
import '../../logic/admin/invoice_controller.dart';
import '../../logic/auth/auth_service.dart';
import '../../logic/admin/manager_bank_service.dart';
import '../../models/thong_bao.dart';
import '../../services/thong_bao_service.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  bool sendNotify = true;
  int? maQuanLy;
  ManagerBankInfo? bankInfo;
  List<BankModel> banks = [];
  bool isLoadingBank = false;

  @override
  void initState() {
    super.initState();
    _loadManagerAndBankInfo();
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
                              // Hiển thị loading trên màn hình chính
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
                                // Tải lại thông tin
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
    return ChangeNotifierProvider(
      create: (_) => InvoiceController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            // Header Gradient
            const HeaderSection(),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const PageTitleSection(),
                    const SizedBox(height: 20),
                    const InvoiceFormCard(),
                    const SizedBox(height: 30),

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
                                    'Quét QR chuyển khoản',
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

                    // Notify Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gửi thông báo cho khách ngay',
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

                    const SizedBox(height: 20),

                    // Primary Button
                    Consumer<InvoiceController>(
                      builder: (context, controller, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading ||
                                    controller.selectedRoomId == null
                                ? null
                                : () async {
                                    // 1. Thông tin ngân hàng giao dịch không thể để trống
                                    if (bankInfo == null ||
                                        bankInfo!.soTaiKhoan.isEmpty ||
                                        bankInfo!.tenTaiKhoan.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Thông tin ngân hàng giao dịch không thể để trống. Vui lòng thiết lập ở phía dưới!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // 2. Ràng buộc phòng (đã lập hóa đơn, đang trống, hoặc đang bảo trì)
                                    final roomValidationError = controller
                                        .validateRoomForInvoice(
                                          controller.selectedRoomId!,
                                          DateTime.now().month,
                                          DateTime.now().year,
                                        );
                                    if (roomValidationError != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(roomValidationError),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // 3. Chỉ số điện nước mới không thể để trống
                                    if (!controller.isDienMoiEntered) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Chỉ số điện mới không thể để trống!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    if (!controller.isNuocMoiEntered) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Chỉ số nước mới không thể để trống!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // 4. Chỉ số mới không thể nhỏ hơn chỉ số cũ
                                    if (controller.soDienMoi <
                                        controller.soDienCu) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Chỉ số điện mới không thể nhỏ hơn chỉ số điện cũ!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    if (controller.soNuocMoi <
                                        controller.soNuocCu) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Chỉ số nước mới không thể nhỏ hơn chỉ số nước cũ!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // Tiến hành tạo hóa đơn
                                    final newInvoice = await controller
                                        .createInvoice(
                                          maPhong: controller.selectedRoomId!,
                                          thang: DateTime.now().month,
                                          nam: DateTime.now().year,
                                          soDienCu: controller.soDienCu,
                                          soDienMoi: controller.soDienMoi,
                                          soNuocCu: controller.soNuocCu,
                                          soNuocMoi: controller.soNuocMoi,
                                          donGiaDien: controller.donGiaDien,
                                          donGiaNuoc: controller.donGiaNuoc,
                                          phuPhi: controller.phuPhi,
                                        );

                                    if (newInvoice != null) {
                                      // 5. Nếu switch bật thì tiến hành gửi thông báo cho user
                                      if (sendNotify &&
                                          newInvoice.maKhach != null) {
                                        try {
                                          final thongBao = ThongBao(
                                            maThongBao: 0,
                                            maKhach: newInvoice.maKhach!,
                                            tieuDe:
                                                'Hóa đơn tiền phòng tháng ${newInvoice.thang}/${newInvoice.nam} 💸',
                                            noiDung:
                                                'Chào bạn, hóa đơn tháng ${newInvoice.thang}/${newInvoice.nam} '
                                                'của phòng ${newInvoice.tenPhong} đã được lập với tổng tiền '
                                                '${newInvoice.tongTien.toStringAsFixed(0)}đ. Vui lòng thanh toán trước ngày ${newInvoice.hanThanhToanDisplay}.',
                                            daDoc: false,
                                            ngayGui: DateTime.now(),
                                          );
                                          await ThongBaoService().sendThongBao(
                                            thongBao,
                                          );
                                        } catch (e) {
                                          debugPrint(
                                            "Lỗi gửi thông báo tự động: $e",
                                          );
                                        }
                                      }

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tạo hóa đơn thành công!',
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              controller.errorMessage ??
                                                  'Có lỗi xảy ra',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
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
                            child: controller.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Lưu & Xuất hóa đơn',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
