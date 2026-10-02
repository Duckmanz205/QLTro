import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/admin/phong_service.dart';
import '../../models/admin/phong_view_model.dart';
import '../../shared/api_constants.dart';
import 'UR_ChiTietPhong.dart';
import 'UR_DatLichXemPhong.dart';
class RoomSearchView extends StatefulWidget {
  const RoomSearchView({super.key});

  @override
  State<RoomSearchView> createState() => _RoomSearchViewState();
}

class _RoomSearchViewState extends State<RoomSearchView> {
  final PhongService _service = PhongService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<PhongViewModel>> _futureRooms;

  String _keyword = '';
  String _priceFilter = 'Mức giá';
  String _areaFilter = 'Tất cả khu vực';
  String _sortFilter = 'Mặc định';

  @override
  void initState() {
    super.initState();
    _futureRooms = _service.getPhongView();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _futureRooms = _service.getPhongView();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _keyword = '';
      _searchController.clear();
      _priceFilter = 'Mức giá';
      _areaFilter = 'Tất cả khu vực';
      _sortFilter = 'Mặc định';
    });
  }

  List<String> _getAreas(List<PhongViewModel> rooms) {
    final areas = rooms
        .where((room) => room.isTrong)
        .map((room) => room.diaChi.trim())
        .where((area) => area.isNotEmpty)
        .toSet()
        .toList();

    areas.sort();
    return ['Tất cả khu vực', ...areas];
  }

  List<PhongViewModel> _applyFilter(List<PhongViewModel> rooms) {
    final onlyTrongRooms = rooms.where((room) => room.isTrong).toList();

    final filtered = onlyTrongRooms.where((room) {
      final keyword = _keyword.trim().toLowerCase();

      final matchKeyword = keyword.isEmpty ||
          room.tenCoSo.toLowerCase().contains(keyword) ||
          room.diaChi.toLowerCase().contains(keyword) ||
          room.soPhong.toLowerCase().contains(keyword) ||
          room.trangThai.toLowerCase().contains(keyword) ||
          room.tienIches.any((x) => x.toLowerCase().contains(keyword)) ||
          (room.moTa?.toLowerCase().contains(keyword) ?? false);

      final matchPrice = _priceFilter == 'Mức giá' ||
          (_priceFilter == 'Dưới 2 triệu' && room.giaThue < 2000000) ||
          (_priceFilter == '2 - 3 triệu' &&
              room.giaThue >= 2000000 &&
              room.giaThue <= 3000000) ||
          (_priceFilter == '3 - 4 triệu' &&
              room.giaThue > 3000000 &&
              room.giaThue <= 4000000) ||
          (_priceFilter == 'Trên 4 triệu' && room.giaThue > 4000000);

      final matchArea =
          _areaFilter == 'Tất cả khu vực' || room.diaChi == _areaFilter;

      return matchKeyword && matchPrice && matchArea;
    }).toList();

    switch (_sortFilter) {
      case 'Giá tăng dần':
        filtered.sort((a, b) => a.giaThue.compareTo(b.giaThue));
        break;
      case 'Giá giảm dần':
        filtered.sort((a, b) => b.giaThue.compareTo(a.giaThue));
        break;
      case 'Phòng A-Z':
        filtered.sort((a, b) => a.soPhong.compareTo(b.soPhong));
        break;
      case 'Cơ sở A-Z':
        filtered.sort((a, b) => a.tenCoSo.compareTo(b.tenCoSo));
        break;
      default:
        filtered.sort((a, b) => a.maPhong.compareTo(b.maPhong));
        break;
    }

    return filtered;
  }

  int _countTrong(List<PhongViewModel> rooms) =>
      rooms.where((x) => x.isTrong).length;

  Color _accentColor(PhongViewModel room) {
    return const Color(0xFF34C38F);
  }

  Color _bgColor(PhongViewModel room) {
    return const Color(0xFFE9FBF4);
  }

  void _openRoomDetail(PhongViewModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDetailView(room: room),
      ),
    );
  }

  Future<void> _bookRoom(PhongViewModel room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Bốc mã khách từ phiên đăng nhập, mặc định là 1 (khach1) nếu chạy test máy ảo
      final int currentMaKhach = prefs.getInt('maKhach') ?? 1;

      if (!mounted) return;
      
      // Điều hướng trực tiếp sang trang Đặt lịch của ông với đầy đủ tham số động
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể khởi tạo tiến trình đặt lịch!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<PhongViewModel>>(
            future: _futureRooms,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFB269F2),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              }

              final rooms = snapshot.data ?? [];
              final trongRooms = rooms.where((room) => room.isTrong).toList();
              final areas = _getAreas(rooms);
              final filteredRooms = _applyFilter(rooms);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(trongRooms.length),
                    const SizedBox(height: 16),
                    _buildOverviewCards(trongRooms),
                    const SizedBox(height: 18),
                    _buildSearchPanel(
                      areas,
                      filteredRooms.length,
                      trongRooms.length,
                    ),
                    const SizedBox(height: 12),
                    _buildActiveFilters(),
                    const SizedBox(height: 16),
                    _buildResultHeader(filteredRooms.length),
                    const SizedBox(height: 14),
                    if (filteredRooms.isEmpty)
                      _buildEmpty()
                    else
                      ...filteredRooms.map(
                        (room) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _EnhancedRoomSearchCard(
                            room: room,
                            accentColor: _accentColor(room),
                            bgColor: _bgColor(room),
                            onDetail: () => _openRoomDetail(room),
                            onBook: () => _bookRoom(room),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalRooms) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB269F2),
            Color(0xFF8E64E8),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRA CỨU PHÒNG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tìm phòng trống',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dữ liệu thật từ hệ thống • $totalRooms phòng trống',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(List<PhongViewModel> rooms) {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            label: 'Phòng trống',
            value: '${_countTrong(rooms)}',
            valueColor: const Color(0xFF34C38F),
            bg: const Color(0xFFE9FBF4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _overviewCard(
            label: 'Đang hiển thị',
            value: '${rooms.length}',
            valueColor: const Color(0xFF151521),
            bg: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _overviewCard({
    required String label,
    required String value,
    required Color valueColor,
    required Color bg,
  }) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPanel(
    List<String> areas,
    int filteredCount,
    int totalCount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBox(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _filterDropdown(
                  value: _priceFilter,
                  items: const [
                    'Mức giá',
                    'Dưới 2 triệu',
                    '2 - 3 triệu',
                    '3 - 4 triệu',
                    'Trên 4 triệu',
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _priceFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _filterDropdown(
                  value: areas.contains(_areaFilter)
                      ? _areaFilter
                      : 'Tất cả khu vực',
                  items: areas,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _areaFilter = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _filterDropdown(
                  value: _sortFilter,
                  items: const [
                    'Mặc định',
                    'Giá tăng dần',
                    'Giá giảm dần',
                    'Phòng A-Z',
                    'Cơ sở A-Z',
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _sortFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FB),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    '$filteredCount / $totalCount kết quả',
                    style: const TextStyle(
                      color: Color(0xFF151521),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
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

  Widget _buildSearchBox() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _keyword = value;
          });
        },
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Nhập tên cơ sở, khu vực, mã phòng, tiện ích...',
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.35),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.black.withValues(alpha: 0.35),
            size: 19,
          ),
          suffixIcon: _keyword.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() {
                      _keyword = '';
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
          filled: true,
          fillColor: const Color(0xFFF8F8FB),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(
              color: Color(0xFFB269F2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8F8FB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(
              color: Color(0xFFB269F2),
            ),
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
        ),
        style: const TextStyle(
          color: Color(0xFF151521),
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActiveFilters() {
    final chips = <Map<String, String>>[];

    if (_keyword.isNotEmpty) {
      chips.add({'label': 'Từ khóa: $_keyword', 'type': 'keyword'});
    }
    if (_priceFilter != 'Mức giá') {
      chips.add({'label': _priceFilter, 'type': 'price'});
    }
    if (_areaFilter != 'Tất cả khu vực') {
      chips.add({'label': _areaFilter, 'type': 'area'});
    }
    if (_sortFilter != 'Mặc định') {
      chips.add({'label': _sortFilter, 'type': 'sort'});
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...chips.map((chip) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF2E9FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFB269F2).withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              chip['label']!,
              style: const TextStyle(
                color: Color(0xFF7B2CBF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: _clearAllFilters,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFEF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFF4D4F).withValues(alpha: 0.18),
              ),
            ),
            child: const Text(
              'Xóa bộ lọc',
              style: TextStyle(
                color: Color(0xFFFF4D4F),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultHeader(int resultCount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$resultCount phòng trống phù hợp',
            style: const TextStyle(
              color: Color(0xFF151521),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          'Kéo xuống để làm mới',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.42),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            color: Color(0xFFB269F2),
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'Không tìm thấy phòng trống phù hợp',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thử đổi từ khóa, khu vực hoặc mức giá để tìm thêm kết quả.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB269F2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa bộ lọc'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: Color(0xFFB269F2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải danh sách phòng',
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
                color: Colors.black.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _reload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB269F2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedRoomSearchCard extends StatelessWidget {
  final PhongViewModel room;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onDetail;
  final VoidCallback onBook;

  const _EnhancedRoomSearchCard({
    required this.room,
    required this.accentColor,
    required this.bgColor,
    required this.onDetail,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDetail,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          children: [
            _buildHeroHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  const SizedBox(height: 5),
                  Text(
                    'Phòng ${room.soPhong}',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.44),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTags(),
                  const SizedBox(height: 10),
                  _buildAddress(),
                  if (room.tienIches.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildTienIches(),
                  ],
                  if (room.moTa != null && room.moTa!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      room.moTa!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _buildBottomActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final imageUrl = (room.hinhAnhPhong?.trim().isNotEmpty == true)
        ? room.hinhAnhPhong?.trim()
        : room.hinhAnhCoSo?.trim();
    final formattedPath = ApiConstants.formatImageUrl(imageUrl);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(19),
            topRight: Radius.circular(19),
          ),
          child: SizedBox(
            height: 156,
            width: double.infinity,
            child: formattedPath != null && formattedPath.isNotEmpty
                ? Image.network(
                    formattedPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Container(
                        color: bgColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFB269F2),
                          ),
                        ),
                      );
                    },
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.32),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 13,
          right: 13,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              room.displayStatus,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          color: accentColor,
          size: 58,
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            room.tenCoSo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF151521),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Mã ${room.maPhong}',
            style: const TextStyle(
              color: Color(0xFF151521),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _tag('TẦNG ${room.tang}'),
        _tag(room.dienTichText),
        _tag('Tối đa ${room.soNguoiToiDa} người'),
      ],
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF151521),
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildTienIches() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: room.tienIches.take(6).map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF2E9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB269F2).withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            item,
            style: const TextStyle(
              color: Color(0xFF7B2CBF),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: Colors.black.withValues(alpha: 0.4),
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            room.diaChi,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: room.giaThueText,
                  style: const TextStyle(
                    color: Color(0xFF151521),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' /tháng',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: OutlinedButton(
            onPressed: onDetail,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF151521),
              side: BorderSide(
                color: Colors.black.withValues(alpha: 0.08),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Chi tiết',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB269F2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Đặt xem',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}