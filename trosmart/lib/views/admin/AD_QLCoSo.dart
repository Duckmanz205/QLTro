import 'package:flutter/material.dart';

import '../../logic/admin/co_so_service.dart';
import '../../models/admin/co_so_model.dart';
import '../../widgets/admin/co_so_card.dart';
import 'AD_ThemCoSo.dart';
import 'AD_ChiTietCoSo.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/common/admin/custom_app_bar.dart';
import '../../widgets/common/admin/custom_bottom_navigation.dart';

class CoSoManagementView extends StatefulWidget {
  final int maQuanLy;

  const CoSoManagementView({
    super.key,
    required this.maQuanLy,
  });

  @override
  State<CoSoManagementView> createState() => _CoSoManagementViewState();
}

class _CoSoManagementViewState extends State<CoSoManagementView> {
  final CoSoService _service = CoSoService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<CoSoDashboardModel>> _futureCoSos;

  String _keyword = '';
  String _areaFilter = 'Tất cả khu vực';
  String _statusFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _futureCoSos = _service.getDashboard(maQuanLy: widget.maQuanLy);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _futureCoSos = _service.getDashboard(maQuanLy: widget.maQuanLy);
    });
  }

  List<CoSoDashboardModel> _applyFilter(List<CoSoDashboardModel> list) {
    return list.where((item) {
      final keyword = _keyword.trim().toLowerCase();

      final matchKeyword = keyword.isEmpty ||
          item.tenCoSo.toLowerCase().contains(keyword) ||
          item.diaChi.toLowerCase().contains(keyword);

      final matchArea =
          _areaFilter == 'Tất cả khu vực' || item.diaChi == _areaFilter;

      final matchStatus =
          _statusFilter == 'Tất cả' || item.status == _statusFilter;

      return matchKeyword && matchArea && matchStatus;
    }).toList();
  }

  List<String> _getAreas(List<CoSoDashboardModel> list) {
    final areas = list
        .map((item) => item.diaChi.trim())
        .where((area) => area.isNotEmpty)
        .toSet()
        .toList();

    areas.sort();

    return ['Tất cả khu vực', ...areas];
  }

  int _countActive(List<CoSoDashboardModel> list) {
    return list.where((item) => item.status == 'Hoạt động').length;
  }

  int _countMaintenance(List<CoSoDashboardModel> list) {
    return list.where((item) => item.status == 'Bảo trì').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          color: const Color(0xFF8E35B6),
          child: FutureBuilder<List<CoSoDashboardModel>>(
            future: _futureCoSos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8E35B6),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              }

              final data = snapshot.data ?? [];
              final areas = _getAreas(data);
              final filteredData = _applyFilter(data);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding =
                      constraints.maxWidth < 390 ? 14.0 : 18.0;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      14,
                      horizontalPadding,
                      28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 430,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitle(data.length),
                            const SizedBox(height: 14),
                            _buildSummaryRow(data),
                            const SizedBox(height: 16),
                            _buildActionPanel(areas),
                            const SizedBox(height: 20),
                            _buildResultHeader(filteredData.length),
                            const SizedBox(height: 12),
                            if (filteredData.isEmpty)
                              _buildEmpty()
                            else
                              ...filteredData.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: CoSoCard(
                                    coSo: item,
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CoSoDetailView(
                                            maCoSo: item.maCoSo,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        _reload();
                                      }
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(int total) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý cơ sở',
                style: TextStyle(
                  color: Color(0xFF151421),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$total cơ sở đang quản lý',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFB85BDD),
                Color(0xFF7430A3),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE3D5EA),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7430A3).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(List<CoSoDashboardModel> data) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: 'Tổng cơ sở',
            value: '${data.length}',
            icon: Icons.domain_rounded,
            color: const Color(0xFF7430A3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            label: 'Hoạt động',
            value: '${_countActive(data)}',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF14B88A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            label: 'Bảo trì',
            value: '${_countMaintenance(data)}',
            icon: Icons.build_circle_rounded,
            color: const Color(0xFFFF9F1C),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3D5EA),
          width: 1.2,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: color.withOpacity(0.25),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.56),
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(List<String> areas) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE3D5EA),
          width: 1.25,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAddButton(),
          const SizedBox(height: 12),
          _buildSearchBox(),
          const SizedBox(height: 10),
          _buildFilterRow(areas),
        ],
      ),
    );
  }

 Widget _buildAddButton() {
  return SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddCoSoView(
              maQuanLy: widget.maQuanLy,
            ),
          ),
        );

        if (result == true) {
          _reload();
        }
      },
      icon: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 17,
        ),
      ),
      label: const Text(
        'Thêm cơ sở',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C42BA),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  );
}

  Widget _buildSearchBox() {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _keyword = value;
          });
        },
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF17151F),
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cơ sở...',
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.36),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 21,
            color: Colors.black.withOpacity(0.42),
          ),
          filled: true,
          fillColor: const Color(0xFFFAF9FC),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE2D8E8),
              width: 1.15,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF9C42BA),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(List<String> areas) {
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _areaFilter = value;
              });
            },
            itemBuilder: (context) {
              return areas.map((area) {
                return PopupMenuItem<String>(
                  value: area,
                  child: Text(area),
                );
              }).toList();
            },
            child: _filterButton(
              icon: Icons.location_on_outlined,
              label: _areaFilter,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _statusFilter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'Tất cả',
                child: Text('Tất cả'),
              ),
              PopupMenuItem<String>(
                value: 'Hoạt động',
                child: Text('Hoạt động'),
              ),
              PopupMenuItem<String>(
                value: 'Bảo trì',
                child: Text('Bảo trì'),
              ),
            ],
            child: _filterButton(
              icon: Icons.filter_alt_outlined,
              label: _statusFilter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2D8E8),
          width: 1.15,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF9C42BA),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withOpacity(0.68),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 17,
            color: Colors.black.withOpacity(0.38),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(int total) {
    return Row(
      children: [
        const Text(
          'Danh sách cơ sở',
          style: TextStyle(
            color: Color(0xFF151421),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFE3F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE3D5EA),
              width: 1,
            ),
          ),
          child: Text(
            '$total kết quả',
            style: const TextStyle(
              color: Color(0xFF7430A3),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 160),
        const Icon(
          Icons.wifi_off_rounded,
          size: 46,
          color: Color(0xFF9C42BA),
        ),
        const SizedBox(height: 14),
        const Text(
          'Không thể tải dữ liệu cơ sở',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: Color(0xFF151421),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withOpacity(0.48),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _reload,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C42BA),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Thử lại',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3D5EA),
          width: 1.2,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 42,
            color: Color(0xFF9C42BA),
          ),
          SizedBox(height: 10),
          Text(
            'Không có cơ sở phù hợp',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF151421),
            ),
          ),
        ],
      ),
    );
  }
}