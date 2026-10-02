import 'package:dio/dio.dart';
import '../../models/admin/invoice_model.dart';
import '../auth/auth_service.dart';
import '../../shared/api_constants.dart';

class InvoiceService {
  final AuthService _authService = AuthService();
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Lấy danh sách hóa đơn theo tháng/năm.
  /// Nếu month = 0 hoặc year = 0 thì lấy tất cả hóa đơn.
  Future<List<InvoiceModel>> getInvoices(int month, int year) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (month > 0 && year > 0) {
        queryParams['month'] = month;
        queryParams['year'] = year;
      }

      final response = await _dio.get(
        '/Invoice',
        queryParameters: queryParams,
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => InvoiceModel.fromJson(item)).toList();
      }
      throw Exception('Không tải được danh sách hóa đơn.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  /// Lấy danh sách hóa đơn theo mã khách thuê (maKhach).
  Future<List<InvoiceModel>> getInvoicesByCustomer(int maKhach) async {
    try {
      final response = await _dio.get(
        '/Invoice/by-customer/$maKhach',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => InvoiceModel.fromJson(item)).toList();
      }
      throw Exception('Không tải được danh sách hóa đơn.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<InvoiceModel> getInvoiceById(int id) async {
    try {
      final response = await _dio.get(
        '/Invoice/$id',
        options: Options(
          headers: await _getHeaders(),
        ),
      );
      if (response.statusCode == 200) {
        return InvoiceModel.fromJson(response.data);
      }
      throw Exception('Không tải được chi tiết hóa đơn.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<InvoiceModel> createInvoice({
    required int maPhong,
    int? maKhach,
    required int thang,
    required int nam,
    required double soDienCu,
    required double soDienMoi,
    required double soNuocCu,
    required double soNuocMoi,
    required double donGiaDien,
    required double donGiaNuoc,
    double tienDichVu = 0,
    String? moTaDichVu,
    required double phuPhi,
    String? moTaPhuPhi,
  }) async {
    try {
      final response = await _dio.post(
        '/Invoice',
        data: {
          'maPhong': maPhong,
          'maKhach': maKhach,
          'thang': thang,
          'nam': nam,
          'soDienCu': soDienCu,
          'soDienMoi': soDienMoi,
          'soNuocCu': soNuocCu,
          'soNuocMoi': soNuocMoi,
          'donGiaDien': donGiaDien,
          'donGiaNuoc': donGiaNuoc,
          'tienDichVu': tienDichVu,
          'moTaDichVu': moTaDichVu,
          'phuPhi': phuPhi,
          'moTaPhuPhi': moTaPhuPhi,
        },
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InvoiceModel.fromJson(response.data);
      }
      throw Exception('Không tạo được hóa đơn.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<void> updateInvoiceStatus(int id, String trangThai) async {
    try {
      final response = await _dio.put(
        '/Invoice/$id/status',
        data: {
          'trangThai': trangThai,
        },
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Không cập nhật được trạng thái.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<void> updateInvoice({
    required int maHoaDon,
    required double soDienMoi,
    required double soNuocMoi,
    required double phuPhi,
    String? moTaPhuPhi,
  }) async {
    try {
      final response = await _dio.put(
        '/Invoice/$maHoaDon',
        data: {
          'soDienMoi': soDienMoi,
          'soNuocMoi': soNuocMoi,
          'phuPhi': phuPhi,
          'moTaPhuPhi': moTaPhuPhi,
        },
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Không cập nhật được hóa đơn.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      final response = await _dio.delete(
        '/Invoice/$id',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Không xóa được hóa đơn.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableRooms() async {
    try {
      // Gọi API lấy danh sách phòng đang thuê để lập hóa đơn
      final response = await _dio.get(
        '/Phong',
        options: Options(
          headers: await _getHeaders(),
        ),
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((room) => <String, dynamic>{
          'id': room['maPhong'],
          'name': 'Phòng ${room['soPhong']} - ${room['trangThai']}',
          'soPhong': room['soPhong'] ?? '',
          'trangThai': room['trangThai'] ?? '',
          'soDienCu': 0.0, // Sẽ lấy từ hóa đơn tháng trước nếu có
          'soNuocCu': 0.0,
          'tienPhong': (room['giaThue'] ?? 0).toDouble(),
        }).toList();
      }
      throw Exception('Không tải được danh sách phòng.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Kết nối mạng quá hạn. Vui lòng kiểm tra internet.');
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? e.message;
      
      if (statusCode == 400) {
        return Exception('Dữ liệu không hợp lệ: $errorMessage');
      } else if (statusCode == 404) {
        return Exception('Không tìm thấy dữ liệu: $errorMessage');
      } else if (statusCode == 500) {
        final serverMsg = e.response?.data?['message'];
        final serverErr = e.response?.data?['error'];
        if (serverMsg != null || serverErr != null) {
          return Exception('$serverMsg ${serverErr != null ? "\nChi tiết: $serverErr" : ""}');
        }
        return Exception('Lỗi máy chủ (500). Vui lòng thử lại sau.');
      }
      return Exception('Lỗi hệ thống ($statusCode): $errorMessage');
    }
    return Exception('Không thể kết nối đến máy chủ. Kiểm tra baseUrl và mạng.');
  }
}
