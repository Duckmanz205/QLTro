import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/app_theme.dart';
import '../../widgets/common/app_search_field.dart';
import '../../widgets/chat_widgets.dart';
import '../../logic/admin/chat_controller.dart';
import 'UR_Chat.dart';

class UrDanhSachChat extends StatefulWidget {
  const UrDanhSachChat({super.key});

  @override
  State<UrDanhSachChat> createState() => _UrDanhSachChatState();
}

class _UrDanhSachChatState extends State<UrDanhSachChat> {
  final ChatController _chatController = ChatController();
  int _maKhach = 1;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchChats();
  }

  Future<void> _loadUserAndFetchChats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maKhach = prefs.getInt('ma_khach') ?? 1;
    });
    _chatController.fetchRecentChatsForUser(_maKhach);
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
      child: Scaffold(
        backgroundColor: AppTheme.bgWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text('Danh sách chat', style: AppTheme.headingXl),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppSearchField(
                  hintText: 'Tìm kiếm quản lý...',
                  onChanged: (value) => _chatController.filterUserChats(value),
                ),
              ),
              const SizedBox(height: 12),
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

                    final list = controller.recentChats;
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'Chưa có đoạn chat nào.',
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
                        final name = chat['tenAdmin'] ?? 'Admin';
                        final initials = name.toString().trim().isNotEmpty 
                            ? name.toString().trim()[0].toUpperCase() 
                            : '?';
                        return ChatListItem(
                          initials: initials,
                          name: name,
                          lastMessage: chat['lastMessage'] ?? '',
                          time: _formatTime(chat['ngayGui']),
                          isUnread: chat['isUnread'] ?? false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UrChat(
                                  receiverId: chat['maAdmin'],
                                  receiverName: name,
                                ),
                              ),
                            ).then((_) {
                              // Reload khi quay lại
                              _chatController.fetchRecentChatsForUser(_maKhach);
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
