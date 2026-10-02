import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/co_so_model.dart';
import '../../models/admin/co_so_detail_model.dart';
import '../../models/admin/manager_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/admin/co_so_image_model.dart';
import '../../models/admin/tien_ich_model.dart';
import '../../shared/api_constants.dart';
import '../auth/auth_service.dart';

class CoSoService {
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

  Future<List<ManagerModel>> getManagers() async {
    final uri = Uri.parse('$baseUrl/CoSo/managers');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách quản lý. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => ManagerModel.fromJson(item)).toList();
  }

  Future<List<CoSoDashboardModel>> getDashboard({int? maQuanLy}) async {
    final uri = maQuanLy == null
        ? Uri.parse('$baseUrl/CoSo/dashboard')
        : Uri.parse('$baseUrl/CoSo/dashboard?maQuanLy=$maQuanLy');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách cơ sở. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);

    return data
        .map((item) => CoSoDashboardModel.fromJson(item))
        .toList();
  }

  Future<CoSoDetailModel> getDetail(int id) async {
    final uri = Uri.parse('$baseUrl/CoSo/$id');

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được chi tiết cơ sở. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return CoSoDetailModel.fromJson(data);
  }

 Future<int> createCoSo({
  required String tenCoSo,
  required String diaChi,
  required String loaiHinh,
  String? moTa,
  int? maQuanLy,
  double? latitude,
  double? longitude,
  List<int> maTienIchIds = const [],
}) async {
  final uri = Uri.parse('$baseUrl/CoSo');

  final response = await http.post(
    uri,
    headers: await _getHeaders(isJson: true),
    body: jsonEncode({
      'tenCoSo': tenCoSo,
      'diaChi': diaChi,
      'loaiHinh': loaiHinh,
      'maQuanLy': maQuanLy,
      'moTa': moTa,
      'latitude': latitude,
      'longitude': longitude,
      'maTienIchIds': maTienIchIds,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(
      'Không thêm được cơ sở. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  final data = jsonDecode(response.body);
  return data['maCoSo'] ?? data['MaCoSo'] ?? 0;
}

  Future<void> updateCoSo({
  required int maCoSo,
  required String tenCoSo,
  required String diaChi,
  required String loaiHinh,
  String? moTa,
  int? maQuanLy,
  double? latitude,
  double? longitude,
  List<int> maTienIchIds = const [],
}) async {
  final uri = Uri.parse('$baseUrl/CoSo/$maCoSo');

  final response = await http.put(
    uri,
    headers: await _getHeaders(isJson: true),
    body: jsonEncode({
      'maCoSo': maCoSo,
      'tenCoSo': tenCoSo,
      'diaChi': diaChi,
      'loaiHinh': loaiHinh,
      'maQuanLy': maQuanLy,
      'moTa': moTa,
      'latitude': latitude,
      'longitude': longitude,
      'maTienIchIds': maTienIchIds,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Không cập nhật được cơ sở. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}

  Future<void> deleteCoSo(int maCoSo) async {
    // 1. Fetch images to delete them from Supabase first
    try {
      final images = await getCoSoImages(maCoSo);
      final supabase = Supabase.instance.client;
      final fileNames = images.map((img) {
        final uri = Uri.parse(img.urlAnh);
        return uri.pathSegments.last;
      }).toList();
      
      if (fileNames.isNotEmpty) {
        await supabase.storage.from('trosmart-images').remove(fileNames);
      }
    } catch (e) {
      print("Error deleting Supabase images of CoSo: $e");
    }

    // 2. Call backend to delete CoSo
    final uri = Uri.parse('$baseUrl/CoSo/$maCoSo');

    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        'Không xóa được cơ sở. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<List<CoSoImageModel>> getCoSoImages(int maCoSo) async {
  final uri = Uri.parse('$baseUrl/CoSo/$maCoSo/images');

  final response = await http.get(uri, headers: await _getHeaders());

  if (response.statusCode != 200) {
    throw Exception(
      'Không tải được danh sách ảnh cơ sở. '
      'Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  final List data = jsonDecode(response.body);
  return data.map((e) => CoSoImageModel.fromJson(e)).toList();
}

Future<CoSoImageModel> uploadCoSoImage({
  required int maCoSo,
  required XFile file,
}) async {
  // 1. Upload the image directly to Supabase Storage
  final supabase = Supabase.instance.client;
  final extension = file.name.split('.').last;
  final fileName = 'coso_${maCoSo}_${DateTime.now().millisecondsSinceEpoch}.$extension';
  final fileBytes = await file.readAsBytes();

  await supabase.storage
      .from('trosmart-images')
      .uploadBinary(fileName, fileBytes, fileOptions: const FileOptions(upsert: true));

  // 2. Get the public url
  final publicUrl = supabase.storage
      .from('trosmart-images')
      .getPublicUrl(fileName);

  // 3. Save this url in the Backend DB using our new URL endpoint
  final uri = Uri.parse('$baseUrl/CoSo/$maCoSo/images/url');

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

  return CoSoImageModel.fromJson(jsonDecode(response.body));
}

Future<void> setMainCoSoImage(int maAnh) async {
  final uri = Uri.parse('$baseUrl/CoSo/images/$maAnh/set-main');

  final response = await http.put(uri, headers: await _getHeaders());

  if (response.statusCode != 200) {
    throw Exception(
      'Không cập nhật được ảnh chính. '
      'Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}

Future<void> deleteCoSoImage(int maAnh, String urlAnh) async {
  // 1. Delete the image from Supabase Storage if it is a Supabase URL
  if (urlAnh.contains('supabase.co') || urlAnh.contains('trosmart-images')) {
    try {
      final uri = Uri.parse(urlAnh);
      final fileName = uri.pathSegments.last;
      final supabase = Supabase.instance.client;
      await supabase.storage.from('trosmart-images').remove([fileName]);
      print("Deleted image from Supabase Storage: $fileName");
    } catch (e) {
      print("Error deleting image from Supabase Storage: $e");
    }
  }

  // 2. Call backend to delete the record in SQL Server DB
  final uri = Uri.parse('$baseUrl/CoSo/images/$maAnh');

  final response = await http.delete(uri, headers: await _getHeaders());

  if (response.statusCode != 200) {
    throw Exception(
      'Không xóa được ảnh. '
      'Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}

Future<List<TienIchModel>> getTienIchList() async {
  final uri = Uri.parse('$baseUrl/CoSo/tien-ich');

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
  final uri = Uri.parse('$baseUrl/CoSo/tien-ich');

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
