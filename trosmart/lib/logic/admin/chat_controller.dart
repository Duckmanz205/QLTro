import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../models/tin_nhan.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Map<String, dynamic>> _allChats = [];
  List<Map<String, dynamic>> recentChats = [];
  List<TinNhan> currentChatHistory = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchRecentChats(int maAdmin) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allChats = await _chatService.getRecentChats(maAdmin);
      recentChats = List.from(_allChats);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterChats(String query) {
    if (query.trim().isEmpty) {
      recentChats = List.from(_allChats);
    } else {
      final lowerQuery = query.toLowerCase();
      recentChats = _allChats.where((chat) {
        final name = (chat['tenKhach'] ?? '').toString().toLowerCase();
        final room = (chat['soPhong'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery) || room.contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchRecentChatsForUser(int maKhach) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allChats = await _chatService.getRecentChatsForUser(maKhach);
      recentChats = List.from(_allChats);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterUserChats(String query) {
    if (query.trim().isEmpty) {
      recentChats = List.from(_allChats);
    } else {
      final lowerQuery = query.toLowerCase();
      recentChats = _allChats.where((chat) {
        final name = (chat['tenAdmin'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchChatHistory(int maAdmin, int maKhach) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentChatHistory = await _chatService.getChatHistory(maAdmin, maKhach);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(TinNhan tinNhan) async {
    try {
      final success = await _chatService.sendMessage(tinNhan);
      if (success) {
        // Sau khi gửi, tự động thêm vào lịch sử hiện tại và render lại
        currentChatHistory.add(tinNhan);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
