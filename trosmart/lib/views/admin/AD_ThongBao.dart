import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_colors.dart';
import '../../widgets/common/admin/custom_app_bar.dart';
import 'AD_LichCongViec.dart';

import '../../models/thong_bao.dart';
import '../../services/thong_bao_service.dart';
import '../../services/co_so_service.dart';
import '../../models/co_so.dart';
import '../../models/admin/admin_pages.dart';

class AD_ThongBao extends StatefulWidget {
  final Function(String)? onNavigate;
  const AD_ThongBao({super.key, this.onNavigate});

  @override
  State<AD_ThongBao> createState() => _AD_ThongBaoState();
}

class _AD_ThongBaoState extends State<AD_ThongBao> {
  late Future<List<ThongBao>> _futureThongBao;
  String _searchText = '';
  String _selectedTab = 'Tất cả';
  int? selectedMaCoSo;

  @override
  void initState() {
    super.initState();
    _loadThongBaos();
  }

  void _loadThongBaos() {
    setState(() {
      _futureThongBao = ThongBaoService().getAllThongBao();
    });
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String targetType = 'Cá nhân';
    int? selectedMaKhach;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Tạo thông báo mới', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: targetType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Gửi đến', 
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cá nhân', child: Text('Cá nhân')),
                        DropdownMenuItem(value: 'Cả cơ sở', child: Text('Cả cơ sở')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => targetType = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề', 
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Nội dung', 
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (targetType == 'Cá nhân') ...[
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: ThongBaoService().getDanhSachKhach(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Không tải được danh sách khách thuê.', style: TextStyle(color: Colors.red));
                          }
                          final List<Map<String, dynamic>> khachList = snapshot.data!;
                          
                          // Mặc định chọn người đầu tiên
                          if (selectedMaKhach == null || !khachList.any((k) => k['maKhach'] == selectedMaKhach)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                selectedMaKhach = khachList.first['maKhach'];
                              });
                            });
                          }

                          return DropdownButtonFormField<int>(
                            value: selectedMaKhach ?? khachList.first['maKhach'],
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Chọn Khách / Phòng', 
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: khachList.map((khach) {
                              return DropdownMenuItem<int>(
                                value: khach['maKhach'],
                                child: Text('${khach['hoTen']} - P.${khach['soPhong']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => selectedMaKhach = value);
                            },
                          );
                        },
                      ),
                    ] else ...[
                      FutureBuilder<List<CoSo>>(
                        future: CoSoService().getAllCoSo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Không tải được danh sách cơ sở.', style: TextStyle(color: Colors.red));
                          }
                          final coSoList = snapshot.data!;
                          
                          if (selectedMaCoSo == null || !coSoList.any((c) => c.maCoSo == selectedMaCoSo)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                selectedMaCoSo = coSoList.first.maCoSo;
                              });
                            });
                          }

                          return DropdownButtonFormField<int>(
                            value: selectedMaCoSo ?? coSoList.first.maCoSo,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Chọn cơ sở', 
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: coSoList.map((cs) {
                              return DropdownMenuItem<int>(
                                value: cs.maCoSo,
                                child: Text(cs.tenCoSo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => selectedMaCoSo = value);
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Hủy', style: GoogleFonts.inter(color: Colors.grey[700])),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D28D9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () async {
                            if (titleController.text.isEmpty || contentController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
                              );
                              return;
                            }
                            
                            if (targetType == 'Cá nhân' && selectedMaKhach == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng đợi load danh sách khách!')),
                              );
                              return;
                            }

                            try {
                              if (targetType == 'Cả cơ sở') {
                                // Tải danh sách khách thuê có phòng
                                final khachList = await ThongBaoService().getDanhSachKhach();
                                if (khachList.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Không tìm thấy khách thuê để gửi!')),
                                  );
                                  return;
                                }

                                // Gửi thông báo song song đến tất cả khách hàng trong danh sách
                                final futures = khachList.map((k) {
                                  final maK = k['maKhach'] as int;
                                  final newTb = ThongBao(
                                    maThongBao: 0,
                                    maKhach: maK,
                                    tieuDe: titleController.text,
                                    noiDung: contentController.text,
                                    loaiThongBao: 'Cơ sở',
                                    daDoc: false,
                                  );
                                  return ThongBaoService().sendThongBao(newTb);
                                });

                                await Future.wait(futures);
                                
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã gửi thông báo đến cả cơ sở thành công!')),
                                );
                                _loadThongBaos();
                              } else {
                                final newTb = ThongBao(
                                  maThongBao: 0,
                                  maKhach: selectedMaKhach!,
                                  tieuDe: titleController.text,
                                  noiDung: contentController.text,
                                  loaiThongBao: 'Cá nhân',
                                  daDoc: false,
                                );

                                final success = await ThongBaoService().sendThongBao(newTb);
                                if (success) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã gửi thông báo cá nhân thành công!')),
                                  );
                                  _loadThongBaos();
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          },
                          child: Text('Gửi', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailDialog(ThongBao tb) {
    final isSystem = tb.tieuDe.toLowerCase().contains("thanh toán") ||
        tb.tieuDe.toLowerCase().contains("sự cố") ||
        tb.tieuDe.toLowerCase().contains("lịch hẹn") ||
        tb.tieuDe.toLowerCase().contains("đặt lịch");

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isSystem ? Colors.green : const Color(0xFF6D28D9)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSystem ? 'Hệ thống/Admin' : 'Gửi khách thuê',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSystem ? Colors.green : const Color(0xFF6D28D9),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tb.tieuDe,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tb.ngayGui != null 
                      ? 'Gửi lúc: ${tb.ngayGui!.hour.toString().padLeft(2, '0')}:${tb.ngayGui!.minute.toString().padLeft(2, '0')}, ${tb.ngayGui!.day}/${tb.ngayGui!.month}/${tb.ngayGui!.year}' 
                      : 'Gửi lúc: Vừa xong',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  tb.noiDung ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                if (tb.tieuDe.toLowerCase().contains('lịch hẹn') || 
                    tb.tieuDe.toLowerCase().contains('đặt lịch') ||
                    (tb.noiDung ?? '').toLowerCase().contains('xem phòng')) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Đóng dialog chi tiết
                        if (widget.onNavigate != null) {
                          widget.onNavigate!(AdminPages.lichCongViec);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdLichCongViec(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D28D9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Xem lịch công việc',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Đóng',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab(String tabName) {
    final isSelected = _selectedTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6D28D9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6D28D9) : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          tabName,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông báo',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý và gửi thông báo cho khách thuê',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add, size: 20, color: Colors.white,),
                    label: Text(
                      'Tạo mới', 
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchText = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thông báo...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),
            
            // Category Sliding Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryTab('Tất cả'),
                    const SizedBox(width: 8),
                    _buildCategoryTab('Thông báo Admin'),
                    const SizedBox(width: 8),
                    _buildCategoryTab('Gửi khách thuê'),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: FutureBuilder<List<ThongBao>>(
                future: _futureThongBao,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có thông báo nào.'));
                  }

                  final rawList = snapshot.data!;
                  
                  // Filter by search text
                  var filteredList = rawList.where((tb) {
                    if (_searchText.isEmpty) return true;
                    final query = _searchText.toLowerCase();
                    return tb.tieuDe.toLowerCase().contains(query) ||
                        (tb.noiDung ?? '').toLowerCase().contains(query);
                  }).toList();

                  // Filter by tab selection
                  if (_selectedTab == 'Thông báo Admin') {
                    filteredList = filteredList.where((tb) {
                      final title = tb.tieuDe.toLowerCase();
                      return title.contains('thanh toán') ||
                          title.contains('sự cố') ||
                          title.contains('lịch hẹn') ||
                          title.contains('đặt lịch') ||
                          title.contains('chuyển khoản') ||
                          title.contains('phòng');
                    }).toList();
                  } else if (_selectedTab == 'Gửi khách thuê') {
                    filteredList = filteredList.where((tb) {
                      final title = tb.tieuDe.toLowerCase();
                      return !(title.contains('thanh toán') ||
                          title.contains('sự cố') ||
                          title.contains('lịch hẹn') ||
                          title.contains('đặt lịch') ||
                          title.contains('chuyển khoản') ||
                          title.contains('phòng'));
                    }).toList();
                  }

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy thông báo nào phù hợp.',
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final tb = filteredList[index];
                      final isSystem = tb.tieuDe.toLowerCase().contains('thanh toán') || 
                                       tb.tieuDe.toLowerCase().contains('sự cố') ||
                                       tb.tieuDe.toLowerCase().contains('lịch hẹn') ||
                                       tb.tieuDe.toLowerCase().contains('đặt lịch');
                      final typeColor = isSystem ? Colors.green : Colors.blue;
                      final isAppointment = tb.tieuDe.toLowerCase().contains('lịch hẹn') || 
                                            tb.tieuDe.toLowerCase().contains('đặt lịch') ||
                                            (tb.noiDung ?? '').toLowerCase().contains('xem phòng');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () => _showDetailDialog(tb),
                          child: _buildNotificationCard(
                            title: tb.tieuDe,
                            content: tb.noiDung ?? '',
                            time: tb.ngayGui != null 
                                ? '${tb.ngayGui!.hour.toString().padLeft(2, '0')}:${tb.ngayGui!.minute.toString().padLeft(2, '0')}, ${tb.ngayGui!.day}/${tb.ngayGui!.month}/${tb.ngayGui!.year}' 
                                : '',
                            type: isSystem ? 'Hệ thống/Admin' : 'Gửi khách thuê',
                            typeColor: typeColor,
                            status: tb.daDoc ? 'Đã xem' : 'Chưa xem',
                            actionLabel: isAppointment ? 'XEM LỊCH CÔNG VIỆC' : null,
                            onActionTap: isAppointment
                                ? () {
                                    if (widget.onNavigate != null) {
                                      widget.onNavigate!(AdminPages.lichCongViec);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AdLichCongViec(),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String content,
    required String time,
    required String type,
    required Color typeColor,
    required String status,
    VoidCallback? onActionTap,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: status == 'Đã xem' ? Colors.grey.shade600 : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D28D9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
