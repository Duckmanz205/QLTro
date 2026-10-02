import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../logic/admin/co_so_service.dart';
import '../../models/admin/co_so_detail_model.dart';
import '../../shared/api_constants.dart';
import 'AD_ChiTietPhong.dart';
import 'AD_QLPhong.dart';
import 'AD_SuaCoSo.dart';
import 'AD_XoaCoSo.dart';

class CoSoDetailView extends StatefulWidget {
  final int maCoSo;

  const CoSoDetailView({
    super.key,
    required this.maCoSo,
  });

  @override
  State<CoSoDetailView> createState() =>
      _CoSoDetailViewState();
}

class _CoSoDetailViewState
    extends State<CoSoDetailView> {
  final CoSoService _service = CoSoService();

  late Future<CoSoDetailModel> _futureDetail;

  @override
  void initState() {
    super.initState();

    _futureDetail =
        _service.getDetail(widget.maCoSo);
  }

  Future<void> _reload() async {
    setState(() {
      _futureDetail =
          _service.getDetail(widget.maCoSo);
    });
  }

  Future<void> _openPhongDetail(
    CoSoDetailModel coSo,
    PhongMiniModel room,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhongDetailView(
          maPhong: room.maPhong,
          tenCoSo: coSo.tenCoSo,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _reload();
    }
  }

  Future<void> _openPhongManagement(
    CoSoDetailModel coSo,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhongManagementView(
          maCoSo: coSo.maCoSo,
          tenCoSo: coSo.tenCoSo,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F8FB),

      body: SafeArea(
        child: FutureBuilder<CoSoDetailModel>(
          future: _futureDetail,

          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color: Color(0xFF8A36B0),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(
                snapshot.error.toString(),
              );
            }

            if (!snapshot.hasData) {
              return _buildError(
                'Không có dữ liệu cơ sở',
              );
            }

            final coSo = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _reload,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  32,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _buildHeader(coSo),

                    const SizedBox(
                        height: 18),

                    _buildFacilityImageBox(
                        coSo),

                    const SizedBox(
                        height: 18),

                    _buildStatsCard(coSo),

                    const SizedBox(
                        height: 18),

                    _sectionTitle(
                      'THÔNG TIN QUẢN LÝ',
                    ),

                    const SizedBox(
                        height: 10),

                    _buildManagerCard(coSo),

                    const SizedBox(
                        height: 18),

                    _sectionTitle(
                      'TIỆN ÍCH CƠ SỞ',
                    ),

                    const SizedBox(
                        height: 10),

                    _buildTienIchBox(coSo),

                    const SizedBox(
                        height: 18),

                    _buildRoomTitle(coSo),

                    const SizedBox(
                        height: 10),

                    _buildRoomList(coSo),

                    const SizedBox(
                        height: 18),

                    _sectionTitle(
                      'VỊ TRÍ TRÊN BẢN ĐỒ',
                    ),

                    const SizedBox(
                        height: 10),

                    _buildMapBox(coSo),

                    const SizedBox(
                        height: 18),

                    _buildActionButtons(
                        coSo),

                    const SizedBox(
                        height: 22),

                    _buildViewRoomsButton(
                        coSo),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      CoSoDetailModel coSo) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        18,
        22,
        18,
        24,
      ),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8E64B7),
            Color(0xFFA47BC4),
          ],
        ),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pop(context),

            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Icon(
                  Icons
                      .arrow_back_ios_new_rounded,
                  size: 20,
                  color: Colors.white,
                ),

                SizedBox(width: 6),

                Text(
                  'Quay lại',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            coSo.tenCoSo,

            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            coSo.diaChi,

            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.85),
              fontSize: 12.5,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityImageBox(
    CoSoDetailModel coSo,
  ) {
    return Container(
      width: double.infinity,
      height: 190,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(18),

        child: _buildImageByPath(
          coSo.hinhAnhCoSo,
        ),
      ),
    );
  }

  Widget _buildImageByPath(
      String? path) {
    final formattedPath = ApiConstants.formatImageUrl(path);
    if (formattedPath == null || formattedPath.isEmpty) {
      return _facilityPlaceholder();
    }

    if (formattedPath.startsWith(
        'assets/')) {
      return Image.asset(
        formattedPath,
        fit: BoxFit.cover,

        errorBuilder:
            (_, __, ___) =>
                _facilityPlaceholder(),
      );
    }

    return Image.network(
      formattedPath,
      fit: BoxFit.cover,

      errorBuilder:
          (_, __, ___) =>
              _facilityPlaceholder(),
    );
  }

  Widget _facilityPlaceholder() {
    return Container(
      color: const Color(0xFFF0E9F8),

      child: const Center(
        child: Icon(
          Icons
              .add_photo_alternate_outlined,
          color: Color(0xFF8A36B0),
          size: 42,
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      CoSoDetailModel coSo) {
    return Container(
      height: 82,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(19),
      ),

      child: Row(
        children: [
          Expanded(
            child: _statItem(
              label: 'TỔNG PHÒNG',
              value:
                  '${coSo.tongPhong}',
              valueColor:
                  const Color(
                      0xFF161622),
            ),
          ),

          _divider(),

          Expanded(
            child: _statItem(
              label: 'TRỐNG',
              value:
                  '${coSo.phongTrong}',
              valueColor:
                  const Color(
                      0xFF2DBE60),
            ),
          ),

          _divider(),

          Expanded(
            child: _statItem(
              label: 'ĐÃ THUÊ',
              value:
                  '${coSo.daThue}',
              valueColor:
                  const Color(
                      0xFF7B2CBF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Text(
          label,

          style: TextStyle(
            color: Colors.black
                .withOpacity(0.32),
            fontSize: 9.5,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          value,

          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 42,
      color:
          Colors.black.withOpacity(0.06),
    );
  }

  Widget _sectionTitle(
      String title) {
    return Text(
      title,

      style: const TextStyle(
        color: Color(0xFF7B2CBF),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildManagerCard(
      CoSoDetailModel coSo) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          _infoRow(
            'Loại hình',
            coSo.loaiHinh,
          ),

          const SizedBox(height: 14),

          _infoRow(
            'Quản lý',
            coSo.tenQuanLy ??
                'Chưa có',
          ),

          const SizedBox(height: 14),

          _infoRow(
            'Liên hệ',
            coSo.soDienThoaiQuanLy ??
                'Chưa có',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 90,

          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.black
                  .withOpacity(0.48),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTienIchBox(
      CoSoDetailModel coSo) {
    if (coSo.tienIches.isEmpty) {
      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
                  16),
        ),

        child: const Text(
          'Cơ sở này chưa có tiện ích',
        ),
      );
    }

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Wrap(
        spacing: 8,
        runSpacing: 8,

        children:
            coSo.tienIches.map((item) {
          return Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color:
                  const Color(0xFFF2E9FA),

              borderRadius:
                  BorderRadius.circular(
                      18),
            ),

            child: Text(
              item.tenTienIch,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoomTitle(
      CoSoDetailModel coSo) {
    return Text(
      'DANH SÁCH PHÒNG (${coSo.phongs.length})',

      style: const TextStyle(
        color: Color(0xFF7B2CBF),
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildRoomList(
      CoSoDetailModel coSo) {
    final rooms =
        coSo.phongs.take(4).toList();

    if (rooms.isEmpty) {
      return _emptyRoomBox();
    }

    return Column(
      children:
          rooms.map((room) {
        return _buildRoomPreviewCard(
          coSo,
          room,
        );
      }).toList(),
    );
  }

  Widget _buildRoomPreviewCard(
    CoSoDetailModel coSo,
    PhongMiniModel room,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(16),

      onTap: () =>
          _openPhongDetail(coSo, room),

      child: Container(
        margin:
            const EdgeInsets.only(
                bottom: 10),

        padding:
            const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
                  16),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              color: Color(0xFF8A36B0),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'Phòng ${room.soPhong}',
              ),
            ),

            _roomStatusBadge(room),
          ],
        ),
      ),
    );
  }

  Widget _roomStatusBadge(
      PhongMiniModel room) {
    final isTrong = room.trong;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: isTrong
            ? Colors.green.shade100
            : Colors.purple.shade100,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        isTrong
            ? 'Trống'
            : 'Đang thuê',
      ),
    );
  }

  // ================= MAP FIX 403 =================

  Widget _buildMapBox(
      CoSoDetailModel coSo) {
    if (coSo.latitude == null ||
        coSo.longitude == null) {
      return _mapPlaceholder();
    }

    final point = LatLng(
      coSo.latitude!,
      coSo.longitude!,
    );

    return Container(
      height: 220,
      width: double.infinity,

      clipBehavior: Clip.antiAlias,

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 16,
        ),

        children: [
          TileLayer(
            urlTemplate:
                'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',

            userAgentPackageName:
                'com.trosmart.app',

            maxZoom: 19,
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 40,
                height: 40,

                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      height: 220,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAE7F8),
            Color(0xFFDCD5F4),
          ],
        ),

        borderRadius:
            BorderRadius.circular(15),
      ),

      child: const Center(
        child: Text(
          'Chưa có tọa độ bản đồ',
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      CoSoDetailModel coSo) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final result =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditCoSoView(
                    coSo: coSo,
                  ),
                ),
              );

              if (result == true) {
                _reload();
              }
            },

            child:
                const Text('Chỉnh sửa'),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          DeleteCoSoView(
                    coSo: coSo,
                  ),
                ),
              );

              if (!mounted) return;

              if (result == true) {
                Navigator.pop(
                  context,
                  true,
                );
              }
            },

            child: const Text('Xóa'),
          ),
        ),
      ],
    );
  }

  Widget _buildViewRoomsButton(
      CoSoDetailModel coSo) {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton.icon(
        onPressed: () =>
            _openPhongManagement(
                coSo),

        icon: const Icon(
          Icons.meeting_room_rounded,
        ),

        label: const Text(
          'Xem danh sách phòng',
        ),
      ),
    );
  }

  Widget _emptyRoomBox() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(13),
      ),

      child: const Text(
        'Cơ sở này chưa có phòng',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(26),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: Color(0xFF8A36B0),
            ),

            const SizedBox(height: 12),

            const Text(
              'Không thể tải chi tiết cơ sở',
              style: TextStyle(
                fontWeight:
                    FontWeight.w900,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _reload,

              child:
                  const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}