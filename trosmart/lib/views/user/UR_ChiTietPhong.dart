import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Ur_DatLichXemPhong.dart';
import '../../models/admin/phong_view_model.dart';
import '../../shared/api_constants.dart';
import 'UR_Chat.dart';

class RoomDetailView extends StatelessWidget {
  final PhongViewModel room;

  const RoomDetailView({
    super.key,
    required this.room,
  });

  static const Color primary = Color(0xFFB269F2);
  static const Color primaryDark = Color(0xFF8E64E8);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFF1F1F4);

  String _money(num value) {
    final raw = value.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '$bufferđ';
  }

  String get _fullPrice => _money(room.giaThue);

  bool get _canBook => room.isTrong;

  String get _roomTypeText {
    if (room.soNguoiToiDa <= 1) return 'Phòng đơn';
    if (room.soNguoiToiDa == 2) return 'Phòng 2 người';
    return 'Phòng nhiều người';
  }

  Color get _statusColor {
    if (room.isTrong) return const Color(0xFF2DBE60);
    if (room.isDangThue) return const Color(0xFF7B61FF);
    if (room.isBaoTri) return const Color(0xFFFF8A65);
    return primary;
  }

  Color get _statusBg {
    if (room.isTrong) return const Color(0xFFE9FBF4);
    if (room.isDangThue) return const Color(0xFFF0EDFF);
    if (room.isBaoTri) return const Color(0xFFFFF2EB);
    return const Color(0xFFF7F0FF);
  }

  String get _availabilityText {
    if (room.isTrong) {
      return 'Phòng đang trống và có thể đặt lịch xem.';
    }

    if (room.isDangThue) {
      return 'Phòng hiện đang có khách thuê.';
    }

    if (room.isBaoTri) {
      return 'Phòng đang bảo trì, chưa thể đặt lịch.';
    }

    return 'Trạng thái phòng chưa xác định.';
  }

 Future<void> _showBookingMessage(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Bốc mã khách đăng nhập từ máy, fallback bằng 1 (khach1) để bao test nghiệm thu
      final int currentMaKhach = prefs.getInt('maKhach') ?? 1;

      if (!context.mounted) return;

      // Đẩy khách sang form đặt lịch kèm trọn bộ tham số phòng đang xem
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UrDatLichXemPhong(
            maPhong: room.maPhong,
            maKhach: currentMaKhach,
            soPhong: room.soPhong,
            tenCoSo: room.tenCoSo,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Lỗi điều hướng luồng đặt lịch: $e");
    }
  }

  Future<void> _showContactMessage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UrChat(
        initialMessage: 'Tôi muốn liên hệ xem phòng ${room.soPhong} - ${room.tenCoSo}',
        receiverId: room.nguoiQuanLyId > 0 ? room.nguoiQuanLyId : 1,
        receiverName: room.tenNguoiQuanLy.isNotEmpty ? room.tenNguoiQuanLy : 'Chủ trọ - Anh An',
      )),
    );
  }

  Future<void> _openMap(BuildContext context) async {
    final query = room.hasLocation
        ? '${room.latitude},${room.longitude}'
        : '${room.tenCoSo}, ${room.diaChi}';

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không mở được Google Maps'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      bottomNavigationBar: _bottomBookingBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imageHero(),
                    const SizedBox(height: 16),

                    _mainInfoCard(context),
                    const SizedBox(height: 16),

                    _overviewGrid(),
                    const SizedBox(height: 18),

                    _sectionTitle('Cơ sở'),
                    const SizedBox(height: 12),
                    _facilityCard(context),

                    const SizedBox(height: 18),

                    if (room.tienIches.isNotEmpty) ...[
                      _sectionTitle('Tiện ích phòng'),
                      const SizedBox(height: 12),
                      _amenitiesCard(),
                      const SizedBox(height: 18),
                    ],

                    _sectionTitle('Vị trí cơ sở'),
                    const SizedBox(height: 12),
                    _mapCard(context),

                    const SizedBox(height: 18),

                    _sectionTitle('Thông tin chi tiết'),
                    const SizedBox(height: 12),
                    _detailInfoCard(),

                    const SizedBox(height: 18),

                    _sectionTitle('Tình trạng hiện tại'),
                    const SizedBox(height: 12),
                    _availabilityCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: textDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Chi tiết phòng ${room.soPhong}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  primaryDark,
                  primary,
                ],
              ),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageHero() {
    final imageUrl = room.hinhAnhPhong?.trim();
    final formattedPath = ApiConstants.formatImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (formattedPath != null && formattedPath.isNotEmpty)
              Image.network(
                formattedPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(
                      color: primary,
                      strokeWidth: 2,
                    ),
                  );
                },
              )
            else
              _imagePlaceholder(),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 14,
              left: 14,
              child: _statusBadge(),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phòng ${room.soPhong}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    room.tenCoSo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          room.diaChi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE9FBF4),
            Color(0xFFF2E9FA),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 72,
          color: primary,
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        room.displayStatus,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _mainInfoCard(BuildContext context) {
    return _whiteBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GIÁ THUÊ',
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  _fullPrice,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '/tháng',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _availabilityText,
            style: TextStyle(
              color: _statusColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContactMessage(context),
                  icon: const Icon(
                    Icons.phone_outlined,
                    size: 18,
                  ),
                  label: const Text('Liên hệ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _canBook ? () => _showBookingMessage(context) : null,
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                  ),
                  label: const Text('Đặt lịch xem'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD7D7DD),
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.48,
      children: [
        _infoCard(
          icon: Icons.square_foot_rounded,
          label: 'DIỆN TÍCH',
          value: room.dienTichText,
        ),
        _infoCard(
          icon: Icons.groups_2_outlined,
          label: 'SỨC CHỨA',
          value: '${room.soNguoiToiDa} người',
        ),
        _infoCard(
          icon: Icons.meeting_room_outlined,
          label: 'LOẠI PHÒNG',
          value: _roomTypeText,
        ),
        _infoCard(
          icon: Icons.layers_outlined,
          label: 'TẦNG',
          value: '${room.tang}',
        ),
      ],
    );
  }

  Widget _facilityCard(BuildContext context) {
    final imageUrl = room.hinhAnhCoSo?.trim();
    final formattedPath = ApiConstants.formatImageUrl(imageUrl);

    return _whiteBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 78,
              height: 78,
              child: formattedPath != null && formattedPath.isNotEmpty
                  ? Image.network(
                      formattedPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _facilityPlaceholder(),
                    )
                  : _facilityPlaceholder(),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.tenCoSo,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  room.diaChi,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => _openMap(context),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: primary,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Mở Google Maps',
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

  Widget _facilityPlaceholder() {
    return Container(
      color: const Color(0xFFF2E9FA),
      child: const Icon(
        Icons.business_rounded,
        color: primary,
        size: 34,
      ),
    );
  }

  Widget _amenitiesCard() {
    return _whiteBox(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: room.tienIches.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF2E9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primary.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: primary,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF7B2CBF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= MAP CARD FIX =================

  Widget _mapCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMap(context),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE9FBF4),
                        Color(0xFFF7F0FF),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: CustomPaint(
                  painter: _MapPatternPainter(),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nhấn để mở Google Maps',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2E9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: primary,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.tenCoSo,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.diaChi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.open_in_new_rounded,
                        color: primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================================================

  Widget _detailInfoCard() {
    return _whiteBox(
      child: Column(
        children: [
          _detailRow('Mã phòng', '${room.maPhong}'),
          _divider(),
          _detailRow('Số phòng', room.soPhong),
          _divider(),
          _detailRow('Mã cơ sở', '${room.maCoSo}'),
          _divider(),
          _detailRow('Cơ sở', room.tenCoSo),
          _divider(),
          _detailRow('Địa chỉ', room.diaChi),
          _divider(),
          _detailRow(
            'Trạng thái',
            room.displayStatus,
            valueColor: _statusColor,
          ),
          _divider(),
          _detailRow('Giá thuê', _fullPrice),
          _divider(),
          _detailRow('Diện tích', room.dienTichText),
          _divider(),
          _detailRow(
            'Số người tối đa',
            '${room.soNguoiToiDa} người',
          ),
          _divider(),
          _detailRow('Tầng', '${room.tang}'),

          if (room.hasLocation) ...[
            _divider(),
            _detailRow('Vĩ độ', room.latitude.toString()),
            _divider(),
            _detailRow('Kinh độ', room.longitude.toString()),
          ],
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    return _whiteBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              room.isTrong
                  ? Icons.check_circle_outline_rounded
                  : room.isDangThue
                      ? Icons.person_outline_rounded
                      : Icons.build_circle_outlined,
              color: _statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.displayStatus,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _availabilityText,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primary,
            size: 20,
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.45),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? textDark,
              fontSize: 12.8,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 1,
        color: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _whiteBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _bottomBookingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(
          top: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GIÁ THUÊ',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: room.giaThueText,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const TextSpan(
                          text: '/tháng',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed:
                    _canBook ? () => _showBookingMessage(context) : null,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                ),
                label: Text(
                  _canBook
                      ? 'Đặt lịch xem'
                      : 'Không khả dụng',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD7D7DD),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final smallRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22);

    canvas.drawLine(
      Offset(-20, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.05),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.08, size.height + 10),
      Offset(size.width * 0.92, -10),
      roadPaint,
    );

    canvas.drawLine(
      Offset(-10, size.height * 0.72),
      Offset(size.width + 10, size.height * 0.58),
      smallRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.22, -10),
      Offset(size.width * 0.55, size.height + 10),
      smallRoadPaint,
    );

    for (double x = 20; x < size.width; x += 50) {
      for (double y = 20; y < size.height; y += 50) {
        canvas.drawCircle(
          Offset(x, y),
          2,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}