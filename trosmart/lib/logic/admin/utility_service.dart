import 'package:dio/dio.dart';
import '../auth/auth_service.dart';
import '../../shared/api_constants.dart';

class UtilityService {
  final AuthService _authService = AuthService();
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Lấy danh sách chỉ số điện nước tất cả phòng theo tháng/năm
  Future<List<Map<String, dynamic>>> getReadings(int month, int year) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/UtilityReading',
        queryParameters: {
          'month': month,
          'year': year,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      throw Exception('Không tải được danh sách chỉ số.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  /// Lưu chỉ số điện nước cho 1 phòng
  Future<void> saveReading({
    required int maPhong,
    required int thang,
    required int nam,
    required int chiSoDienCu,
    int? chiSoDienMoi,
    required int chiSoNuocCu,
    int? chiSoNuocMoi,
  }) async {
    try {
      final token = await _authService.getToken();
      await _dio.post(
        '/UtilityReading',
        data: {
          'maPhong': maPhong,
          'thang': thang,
          'nam': nam,
          'chiSoDienCu': chiSoDienCu,
          'chiSoDienMoi': chiSoDienMoi,
          'chiSoNuocCu': chiSoNuocCu,
          'chiSoNuocMoi': chiSoNuocMoi,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  /// Lưu chỉ số điện nước cho nhiều phòng cùng lúc
  Future<void> saveBatchReadings(List<Map<String, dynamic>> readings) async {
    try {
      final token = await _authService.getToken();
      await _dio.post(
        '/UtilityReading/batch',
        data: readings,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  /// Cập nhật đơn giá điện nước cho cơ sở
  Future<void> updateUtilityPrices(int maCoSo, double donGiaDien, double donGiaNuoc) async {
    try {
      final token = await _authService.getToken();
      await _dio.patch(
        '/CoSo/$maCoSo/utility-prices',
        data: {
          'donGiaDien': donGiaDien,
          'donGiaNuoc': donGiaNuoc,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Kết nối mạng quá hạn.');
    } else if (e.type == DioExceptionType.badResponse) {
      final msg = e.response?.data?['message'] ?? e.message;
      return Exception('Lỗi: $msg');
    }
    return Exception('Không thể kết nối đến máy chủ.');
  }
}
