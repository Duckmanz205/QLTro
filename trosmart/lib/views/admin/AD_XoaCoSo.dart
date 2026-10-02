import 'package:flutter/material.dart';

import '../../logic/admin/co_so_service.dart';
import '../../models/admin/co_so_detail_model.dart';

class DeleteCoSoView extends StatefulWidget {
  final CoSoDetailModel coSo;

  const DeleteCoSoView({
    super.key,
    required this.coSo,
  });

  @override
  State<DeleteCoSoView> createState() => _DeleteCoSoViewState();
}

class _DeleteCoSoViewState extends State<DeleteCoSoView> {
  final CoSoService _service = CoSoService();

  bool _isLoading = false;

  Future<void> _delete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.deleteCoSo(widget.coSo.maCoSo);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa cơ sở')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goBack() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final coSo = widget.coSo;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
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
              _buildInfoCard(coSo),
              const SizedBox(height: 16),
              _buildWarningBox(coSo),
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
        'Xóa cơ sở',
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
            'Bạn có chắc chắn muốn xóa cơ sở này?',
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
            'Hành động này không thể hoàn tác. Toàn bộ thông tin cơ sở, phòng và hình ảnh liên quan sẽ bị xóa.',
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

  Widget _buildInfoCard(CoSoDetailModel coSo) {
    final managerName = (coSo.tenQuanLy != null && coSo.tenQuanLy!.isNotEmpty)
        ? coSo.tenQuanLy!
        : (coSo.maQuanLy == null ? 'Chưa gán' : 'Mã ${coSo.maQuanLy}');

    final phone = (coSo.soDienThoaiQuanLy != null &&
            coSo.soDienThoaiQuanLy!.isNotEmpty)
        ? coSo.soDienThoaiQuanLy!
        : 'Chưa có';

    final email =
        (coSo.emailQuanLy != null && coSo.emailQuanLy!.isNotEmpty)
            ? coSo.emailQuanLy!
            : 'Chưa có';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF4D4F).withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFFFF4D4F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coSo.tenCoSo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF191622),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coSo.diaChi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('Mã cơ sở', coSo.maCoSo.toString()),
          const SizedBox(height: 10),
          _infoRow(
            'Loại hình',
            coSo.loaiHinh.isEmpty ? 'Chưa có' : coSo.loaiHinh,
          ),
          const SizedBox(height: 10),
          _infoRow('Quản lý', managerName),
          const SizedBox(height: 10),
          _infoRow('SĐT quản lý', phone),
          const SizedBox(height: 10),
          _infoRow('Email quản lý', email),
          const SizedBox(height: 14),
          _buildStatsRow(coSo),
          const SizedBox(height: 14),
          _buildTienIchPreview(coSo),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CoSoDetailModel coSo) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            label: 'Tổng phòng',
            value: coSo.tongPhong.toString(),
            color: const Color(0xFF191622),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statBox(
            label: 'Trống',
            value: coSo.phongTrong.toString(),
            color: const Color(0xFF2DBE60),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statBox(
            label: 'Đã thuê',
            value: coSo.daThue.toString(),
            color: const Color(0xFF7B2CBF),
          ),
        ),
      ],
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTienIchPreview(CoSoDetailModel coSo) {
    if (coSo.tienIches.isEmpty) {
      return _infoRow('Tiện ích', 'Chưa có');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TIỆN ÍCH CƠ SỞ'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coSo.tienIches.take(6).map((item) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E9FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF8A36B0).withOpacity(0.18),
                  ),
                ),
                child: Text(
                  item.tenTienIch,
                  style: const TextStyle(
                    color: Color(0xFF7B2CBF),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox(CoSoDetailModel coSo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF4D4F).withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hệ quả khi xóa cơ sở này:',
            style: TextStyle(
              color: Color(0xFF191622),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _WarningLine(
            text: 'Xóa vĩnh viễn ${coSo.tongPhong} phòng thuộc cơ sở.',
          ),
          const SizedBox(height: 8),
          const _WarningLine(text: 'Xóa toàn bộ hình ảnh liên quan.'),
          const SizedBox(height: 8),
          const _WarningLine(text: 'Dữ liệu đã xóa sẽ không thể khôi phục.'),
        ],
      ),
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.48),
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _WarningLine extends StatelessWidget {
  final String text;

  const _WarningLine({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.circle,
          size: 6,
          color: Color(0xFFFF4D4F),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}