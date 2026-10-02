import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/app_theme.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/chat_widgets.dart';
import '../../logic/admin/chat_controller.dart';
import '../../models/tin_nhan.dart';

class AdChiTietChat extends StatefulWidget {
  final int maKhach;
  final String tenKhach;
  final String soPhong;

  const AdChiTietChat({
    super.key,
    required this.maKhach,
    required this.tenKhach,
    required this.soPhong,
  });

  @override
  State<AdChiTietChat> createState() => _AdChiTietChatState();
}

class _AdChiTietChatState extends State<AdChiTietChat> {
  final ChatController _chatController = ChatController();
  final TextEditingController _msgController = TextEditingController();
  int _maAdmin = 1;

  @override
  void initState() {
    super.initState();
    _loadAdminAndFetchHistory();
  }

  Future<void> _loadAdminAndFetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maAdmin = prefs.getInt('ma_quan_ly') ?? 1;
    });
    _chatController.fetchChatHistory(_maAdmin, widget.maKhach);
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
      maNguoiGui: _maAdmin,
      vaiTroNguoiGui: 'Admin',
      maNguoiNhan: widget.maKhach,
      vaiTroNguoiNhan: 'User',
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
              AppDetailHeader(title: '${widget.tenKhach} (P.${widget.soPhong})'),
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
                        return const Center(child: Text('Chưa có tin nhắn nào.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final msg = history[index];
                          final isSentByAdmin = msg.vaiTroNguoiGui == 'Admin' && msg.maNguoiGui == _maAdmin;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ChatBubble(
                              message: msg.noiDung,
                              time: _formatTime(msg.ngayGui),
                              isSent: isSentByAdmin,
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
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}