import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../shared/app_theme.dart';
import '../../widgets/chat_widgets.dart';
import '../../logic/admin/chat_controller.dart';
import '../../models/tin_nhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrChat extends StatefulWidget {
  final String? initialMessage;
  final int receiverId;
  final String receiverName;
  
  const UrChat({
    super.key, 
    this.initialMessage,
    this.receiverId = 1,
    this.receiverName = 'Chủ trọ - Anh An',
  });

  @override
  State<UrChat> createState() => _UrChatState();
}

class _UrChatState extends State<UrChat> {
  final ChatController _chatController = ChatController();
  final TextEditingController _msgController = TextEditingController();
  int _maKhach = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _msgController.text = widget.initialMessage!;
    }
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maKhach = prefs.getInt('ma_khach') ?? 1;
    });
    _chatController.fetchChatHistory(widget.receiverId, _maKhach);
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    
    final newMsg = TinNhan(
      maTinNhan: 0,
      maNguoiGui: _maKhach,
      vaiTroNguoiGui: 'User',
      maNguoiNhan: widget.receiverId,
      vaiTroNguoiNhan: 'Admin',
      noiDung: _msgController.text.trim(),
      ngayGui: DateTime.now().toIso8601String(),
      daDoc: false,
    );

    _msgController.clear();
    await _chatController.sendMessage(newMsg);
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
            children: [
              _ContactInfoBar(
                receiverName: widget.receiverName,
              ),
              Expanded(
                child: Container(
                  color: AppTheme.bgLight,
                  child: Consumer<ChatController>(
                    builder: (context, controller, child) {
                      if (controller.isLoading && controller.currentChatHistory.isEmpty) {
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

                      final history = controller.currentChatHistory;
                      if (history.isEmpty) {
                        return const Center(child: Text('Hãy gửi lời chào đến chủ trọ!'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final msg = history[index];
                          final isSentByUser = msg.vaiTroNguoiGui == 'User' && msg.maNguoiGui == _maKhach;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ChatBubble(
                              message: msg.noiDung,
                              time: _formatTime(msg.ngayGui),
                              isSent: isSentByUser,
                              backgroundColor: isSentByUser ? const Color(0xFF8B5CF6) : Colors.white,
                              textColor: isSentByUser ? Colors.white : const Color(0xFF1F2937),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              ChatInputBar(
                controller: _msgController,
                hintText: 'Nhập tin nhắn...',
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfoBar extends StatelessWidget {
  final String receiverName;

  const _ContactInfoBar({
    Key? key,
    required this.receiverName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.bgGray100),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: AppTheme.bgGray100,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: AppTheme.bgGray100),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: AppTheme.deepPurple,
                  size: 24,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: AppTheme.statusGreen,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverName,
                  style: AppTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Online',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.statusGreenText,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.info_outline, size: 24, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}