import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/phong_model.dart';
import '../../models/admin/phong_view_model.dart';
import '../../models/admin/tien_ich_model.dart';
import '../../shared/api_constants.dart';
import '../auth/auth_service.dart';

class PhongService {
  String get baseUrl => ApiConstants.baseUrl;

  Future<Map<String, String>> _getHeaders({bool isJson = false}) async {
    final token = await AuthService().getToken();
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<PhongModel>> getAll({int? maQuanLy}) async {
    final uri = maQuanLy == null
        ? Uri.parse('$baseUrl/Phong')
        : Uri.parse('$baseUrl/Phong?maQuanLy=$maQuanLy');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách tất cả phòng. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => PhongModel.fromJson(item)).toList();
  }

  Future<List<PhongModel>> getByCoSo(int maCoSo) async {
    final uri = Uri.parse('$baseUrl/Phong/coso/$maCoSo');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách phòng. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => PhongModel.fromJson(item)).toList();
  }

  Future<List<PhongModel>> getPhongTrong() async {
    final uri = Uri.parse('$baseUrl/Phong/trong');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách phòng trống. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => PhongModel.fromJson(item)).toList();
  }

  Future<List<PhongViewModel>> getPhongView() async {
    final uri = Uri.parse('$baseUrl/Phong/view');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được dữ liệu tra cứu phòng. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => PhongViewModel.fromJson(item)).toList();
  }

  Future<PhongModel> getDetail(int maPhong) async {
    final uri = Uri.parse('$baseUrl/Phong/$maPhong');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được chi tiết phòng. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return PhongModel.fromJson(data);
  }

 Future<int> createPhong({
  required String soPhong,
  required num giaThue,
  required String trangThai,
  required int maCoSo,
  int? tang,
  num? dienTich,
  int? soNguoiToiDa,
  String? moTa,
  List<int> maTienIchIds = const [],
}) async {
  final uri = Uri.parse('$baseUrl/Phong');

  final response = await http.post(
    uri,
    headers: await _getHeaders(isJson: true),
    body: jsonEncode({
      'soPhong': soPhong,
      'giaThue': giaThue,
      'trangThai': trangThai,
      'maCoSo': maCoSo,
      'tang': tang,
      'dienTich': dienTich,
      'soNguoiToiDa': soNguoiToiDa,
      'moTa': moTa,
      'maTienIchIds': maTienIchIds,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(
      'Không thêm được phòng. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  final data = jsonDecode(response.body);
  return data['maPhong'] ?? data['MaPhong'] ?? 0;
}

 Future<void> updatePhong({
  required int maPhong,
  required int maCoSo,
  required String soPhong,
  int? tang,
  num? dienTich,
  required num giaThue,
  int? soNguoiToiDa,
  required String trangThai,
  String? moTa,
  List<int> maTienIchIds = const [],
}) async {
  final uri = Uri.parse('$baseUrl/Phong/$maPhong');

  final response = await http.put(
    uri,
    headers: await _getHeaders(isJson: true),
    body: jsonEncode({
      'maPhong': maPhong,
      'maCoSo': maCoSo,
      'soPhong': soPhong,
      'tang': tang,
      'dienTich': dienTich,
      'giaThue': giaThue,
      'soNguoiToiDa': soNguoiToiDa,
      'trangThai': trangThai,
      'moTa': moTa,
      'maTienIchIds': maTienIchIds,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Không cập nhật được phòng. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}

  Future<void> deletePhong(int maPhong) async {
    // 1. Fetch details to delete image from Supabase first
    try {
      final detail = await getDetail(maPhong);
      final urlAnh = detail.hinhAnhPhong;
      if (urlAnh != null && urlAnh.isNotEmpty && urlAnh.contains('supabase.co')) {
        final uri = Uri.parse(urlAnh);
        final segments = uri.pathSegments;
        if (segments.length >= 2) {
          final bucketName = segments[segments.length - 2];
          final fileName = segments.last;
          final supabase = Supabase.instance.client;
          await supabase.storage.from(bucketName).remove([fileName]);
          print("Deleted image from Supabase Storage ($bucketName): $fileName");
        }
      }
    } catch (e) {
      print("Error deleting Supabase image of Phong: $e");
    }

    // 2. Call backend to delete Phong
    final uri = Uri.parse('$baseUrl/Phong/$maPhong');

    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Không xóa được phòng. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<void> uploadPhongImage({
    required int maPhong,
    required XFile file,
  }) async {
    final supabase = Supabase.instance.client;

    // Fetch detail first to get room number and facility ID
    final detail = await getDetail(maPhong);

    // 1. Delete old image if it exists in Supabase
    try {
      final urlAnh = detail.hinhAnhPhong;
      if (urlAnh != null && urlAnh.isNotEmpty && urlAnh.contains('supabase.co')) {
        final uri = Uri.parse(urlAnh);
        final segments = uri.pathSegments;
        if (segments.length >= 2) {
          final bucketName = segments[segments.length - 2];
          final oldFileName = segments.last;
          await supabase.storage.from(bucketName).remove([oldFileName]);
          print("Deleted old image from Supabase Storage ($bucketName): $oldFileName");
        }
      }
    } catch (e) {
      print("Error deleting old image of Phong: $e");
    }

    // 2. Upload the new image directly to Supabase Storage in 'phong' bucket
    final cleanSoPhong = detail.soPhong.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final coSoPart = 'coso${detail.maCoSo}';

    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    final dateTimeStr = '$year$month$day$hour$minute$second$ms';

    final extension = file.name.split('.').last;
    final fileName = '${cleanSoPhong}_${coSoPart}_$dateTimeStr.$extension';
    final fileBytes = await file.readAsBytes();

    await supabase.storage
        .from('phong')
        .uploadBinary(fileName, fileBytes, fileOptions: const FileOptions(upsert: true));

    // 3. Get the public url
    final publicUrl = supabase.storage
        .from('phong')
        .getPublicUrl(fileName);

    // 4. Save this url in the Backend DB using our new URL endpoint
    final uri = Uri.parse('$baseUrl/Phong/$maPhong/image/url');

    final response = await http.post(
      uri,
      headers: await _getHeaders(isJson: true),
      body: jsonEncode({
        'url': publicUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Không lưu được ảnh vào backend. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<List<TienIchModel>> getTienIchList() async {
  final uri = Uri.parse('$baseUrl/Phong/tien-ich');

  final response = await http.get(uri, headers: await _getHeaders());

  if (response.statusCode != 200) {
    throw Exception(
      'Không tải được tiện ích. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  final List data = jsonDecode(response.body);
  return data.map((e) => TienIchModel.fromJson(e)).toList();
}

Future<TienIchModel> createTienIch({
  required String tenTienIch,
}) async {
  final uri = Uri.parse('$baseUrl/Phong/tien-ich');

  final response = await http.post(
    uri,
    headers: await _getHeaders(isJson: true),
    body: jsonEncode({
      'tenTienIch': tenTienIch,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(
      'Không thêm được tiện ích. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  final data = jsonDecode(response.body);
  return TienIchModel.fromJson(data);
}
}