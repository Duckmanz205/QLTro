import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/thong_bao.dart';
import '../shared/api_constants.dart';
import '../logic/auth/auth_service.dart';

class ThongBaoService {
  final AuthService _authService = AuthService();

  // Lấy tất cả thông báo (dành cho Admin)
  Future<List<ThongBao>> getAllThongBao() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/ThongBao');
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ThongBao.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load thông báo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Lấy thông báo theo mã khách (dành cho User)
  Future<List<ThongBao>> getThongBaoForUser(int maKhach) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/ThongBao/user/$maKhach');
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ThongBao.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load thông báo user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Tạo thông báo mới (Admin)
  Future<bool> sendThongBao(ThongBao thongBao) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/ThongBao');
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(thongBao.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Server từ chối với lỗi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi gửi thông báo: $e');
    }
  }

  // Lấy danh sách khách hàng để gửi thông báo (Admin)
  Future<List<Map<String, dynamic>>> getDanhSachKhach() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/ThongBao/danh-sach-khach');
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load danh sách khách: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }
}
