import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/thong_ke_model.dart';
import '../auth/auth_service.dart';

import '../../shared/api_constants.dart';

class ThongKeService {
  String get _baseUrl => ApiConstants.baseUrl.replaceAll('/api', '');
  final AuthService _authService = AuthService();

  // -------------------------------------------------------------
  // Lấy dữ liệu báo cáo thống kê cho Chủ trọ (Admin)
  // -------------------------------------------------------------
  Future<AdminThongKeModel> getAdminStats({int? year}) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Vui lòng đăng nhập lại để xem thống kê.');
    }

    final queryYear = year ?? DateTime.now().year;
    final url = Uri.parse('$_baseUrl/api/ThongKe/admin?year=$queryYear');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return AdminThongKeModel.fromJson(jsonDecode(response.body));
    } else {
      try {
        final body = jsonDecode(response.body);
        final msg = body is Map
            ? (body['message'] ?? body['detail'] ?? 'Lỗi không xác định')
            : 'Lỗi lấy dữ liệu';
        throw Exception(msg);
      } catch (e) {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    }
  }

  // -------------------------------------------------------------
  // Lấy dữ liệu chi tiêu & tiêu thụ cho Khách thuê (User)
  // -------------------------------------------------------------
  Future<UserThongKeModel> getUserStats() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Vui lòng đăng nhập lại để xem thống kê.');
    }

    final url = Uri.parse('$_baseUrl/api/ThongKe/user');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserThongKeModel.fromJson(jsonDecode(response.body));
    } else {
      try {
        final body = jsonDecode(response.body);
        final msg = body is Map
            ? (body['message'] ?? body['detail'] ?? 'Lỗi không xác định')
            : 'Lỗi lấy dữ liệu';
        throw Exception(msg);
      } catch (e) {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    }
  }
}
