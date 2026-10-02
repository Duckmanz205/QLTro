import 'package:flutter/material.dart';

import '../../logic/admin/phong_service.dart';
import '../../models/admin/phong_model.dart';
import '../../shared/api_constants.dart';
import 'AD_SuaPhong.dart';

class PhongDetailView extends StatefulWidget {
  final int maPhong;
  final String tenCoSo;

  const PhongDetailView({
    super.key,
    required this.maPhong,
    required this.tenCoSo,
  });

  @override
  State<PhongDetailView> createState() => _PhongDetailViewState();
}

class _PhongDetailViewState extends State<PhongDetailView> {
  final PhongService _service = PhongService();

  late Future<PhongModel> _futureRoom;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _futureRoom = _service.getDetail(widget.maPhong);
  }

  Future<void> _reloadRoom() async {
    setState(() {
      _futureRoom = _service.getDetail(widget.maPhong);
    });
  }

  Future<List<int>> _mapTienIchNamesToIds(List<String> tienIchNames) async {
    if (tienIchNames.isEmpty) return [];

    final allTienIch = await _service.getTienIchList();
    final selectedNames = tienIchNames.map((e) => e.trim().toLowerCase()).toSet();

    return allTienIch
        .where((e) => selectedNames.contains(e.tenTienIch.trim().toLowerCase()))
        .map((e) => e.maTienIch)
        .toList();
  }

  Future<void> _reloadFromEdit(PhongModel room) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPhongView(
          room: room,
          tenCoSo: widget.tenCoSo,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _traPhong(PhongModel room) async {
    if (room.trong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phòng hiện đã ở trạng thái Trống'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận trả phòng',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Bạn muốn chuyển phòng ${_displayRoomName(room.soPhong)} về trạng thái Trống?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7430A3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final maTienIchIds = await _mapTienIchNamesToIds(room.tienIches);

      await _service.updatePhong(
        maPhong: room.maPhong,
        maCoSo: room.maCoSo,
        soPhong: room.soPhong,
        tang: room.tang,
        dienTich: room.dienTich,
        giaThue: room.giaThue,
        soNguoiToiDa: room.soNguoiToiDa,
        trangThai: 'Trống',
        moTa: room.moTa,
        maTienIchIds: maTienIchIds,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật trạng thái phòng về Trống'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể trả phòng: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: FutureBuilder<PhongModel>(
          future: _futureRoom,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8A36B0),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return _buildError('Không có dữ liệu phòng');
            }

            final room = snapshot.data!;
            final statusStyle = _statusStyle(room);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackRow(),
                  const SizedBox(height: 14),
                  _buildHeaderCard(room),
                  const SizedBox(height: 16),
                  _buildImageCard(room, statusStyle),
                  const SizedBox(height: 14),
                  _buildStatusCard(room, statusStyle),
                  const SizedBox(height: 14),
                  _buildInfoCard(room),
                  const SizedBox(height: 14),
                  _buildTienIchCard(room),
                  const SizedBox(height: 14),
                  _buildDescriptionCard(room),
                  const SizedBox(height: 20),
                  _buildPrimaryButton(
                    text: 'Chỉnh sửa phòng',
                    onTap: _isSubmitting ? null : () => _reloadFromEdit(room),
                  ),
                  const SizedBox(height: 10),
                  _buildOutlineButton(
                    text: room.trong ? 'Phòng đang trống' : 'Trả phòng',
                    onTap: (_isSubmitting || room.trong)
                        ? null
                        : () => _traPhong(room),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackRow() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF191622),
          ),
          SizedBox(width: 6),
          Text(
            'Quay lại',
            style: TextStyle(
              color: Color(0xFF191622),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(PhongModel room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF742EA1),
            Color(0xFF9C4FC1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHI TIẾT PHÒNG',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _displayRoomName(room.soPhong),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.tenCoSo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(PhongModel room, _RoomStatusStyle style) {
    final imagePath = room.hinhAnhPhong?.trim();

    return Container(
      width: double.infinity,
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: style.bgColor,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null && imagePath.isNotEmpty)
            _buildImage(imagePath)
          else
            Center(
              child: Icon(
                room.baoTri ? Icons.build_circle_outlined : Icons.image_outlined,
                color: style.mainColor,
                size: 42,
              ),
            ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                room.statusLabel,
                style: TextStyle(
                  color: style.mainColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    final formattedPath = ApiConstants.formatImageUrl(path) ?? path;
    if (formattedPath.startsWith('assets/')) {
      return Image.asset(
        formattedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF7430A3),
              size: 40,
            ),
          );
        },
      );
    }

    return Image.network(
      formattedPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF7430A3),
            size: 40,
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(PhongModel room, _RoomStatusStyle statusStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusStyle.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              room.baoTri ? Icons.build_rounded : Icons.meeting_room_outlined,
              color: statusStyle.mainColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái hiện tại',
                  style: TextStyle(
                    color: Color(0xFF7A7A85),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.statusLabel,
                  style: TextStyle(
                    color: statusStyle.mainColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(PhongModel room) {
    return _card(
      child: Column(
        children: [
          _sectionTitle('THÔNG TIN PHÒNG'),
          const SizedBox(height: 12),
          _infoRow('Mã phòng', room.maPhong.toString()),
          _divider(),
          _infoRow('Số phòng', room.soPhong),
          _divider(),
          _infoRow('Cơ sở', widget.tenCoSo),
          _divider(),
          _infoRow('Mã cơ sở', room.maCoSo.toString()),
          _divider(),
          _infoRow('Tầng', room.tang?.toString() ?? 'Chưa có'),
          _divider(),
          _infoRow(
            'Diện tích',
            room.dienTich != null
                ? '${room.dienTich!.toStringAsFixed(0)} m²'
                : 'Chưa có',
          ),
          _divider(),
          _infoRow(
            'Số người tối đa',
            room.soNguoiToiDa?.toString() ?? 'Chưa có',
          ),
          _divider(),
          _infoRow('Giá thuê', _formatCurrency(room.giaThue)),
          _divider(),
          _infoRow('Trạng thái', room.statusLabel),
        ],
      ),
    );
  }

  Widget _buildTienIchCard(PhongModel room) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('TIỆN ÍCH PHÒNG'),
          const SizedBox(height: 12),
          if (room.tienIches.isEmpty)
            Text(
              'Phòng này chưa có tiện ích',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.tienIches.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E9FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF8A36B0).withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xFF7B2CBF),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(PhongModel room) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('MÔ TẢ'),
          const SizedBox(height: 12),
          Text(
            (room.moTa != null && room.moTa!.trim().isNotEmpty)
                ? room.moTa!
                : 'Chưa có mô tả cho phòng này.',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.68),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7430A3),
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.46),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF191622),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7430A3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF4D4F),
          side: BorderSide(
            color: onTap == null
                ? const Color(0xFFFF4D4F).withValues(alpha: 0.35)
                : const Color(0xFFFF4D4F),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFF7430A3),
              size: 44,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải chi tiết phòng',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.48),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _reloadRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7430A3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  String _displayRoomName(String soPhong) {
    final value = soPhong.trim();
    if (value.toLowerCase().startsWith('p.')) return value;
    return 'P.$value';
  }

  String _formatCurrency(num value) {
    final text = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()} VNĐ';
  }

  _RoomStatusStyle _statusStyle(PhongModel room) {
    if (room.dangThue) {
      return const _RoomStatusStyle(
        mainColor: Color(0xFF19D8B3),
        bgColor: Color(0xFFE7FFF8),
      );
    }

    if (room.trong) {
      return const _RoomStatusStyle(
        mainColor: Color(0xFFF5A623),
        bgColor: Color(0xFFFFF3D9),
      );
    }

    return const _RoomStatusStyle(
      mainColor: Color(0xFFFF4D4F),
      bgColor: Color(0xFFFFE8E8),
    );
  }
}

class _RoomStatusStyle {
  final Color mainColor;
  final Color bgColor;

  const _RoomStatusStyle({
    required this.mainColor,
    required this.bgColor,
  });
}