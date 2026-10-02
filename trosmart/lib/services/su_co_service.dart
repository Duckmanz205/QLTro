import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/su_co.dart';
import '../shared/api_constants.dart';
import '../logic/auth/auth_service.dart';

class SuCoService {
  final AuthService _authService = AuthService();

  // Lấy tất cả sự cố (Admin)
  Future<List<SuCo>> getAllSuCo({int? maQuanLy}) async {
    final uriStr = maQuanLy != null
        ? '${ApiConstants.baseUrl}/SuCo?maQuanLy=$maQuanLy'
        : '${ApiConstants.baseUrl}/SuCo';
    final url = Uri.parse(uriStr);
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SuCo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sự cố: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Lấy sự cố theo mã khách (User)
  Future<List<SuCo>> getSuCoForUser(int maKhach) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/SuCo/user/$maKhach');
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SuCo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sự cố user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Gửi báo cáo sự cố mới (User)
  Future<bool> sendSuCo(SuCo suCo) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/SuCo');
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(suCo.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  // Cập nhật trạng thái sự cố (Admin)
  Future<bool> updateSuCoStatus(int id, String trangThai) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/SuCo/$id/status');
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(trangThai),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }
}
