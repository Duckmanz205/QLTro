import 'package:flutter/material.dart';

import '../../logic/admin/phong_service.dart';
import '../../logic/auth/auth_service.dart';
import '../../models/admin/phong_model.dart';
import '../../shared/api_constants.dart';
import 'AD_ThemPhong.dart';
import 'AD_ChiTietPhong.dart';

class PhongManagementView extends StatefulWidget {
  final int? maCoSo;
  final String? tenCoSo;

  const PhongManagementView({super.key, this.maCoSo, this.tenCoSo});

  @override
  State<PhongManagementView> createState() => _PhongManagementViewState();
}

class _PhongManagementViewState extends State<PhongManagementView> {
  final PhongService _service = PhongService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<PhongModel>> _futurePhongs;
  int? _maQuanLy;

  String _keyword = '';
  String _statusFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _futurePhongs = _loadPhongs();
  }

  Future<List<PhongModel>> _loadPhongs() async {
    _maQuanLy = await _authService.getMaQuanLy();
    if (widget.maCoSo != null) {
      return _service.getByCoSo(widget.maCoSo!);
    }
    return _service.getAll(maQuanLy: _maQuanLy);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _futurePhongs = widget.maCoSo != null
          ? _service.getByCoSo(widget.maCoSo!)
          : _service.getAll(maQuanLy: _maQuanLy);
    });
  }

  List<PhongModel> _applyFilter(List<PhongModel> list) {
    return list.where((item) {
      final keyword = _keyword.trim().toLowerCase();

      final matchTienIch = item.tienIches.any(
        (x) => x.toLowerCase().contains(keyword),
      );

      final matchKeyword =
          keyword.isEmpty ||
          item.soPhong.toLowerCase().contains(keyword) ||
          item.trangThai.toLowerCase().contains(keyword) ||
          (item.moTa?.toLowerCase().contains(keyword) ?? false) ||
          (item.tang?.toString().contains(keyword) ?? false) ||
          matchTienIch;

      final matchStatus =
          _statusFilter == 'Tất cả' || item.trangThai == _statusFilter;

      return matchKeyword && matchStatus;
    }).toList();
  }

  int _countStatus(List<PhongModel> list, String status) {
    return list.where((x) => x.trangThai == status).length;
  }

  Future<void> _openAddPhong() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddPhongView(maCoSo: widget.maCoSo, tenCoSo: widget.tenCoSo),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _reload();
    }
  }

  Future<void> _openPhongDetail(PhongModel room) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PhongDetailView(
          maPhong: room.maPhong,
          tenCoSo: widget.tenCoSo ?? room.tenCoSo ?? '',
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
      backgroundColor: const Color(0xFFF8F8FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPhong,
        backgroundColor: const Color(0xFF7430A3),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm phòng',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<PhongModel>>(
          future: _futurePhongs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8A36B0)),
              );
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            final data = snapshot.data ?? [];
            final filteredData = _applyFilter(data);

            return RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackRow(),
                    const SizedBox(height: 14),
                    _buildOverviewText(),
                    _buildTitle(),
                    const SizedBox(height: 10),
                    _buildSubHeader(data.length),
                    const SizedBox(height: 14),
                    _buildStats(data),
                    const SizedBox(height: 14),
                    _buildFilterChips(),
                    const SizedBox(height: 12),
                    _buildSearchBox(),
                    const SizedBox(height: 18),

                    if (filteredData.isEmpty)
                      _buildEmpty()
                    else
                      _buildRoomList(filteredData),
                  ],
                ),
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

  Widget _buildOverviewText() {
    return const Text(
      'TỔNG QUAN',
      style: TextStyle(
        color: Color(0xFF7B2CBF),
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Quản lý phòng',
      style: TextStyle(
        color: Color(0xFF151521),
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildSubHeader(int total) {
    final title = widget.tenCoSo != null
        ? '${widget.tenCoSo} — $total phòng'
        : 'Tất cả cơ sở — $total phòng';
    return Text(
      title,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.65),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildStats(List<PhongModel> list) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            value: '${_countStatus(list, 'Đang thuê')}',
            label: 'Đang thuê',
            color: const Color(0xFF19D8B3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            value: '${_countStatus(list, 'Trống')}',
            label: 'Còn trống',
            color: const Color(0xFFF5A623),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            value: '${_countStatus(list, 'Bảo trì')}',
            label: 'Bảo trì',
            color: const Color(0xFFFF4D4F),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tất cả', 'Đang thuê', 'Trống', 'Bảo trì'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _statusFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _statusFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF7430A3) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF17151F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBox() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _keyword = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm phòng hoặc tiện ích...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomList(List<PhongModel> rooms) {
    return ListView.separated(
      itemCount: rooms.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final room = rooms[index];

        return _RoomCard(room: room, onTap: () => _openPhongDetail(room));
      },
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.meeting_room_outlined, color: Color(0xFF7430A3), size: 40),
          SizedBox(height: 10),
          Text(
            'Không có phòng phù hợp',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(child: Text(error));
  }
}

class _RoomCard extends StatelessWidget {
  final PhongModel room;
  final VoidCallback? onTap;

  const _RoomCard({required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(room);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: _buildImageBox(statusStyle),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_displayRoomName(room.soPhong)}${room.tenCoSo != null && room.tenCoSo!.isNotEmpty ? " - ${room.tenCoSo}" : ""}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusStyle.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    room.trangThai,
                    style: TextStyle(
                      color: statusStyle.mainColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              room.tang != null ? 'Tầng ${room.tang}' : 'Chưa có tầng',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: room.tienIches.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E9FA),
                      borderRadius: BorderRadius.circular(14),
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
            ),

            const SizedBox(height: 14),

            Text(
              _formatCurrency(room.giaThue),
              style: TextStyle(
                color: statusStyle.mainColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'VNĐ / tháng',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.48),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (room.moTa != null && room.moTa!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                room.moTa!,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.55),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(_RoomStatusStyle style) {
    final formattedPath = ApiConstants.formatImageUrl(room.hinhAnhPhong);

    if (formattedPath != null && formattedPath.isNotEmpty) {
      if (formattedPath.startsWith('assets/')) {
        return Image.asset(formattedPath, fit: BoxFit.cover);
      }

      return Image.network(
        formattedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: style.bgColor,
          child: Icon(
            Icons.image_not_supported,
            color: style.mainColor,
            size: 34,
          ),
        ),
      );
    }

    return Container(
      color: style.bgColor,
      child: Icon(
        room.baoTri ? Icons.build_rounded : Icons.home_outlined,
        color: style.mainColor,
        size: 42,
      ),
    );
  }

  String _displayRoomName(String soPhong) {
    final value = soPhong.trim();

    if (value.toLowerCase().startsWith('p.')) {
      return value;
    }

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

    return buffer.toString().split('').reversed.join();
  }

  _RoomStatusStyle _statusStyle(PhongModel room) {
    if (room.trangThai == 'Đang thuê') {
      return const _RoomStatusStyle(
        mainColor: Color(0xFF19D8B3),
        bgColor: Color(0xFFE7FFF8),
      );
    }

    if (room.trangThai == 'Trống') {
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

  const _RoomStatusStyle({required this.mainColor, required this.bgColor});
}
