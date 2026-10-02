import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_colors.dart';
import '../../widgets/common/admin/custom_app_bar.dart';
import '../../widgets/admin/utility_management_widgets.dart';
import '../../logic/admin/utility_controller.dart';

class UtilityManagementView extends StatefulWidget {
  final bool isActive;
  const UtilityManagementView({super.key, this.isActive = false});

  @override
  State<UtilityManagementView> createState() => _UtilityManagementViewState();
}

class _UtilityManagementViewState extends State<UtilityManagementView> {
  late UtilityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UtilityController();
  }

  @override
  void didUpdateWidget(covariant UtilityManagementView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.fetchReadings();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: Consumer<UtilityController>(
          builder: (context, controller, _) {
            if (controller.isLoading && controller.rooms.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null && controller.rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => controller.fetchReadings(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Tách phòng theo trạng thái
            final occupiedRooms = controller.rooms
                .where((r) => r['trangThai'] != 'Trống')
                .toList();
            final vacantRooms = controller.rooms
                .where((r) => r['trangThai'] == 'Trống')
                .toList();

            return RefreshIndicator(
              onRefresh: () => controller.fetchReadings(),
              color: const Color(0xFF7430A3),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitleSection(
                      month: controller.selectedMonth,
                      year: controller.selectedYear,
                    ),
                    const SizedBox(height: 20),
                    SaveAllButton(
                      savedCount: controller.savedRooms,
                      totalCount: controller.totalRooms,
                      onPressed: () async {
                        final success = await controller.saveAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Đã lưu tất cả chỉ số!'
                                    : controller.errorMessage ?? 'Lỗi',
                              ),
                              backgroundColor: success
                                  ? AppColors.accentTeal
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    UtilityStatsGrid(
                      enteredRooms: controller.enteredRooms,
                      totalRooms: controller.totalRooms,
                      month: controller.selectedMonth,
                      year: controller.selectedYear,
                    ),
                    const SizedBox(height: 20),
                    const UtilityFilterSection(),
                    const SizedBox(height: 20),
                    RoomListHeader(totalRooms: controller.totalRooms),
                    const SizedBox(height: 12),

                    // Phòng có khách thuê
                    ...occupiedRooms.map((room) {
                      final maPhong = room['maPhong'] as int;
                      final hasSaved =
                          room['chiSoDienMoi'] != null &&
                          room['chiSoNuocMoi'] != null;
                      final hasInput =
                          controller.getDienMoi(maPhong) != null ||
                          controller.getNuocMoi(maPhong) != null;

                      RoomStatus status;
                      if (hasSaved && !hasInput) {
                        status = RoomStatus.saved;
                      } else if (hasInput ||
                          (room['chiSoDienMoi'] != null &&
                              room['chiSoNuocMoi'] == null)) {
                        status = RoomStatus.inputting;
                      } else {
                        status = RoomStatus.inputting;
                      }

                      // Tính tổng tiền
                      final dienCu = room['chiSoDienCu'] ?? 0;
                      final nuocCu = room['chiSoNuocCu'] ?? 0;
                      final dienMoi =
                          controller.getDienMoi(maPhong) ?? room['chiSoDienMoi'];
                      final nuocMoi =
                          controller.getNuocMoi(maPhong) ?? room['chiSoNuocMoi'];

                      String? totalAmount;
                      if (dienMoi != null && nuocMoi != null) {
                        final donGiaDien = (room['donGiaDien'] ?? 3500.0).toDouble();
                        final donGiaNuoc = (room['donGiaNuoc'] ?? 20000.0).toDouble();
                        final tienDien =
                            (dienMoi - dienCu) * donGiaDien;
                        final tienNuoc =
                            (nuocMoi - nuocCu) * donGiaNuoc;
                        final total = tienDien + tienNuoc;
                        totalAmount =
                            '${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
                        status = hasSaved && !hasInput
                            ? RoomStatus.saved
                            : RoomStatus.calculated;
                      }

                      final bool isInvoiceCreated = room['daLapHoaDon'] == true;
                      final donGiaDien = (room['donGiaDien'] ?? 3500.0).toDouble();
                      final donGiaNuoc = (room['donGiaNuoc'] ?? 20000.0).toDouble();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RoomUtilityCard(
                          roomName: 'Phòng ${room['soPhong']}',
                          tenant:
                              '${room['tenKhachThue']?.isNotEmpty == true ? room['tenKhachThue'] : 'Chưa rõ'} - Tầng ${room['tang'] ?? '?'}',
                          facilityName: room['tenCoSo'],
                          status: status,
                          totalAmount: totalAmount,
                          dienCu: dienCu.toString(),
                          dienMoi: dienMoi?.toString(),
                          nuocCu: nuocCu.toString(),
                          nuocMoi: nuocMoi?.toString(),
                          isInvoiceCreated: isInvoiceCreated,
                          donGiaDien: donGiaDien,
                          donGiaNuoc: donGiaNuoc,
                          onDienMoiChanged: (val) =>
                              controller.updateDienMoi(maPhong, val),
                          onNuocMoiChanged: (val) =>
                              controller.updateNuocMoi(maPhong, val),
                          onSave: () async {
                            final ok = await controller.saveRoom(maPhong);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Đã lưu chỉ số Phòng ${room['soPhong']}'
                                        : controller.errorMessage ?? 'Lỗi',
                                  ),
                                  backgroundColor: ok
                                      ? AppColors.accentTeal
                                      : Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }),

                    // Phòng trống
                    ...vacantRooms.map(
                      (room) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RoomUtilityCard(
                          roomName: 'Phòng ${room['soPhong']}',
                          tenant:
                              'Chưa có khách thuê - Tầng ${room['tang'] ?? '?'}',
                          status: RoomStatus.vacant,
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
