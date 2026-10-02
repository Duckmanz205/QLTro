import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nguoi_quan_ly.dart';
import '../shared/api_constants.dart';

class NguoiQuanLyService {
  Future<NguoiQuanLy> getAdminProfile(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/NguoiQuanLy/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return NguoiQuanLy.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> updateAdminProfile(NguoiQuanLy profile) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/NguoiQuanLy/${profile.maQuanLy}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
