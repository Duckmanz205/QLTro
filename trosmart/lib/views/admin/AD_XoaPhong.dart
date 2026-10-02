import 'package:flutter/material.dart';

import '../../logic/admin/phong_service.dart';
import '../../models/admin/phong_model.dart';

class DeletePhongView extends StatefulWidget {
  final PhongModel room;
  final String tenCoSo;

  const DeletePhongView({
    super.key,
    required this.room,
    required this.tenCoSo,
  });

  @override
  State<DeletePhongView> createState() => _DeletePhongViewState();
}

class _DeletePhongViewState extends State<DeletePhongView> {
  final PhongService _service = PhongService();
  final TextEditingController _reasonController = TextEditingController();

  bool _confirmed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần xác nhận trước khi xóa phòng'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.deletePhong(widget.room.maPhong);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa phòng')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa phòng: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final statusStyle = _statusStyle(room.statusLabel);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackRow(),
              const SizedBox(height: 14),
              _buildHeaderCard(),
              const SizedBox(height: 18),
              _buildWarningIcon(),
              const SizedBox(height: 18),
              _buildIntroText(),
              const SizedBox(height: 18),
              _buildInfoCard(room, statusStyle),
              const SizedBox(height: 16),
              _buildReasonBox(),
              const SizedBox(height: 12),
              _buildCheckbox(),
              const SizedBox(height: 24),
              _buildDeleteButton(),
              const SizedBox(height: 12),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackRow() {
    return GestureDetector(
      onTap: _goBack,
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF4D4F),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Xóa phòng',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Center(
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E8),
          borderRadius: BorderRadius.circular(41),
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: Color(0xFFFF4D4F),
          size: 42,
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Bạn có chắc chắn muốn xóa phòng này?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF4D4F),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Hành động này không thể hoàn tác. Dữ liệu ảnh phòng và thông tin phòng sẽ bị xóa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(PhongModel room, _RoomStatusStyle statusStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF4D4F).withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusStyle.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  room.baoTri
                      ? Icons.build_rounded
                      : Icons.meeting_room_outlined,
                  color: statusStyle.mainColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P.${room.soPhong}',
                      style: const TextStyle(
                        color: Color(0xFF191622),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tenCoSo,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusStyle.bgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  room.statusLabel,
                  style: TextStyle(
                    color: statusStyle.mainColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Mã phòng', room.maPhong.toString()),
          const SizedBox(height: 10),
          _infoRow('Mã cơ sở', room.maCoSo.toString()),
          const SizedBox(height: 10),
          _infoRow('Giá thuê', _formatCurrency(room.giaThue)),
          const SizedBox(height: 10),
          _infoRow(
            'Tầng',
            room.tang?.toString() ?? 'Chưa có',
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Số người tối đa',
            room.soNguoiToiDa?.toString() ?? 'Chưa có',
          ),
        ],
      ),
    );
  }

  Widget _buildReasonBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lý do xóa phòng (không bắt buộc)',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF191622),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Gộp phòng, sửa chữa lớn, ngừng khai thác...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.35),
              fontSize: 11.5,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF8A36B0).withOpacity(0.22),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8A36B0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _confirmed,
          activeColor: const Color(0xFFFF4D4F),
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _confirmed = value ?? false);
                },
        ),
        Expanded(
          child: Text(
            'Tôi hiểu rủi ro và xác nhận xóa phòng này.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _delete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D4F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Xác nhận xóa',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _goBack,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7430A3),
          side: const BorderSide(color: Color(0xFF7430A3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Quay lại',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withOpacity(0.48),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF191622),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
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

  _RoomStatusStyle _statusStyle(String status) {
    if (status == 'Đang thuê') {
      return const _RoomStatusStyle(
        mainColor: Color(0xFF19D8B3),
        bgColor: Color(0xFFE7FFF8),
      );
    }

    if (status == 'Trống') {
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