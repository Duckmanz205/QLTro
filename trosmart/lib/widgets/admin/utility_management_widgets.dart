import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../shared/app_colors.dart';
import '../../logic/admin/utility_controller.dart';

class PageTitleSection extends StatelessWidget {
  final int month;
  final int year;
  const PageTitleSection({super.key, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý điện nước',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkAccent,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.adminDarkPurple,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'THÁNG ${month.toString().padLeft(2, '0')} / $year',
              style: const TextStyle(
                color: AppColors.adminDarkPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Cập nhật chỉ số tiêu thụ hàng tháng từng phòng trọ.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}

class SaveAllButton extends StatelessWidget {
  final int savedCount;
  final int totalCount;
  final VoidCallback onPressed;
  const SaveAllButton({super.key, required this.savedCount, required this.totalCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.utilityPurpleLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.adminDarkPurple.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.save, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lưu tất cả',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.utilityPurpleDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$savedCount/$totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UtilityStatsGrid extends StatelessWidget {
  final int enteredRooms;
  final int totalRooms;
  final int month;
  final int year;
  const UtilityStatsGrid({super.key, required this.enteredRooms, required this.totalRooms, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildStatCard('Giá điện', '3.500đ', '/ kWh', LucideIcons.zap, Colors.yellow[400]!),
        _buildStatCard('Giá nước', '20.000đ', '/ khối', LucideIcons.droplet, Colors.blue[300]!),
        _buildStatCard('Đã nhập', '$enteredRooms phòng', '/ $totalRooms phòng', LucideIcons.checkCircle, AppColors.accentTeal),
        _buildStatCard('Kỳ thu', 'T${month.toString().padLeft(2, '0')}/$year', '', LucideIcons.calendar, AppColors.accentTeal, isPicker: true),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color iconColor, {bool isPicker = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.utilityPurpleLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      Text(
                        ' $unit',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 9,
                        ),
                      ),
                    if (isPicker)
                      const Icon(LucideIcons.chevronDown, color: AppColors.accentTeal, size: 12),
                  ],
                ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UtilityFilterSection extends StatelessWidget {
  const UtilityFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Tìm phòng, khách thuê...',
                prefixIcon: const Icon(LucideIcons.search, color: Colors.grey, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.utilityBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.utilityBorder),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.utilityBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: controller.selectedCoSoId,
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(LucideIcons.mapPin, color: Colors.grey, size: 20),
                            SizedBox(width: 12),
                            Text('Tất cả cơ sở', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkAccent)),
                          ],
                        ),
                        icon: const Icon(LucideIcons.chevronDown, color: Colors.grey, size: 20),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(LucideIcons.mapPin, color: Colors.grey, size: 20),
                                SizedBox(width: 12),
                                Text('Tất cả cơ sở', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkAccent)),
                              ],
                            ),
                          ),
                          ...controller.facilities.map((facility) {
                            return DropdownMenuItem<int?>(
                              value: facility['maCoSo'] as int?,
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, color: AppColors.adminDarkPurple, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    facility['tenCoSo'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkAccent),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          controller.changeCoSo(value);
                        },
                      ),
                    ),
                  ),
                ),
                if (controller.selectedCoSoId != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _showPriceConfigDialog(context, controller);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.adminDarkPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.settings, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPriceConfigDialog(BuildContext context, UtilityController controller) {
    if (controller.selectedCoSoId == null) return;
    
    // Tìm cơ sở đang chọn để lấy đơn giá hiện tại
    final selectedFacility = controller.facilities.firstWhere(
      (f) => f['maCoSo'] == controller.selectedCoSoId,
      orElse: () => <String, dynamic>{},
    );
    final String facilityName = selectedFacility['tenCoSo'] ?? 'Cơ sở';
    
    // Tìm phòng thuộc cơ sở này để lấy giá trị đơn giá hiện thời của điện và nước
    double currentDien = 3500;
    double currentNuoc = 20000;
    try {
      final room = controller.rooms.firstWhere((r) => r['maCoSo'] == controller.selectedCoSoId);
      currentDien = (room['donGiaDien'] ?? 3500.0).toDouble();
      currentNuoc = (room['donGiaNuoc'] ?? 20000.0).toDouble();
    } catch (_) {}
    
    final dienController = TextEditingController(text: currentDien.toInt().toString());
    final nuocController = TextEditingController(text: currentNuoc.toInt().toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Cấu hình giá: $facilityName',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adminDarkPurple),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              
              // Ô nhập Giá Điện
              const Text('Đơn giá điện (⚡ đ/kWh)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: dienController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập giá điện, ví dụ: 3500',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              
              // Ô nhập Giá Nước
              const Text('Đơn giá nước (💧 đ/m³)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: nuocController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập giá nước, ví dụ: 20000',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () async {
                  final double? dien = double.tryParse(dienController.text);
                  final double? nuoc = double.tryParse(nuocController.text);
                  if (dien == null || nuoc == null || dien < 0 || nuoc < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập đơn giá hợp lệ.'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  
                  Navigator.pop(context); // Đóng bottom sheet
                  
                  final ok = await controller.updateUtilityPrices(controller.selectedCoSoId!, dien, nuoc);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Cập nhật đơn giá cơ sở thành công!' : 'Lỗi cập nhật đơn giá'),
                        backgroundColor: ok ? AppColors.accentTeal : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminDarkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lưu đơn giá', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoomListHeader extends StatelessWidget {
  final int totalRooms;
  const RoomListHeader({super.key, required this.totalRooms});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Danh sách phòng',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          '$totalRooms phòng',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

enum RoomStatus { inputting, calculated, saved, vacant }

class RoomUtilityCard extends StatelessWidget {
  final String roomName;
  final String tenant;
  final String? facilityName;
  final RoomStatus status;
  final String? totalAmount;
  final String? dienCu;
  final String? dienMoi;
  final String? nuocCu;
  final String? nuocMoi;
  final ValueChanged<String>? onDienMoiChanged;
  final ValueChanged<String>? onNuocMoiChanged;
  final VoidCallback? onSave;
  final bool isInvoiceCreated;
  final double donGiaDien;
  final double donGiaNuoc;

  const RoomUtilityCard({
    super.key,
    required this.roomName,
    required this.tenant,
    this.facilityName,
    required this.status,
    this.totalAmount,
    this.dienCu,
    this.dienMoi,
    this.nuocCu,
    this.nuocMoi,
    this.onDienMoiChanged,
    this.onNuocMoiChanged,
    this.onSave,
    this.isInvoiceCreated = false,
    this.donGiaDien = 3500,
    this.donGiaNuoc = 20000,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = status == RoomStatus.vacant ? Colors.grey[400]! : AppColors.utilityPurpleLight;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (status != RoomStatus.vacant)
            BoxShadow(
              color: AppColors.adminDarkPurple.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          roomName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        if (isInvoiceCreated) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(LucideIcons.receipt, color: Colors.greenAccent, size: 10),
                                SizedBox(width: 4),
                                Text('Đã lập HĐ', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ] else if (status == RoomStatus.saved) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(LucideIcons.check, color: AppColors.accentTeal, size: 10),
                                SizedBox(width: 4),
                                Text('Đã lưu', style: TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                        if (status == RoomStatus.vacant) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Trống', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ),
                        ]
                      ],
                    ),
                    Text(
                      tenant,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                    if (facilityName != null && facilityName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                           const Icon(LucideIcons.mapPin, color: Colors.white60, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            facilityName!,
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (status != RoomStatus.vacant && !isInvoiceCreated)
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: Icon(status == RoomStatus.saved ? LucideIcons.edit2 : LucideIcons.save, size: 14),
                  label: Text(status == RoomStatus.saved ? 'Sửa' : 'Lưu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == RoomStatus.saved ? Colors.white.withOpacity(0.1) : AppColors.accentTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (status == RoomStatus.vacant)
            _buildVacantPlaceholder()
          else
            _buildReadingInputs(),
          if (status != RoomStatus.vacant) ...[
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  totalAmount ?? '— đ',
                  style: TextStyle(
                    color: totalAmount != null ? AppColors.accentTeal : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadingInputs() {
    final dCu = int.tryParse(dienCu ?? '0') ?? 0;
    final dMoi = int.tryParse(dienMoi ?? '') ?? 0;
    final nCu = int.tryParse(nuocCu ?? '0') ?? 0;
    final nMoi = int.tryParse(nuocMoi ?? '') ?? 0;

    final hasDien = dienMoi != null;
    final hasNuoc = nuocMoi != null;

    return Row(
      children: [
        Expanded(
          child: _buildInputBox(
            'Điện (kWh)',
            LucideIcons.zap,
            Colors.yellow[400]!,
            dienCu ?? '0',
            dienMoi,
            onChanged: isInvoiceCreated ? null : onDienMoiChanged,
            consumption: hasDien ? '${dMoi - dCu} kWh' : null,
            cost: hasDien ? '${((dMoi - dCu) * donGiaDien).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInputBox(
            'Nước (m³)',
            LucideIcons.droplet,
            Colors.blue[300]!,
            nuocCu ?? '0',
            nuocMoi,
            onChanged: isInvoiceCreated ? null : onNuocMoiChanged,
            consumption: hasNuoc ? '${nMoi - nCu} m³' : null,
            cost: hasNuoc ? '${((nMoi - nCu) * donGiaNuoc).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildInputBox(String title, IconData icon, Color iconColor, String oldVal, String? newVal, {String? consumption, String? cost, ValueChanged<String>? onChanged}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.utilityDarkCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Chỉ số cũ', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: Text(oldVal, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          Text('Chỉ số mới', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: newVal != null ? Border.all(color: AppColors.accentTeal.withOpacity(0.3)) : null,
            ),
            child: TextField(
              enabled: onChanged != null,
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              controller: newVal != null ? (TextEditingController(text: newVal)..selection = TextSelection.collapsed(offset: newVal.length)) : null,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Nhập...',
                hintStyle: const TextStyle(color: Colors.white24, fontWeight: FontWeight.normal),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: InputBorder.none,
              ),
            ),
          ),
          if (consumption != null) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiêu thụ', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text(consumption, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chi phí', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text(cost!, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildVacantPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: const Icon(LucideIcons.doorClosed, color: Colors.white38, size: 32),
          ),
          const SizedBox(height: 12),
          const Text('Phòng chưa có khách thuê', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const Text('Không cần nhập chỉ số', style: TextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }
}