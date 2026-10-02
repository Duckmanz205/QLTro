import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/app_theme.dart';
import '../../widgets/common/app_search_field.dart';
import '../../widgets/chat_widgets.dart';
import '../../logic/admin/chat_controller.dart';
import 'AD_ChiTietChat.dart';

class AdChat extends StatefulWidget {
  const AdChat({super.key});

  @override
  State<AdChat> createState() => _AdChatState();
}

class _AdChatState extends State<AdChat> {
  final ChatController _chatController = ChatController();

  @override
  void initState() {
    super.initState();
    _loadAndFetchChats();
  }

  Future<void> _loadAndFetchChats() async {
    final prefs = await SharedPreferences.getInstance();
    final maQuanLy = prefs.getInt('ma_quan_ly') ?? 1;
    _chatController.fetchRecentChats(maQuanLy);
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chatController,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppTheme.bgWhite,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text('Tin nhắn', style: AppTheme.headingXl),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSearchField(
                    hintText: 'Tìm kiếm người...',
                    onChanged: (value) => _chatController.filterChats(value),
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  labelColor: AppTheme.primaryPurple,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.primaryPurple,
                  labelStyle: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Đang thuê'),
                    Tab(text: 'Hết hợp đồng'),
                    Tab(text: 'Quan tâm'),
                  ],
                ),
                Expanded(
                  child: Consumer<ChatController>(
                    builder: (context, controller, child) {
                      if (controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.errorMessage != null) {
                        return Center(
                          child: Text(
                            'Lỗi: ${controller.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      Widget buildList(int category) {
                        final list = controller.recentChats.where((c) => c['category'] == category).toList();
                        if (list.isEmpty) {
                          return Center(
                            child: Text(
                              category == 1 ? 'Không có khách đang thuê.' :
                              category == 2 ? 'Không có khách quan tâm.' :
                              'Không có khách hết hợp đồng.',
                              style: AppTheme.bodyMd.copyWith(color: AppTheme.textMuted),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: list.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
                          itemBuilder: (context, index) {
                            final chat = list[index];
                            final name = chat['tenKhach'] ?? 'Khách';
                            final initials = name.toString().trim().isNotEmpty 
                                ? name.toString().trim()[0].toUpperCase() 
                                : '?';
                            return ChatListItem(
                              initials: initials,
                              name: category == 2 ? name : '$name (P.${chat['soPhong']})',
                              lastMessage: chat['lastMessage'] ?? '',
                              time: _formatTime(chat['ngayGui']),
                              isUnread: chat['isUnread'] ?? false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdChiTietChat(
                                      maKhach: chat['maKhach'],
                                      tenKhach: name,
                                      soPhong: chat['soPhong'].toString(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      return TabBarView(
                        children: [
                          buildList(1), // Khách đang thuê
                          buildList(3), // Khách hết hợp đồng
                          buildList(2), // Khách quan tâm
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
