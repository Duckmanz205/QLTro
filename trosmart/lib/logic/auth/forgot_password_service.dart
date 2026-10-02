import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  // ─── Cùng base URL với AuthService ───
  static const String _baseUrl = 'http://10.0.2.2:5137';

  // ────────────────────────────────────────
  // BƯỚC 1: Xác minh tài khoản bằng TenDangNhap + SDT
  // ────────────────────────────────────────
  Future<void> xacMinhTaiKhoan(String tenDangNhap, String sDT) async {
    final url = Uri.parse('$_baseUrl/api/forgotpassword/xac-minh');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDangNhap': tenDangNhap.trim(),
        'sDT': sDT.trim(),
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = body['message'] as String? ?? 'Xác minh thất bại';
      throw Exception(message);
    }
  }

  // ────────────────────────────────────────
  // BƯỚC 2: Đặt lại mật khẩu mới
  // ────────────────────────────────────────
  Future<void> datLaiMatKhau(String tenDangNhap, String matKhauMoi) async {
    final url = Uri.parse('$_baseUrl/api/forgotpassword/dat-lai');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDangNhap': tenDangNhap.trim(),
        'matKhauMoi': matKhauMoi,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = body['message'] as String? ?? 'Đặt lại mật khẩu thất bại';
      throw Exception(message);
    }
  }
}
