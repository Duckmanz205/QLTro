import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trosmart/models/user_model.dart';

import '../../shared/api_constants.dart';

class AuthService {
  String get _baseUrl => ApiConstants.baseUrl.replaceAll('/api', '');

  // ── SharedPreferences keys ──
  static const String _keyToken = 'auth_token';
  static const String _keyVaiTro = 'vai_tro';
  static const String _keyMaKhach = 'ma_khach';
  static const String _keyMaQuanLy = 'ma_quan_ly';
  static const String _keyHoTen = 'ho_ten';

  // ────────────────────────────────────────
  // LOGIN
  // ────────────────────────────────────────
  Future<AuthResponse> login(String tenDangNhap, String matKhau) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDangNhap': tenDangNhap.trim(),
        'matKhau': matKhau,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(body);
      await _saveSession(authResponse);
      return authResponse;
    } else {
      // Lấy message từ response body để hiển thị SnackBar
      final message = body['message'] as String? ?? 'Đăng nhập thất bại';
      throw Exception(message);
    }
  }

  // ────────────────────────────────────────
  // REGISTER → tự động gọi login sau đó
  // ────────────────────────────────────────
  Future<AuthResponse> register(
    String tenDangNhap,
    String matKhau,
    String hoTen,
    String? sDT,
    String vaiTro,
  ) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDangNhap': tenDangNhap.trim(),
        'matKhau': matKhau,
        'hoTen': hoTen.trim(),
        'sDT': sDT?.trim(),
        'vaiTro': vaiTro,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Đăng ký thành công → gọi login ngay
      return await login(tenDangNhap, matKhau);
    } else {
      final message = body['message'] as String? ?? 'Đăng ký thất bại';
      final detail = body['detail'] as String?;
      if (detail != null && detail.isNotEmpty) {
        throw Exception('$message\nChi tiết: $detail');
      }
      throw Exception(message);
    }
  }

  // ────────────────────────────────────────
  // LOGOUT
  // ────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyVaiTro);
    await prefs.remove(_keyMaKhach);
    await prefs.remove(_keyMaQuanLy);
    await prefs.remove(_keyHoTen);
  }

  // ────────────────────────────────────────
  // GET TOKEN
  // ────────────────────────────────────────
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ────────────────────────────────────────
  // HELPER: Lưu session vào SharedPreferences
  // ────────────────────────────────────────
  Future<void> _saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, auth.token);
    await prefs.setString(_keyVaiTro, auth.vaiTro);
    await prefs.setString(_keyHoTen, auth.hoTen);
    if (auth.maKhach != null) {
      await prefs.setInt(_keyMaKhach, auth.maKhach!);
    }
    if (auth.maQuanLy != null) {
      await prefs.setInt(_keyMaQuanLy, auth.maQuanLy!);
    }
  }

  Future<int?> getMaQuanLy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaQuanLy);
  }

  Future<int?> getMaKhach() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaKhach);
  }

  // ────────────────────────────────────────
  // FORGOT PASSWORD / RESET PASSWORD
  // ────────────────────────────────────────
  Future<void> forgotPassword(String tenDangNhap, String newPassword) async {
    final url = Uri.parse('$_baseUrl/api/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDangNhap': tenDangNhap.trim(),
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body['message'] as String? ?? 'Đặt lại mật khẩu thất bại';
      throw Exception(message);
    }
  }
}
