import 'package:flutter/material.dart';

import '../../models/admin/co_so_model.dart';
import '../../shared/api_constants.dart';

class CoSoCard extends StatelessWidget {
  final CoSoDashboardModel coSo;
  final VoidCallback? onTap;

  const CoSoCard({
    super.key,
    required this.coSo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(coSo.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE3D5EA),
            width: 1.15,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(statusStyle),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  const SizedBox(height: 6),
                  _buildAddressRow(),
                  const SizedBox(height: 14),
                  _buildStatsRow(),
                  const SizedBox(height: 14),
                  _buildTienIchSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(_CoSoStatusStyle statusStyle) {
    return Container(
      height: 158,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageByPath(
            coSo.hinhAnhCoSo,
            placeholder: _imagePlaceholder(),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                coSo.status,
                style: TextStyle(
                  color: statusStyle.textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.52),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            coSo.tenCoSo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF151421),
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF7430A3),
          size: 22,
        ),
      ],
    );
  }

  Widget _buildAddressRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.black.withOpacity(0.42),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            coSo.diaChi,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.58),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            label: 'Tổng',
            value: '${coSo.tongPhong}',
            valueColor: const Color(0xFF7430A3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _miniStat(
            label: 'Trống',
            value: '${coSo.phongTrong}',
            valueColor: const Color(0xFF14B88A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _miniStat(
            label: 'Đã thuê',
            value: '${coSo.daThue}',
            valueColor: const Color(0xFFFF9F1C),
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8DDF0),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withOpacity(0.48),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTienIchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiện ích',
          style: TextStyle(
            color: Color(0xFF7B2CBF),
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        if (coSo.tienIches.isEmpty)
          Text(
            'Chưa có tiện ích',
            style: TextStyle(
              color: Colors.black.withOpacity(0.45),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coSo.tienIches.take(6).map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8A36B0).withOpacity(0.18),
                  ),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF7B2CBF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildImageByPath(
    String? path, {
    required Widget placeholder,
  }) {
    final formattedPath = ApiConstants.formatImageUrl(path);
    if (formattedPath == null || formattedPath.isEmpty) {
      return placeholder;
    }

    if (formattedPath.startsWith('assets/')) {
      return Image.asset(
        formattedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image.network(
      formattedPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF0E9F8),
            Color(0xFFE1D2F3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          color: Color(0xFF8A36B0),
          size: 40,
        ),
      ),
    );
  }

  _CoSoStatusStyle _statusStyle(String status) {
    switch (status.trim().toLowerCase()) {
      case 'bảo trì':
        return const _CoSoStatusStyle(
          textColor: Color(0xFFFF9F1C),
        );
      case 'hoạt động':
      default:
        return const _CoSoStatusStyle(
          textColor: Color(0xFF14B88A),
        );
    }
  }
}

class _CoSoStatusStyle {
  final Color textColor;

  const _CoSoStatusStyle({
    required this.textColor,
  });
}