import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tin_nhan.dart';
import '../shared/api_constants.dart';

class ChatService {
  // Lấy lịch sử chat giữa Admin và User
  Future<List<TinNhan>> getChatHistory(int maAdmin, int maKhach) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/TinNhan/$maAdmin/$maKhach');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TinNhan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lịch sử chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Gửi tin nhắn mới
  Future<bool> sendMessage(TinNhan tinNhan) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/TinNhan');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tinNhan.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Lấy danh sách chat gần đây của Admin
  Future<List<Map<String, dynamic>>> getRecentChats(int maAdmin) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/TinNhan/Admin/$maAdmin/Recent');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load recent chats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Lấy danh sách chat gần đây của User
  Future<List<Map<String, dynamic>>> getRecentChatsForUser(int maKhach) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/TinNhan/User/$maKhach/Recent');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load recent chats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }
}
