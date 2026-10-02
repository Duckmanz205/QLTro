import 'package:dio/dio.dart';
import '../../shared/api_constants.dart';

class BankModel {
  final int maNganHang;
  final String tenNganHang;
  final String tenVietTat;
  final String maBin;

  BankModel({
    required this.maNganHang,
    required this.tenNganHang,
    required this.tenVietTat,
    required this.maBin,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      maNganHang: json['maNganHang'] as int,
      tenNganHang: json['tenNganHang'] as String? ?? '',
      tenVietTat: json['tenVietTat'] as String? ?? '',
      maBin: json['maBin'] as String? ?? '',
    );
  }
}

class ManagerBankInfo {
  final int maQuanLy;
  final String hoTen;
  final String soTaiKhoan;
  final String tenTaiKhoan;
  final int? maNganHang;
  final String tenNganHang;
  final String tenVietTat;
  final String maBin;

  ManagerBankInfo({
    required this.maQuanLy,
    required this.hoTen,
    required this.soTaiKhoan,
    required this.tenTaiKhoan,
    this.maNganHang,
    required this.tenNganHang,
    required this.tenVietTat,
    required this.maBin,
  });

  factory ManagerBankInfo.fromJson(Map<String, dynamic> json) {
    return ManagerBankInfo(
      maQuanLy: json['maQuanLy'] as int,
      hoTen: json['hoTen'] as String? ?? '',
      soTaiKhoan: json['soTaiKhoan'] as String? ?? '',
      tenTaiKhoan: json['tenTaiKhoan'] as String? ?? '',
      maNganHang: json['maNganHang'] as int?,
      tenNganHang: json['tenNganHang'] as String? ?? '',
      tenVietTat: json['tenVietTat'] as String? ?? '',
      maBin: json['maBin'] as String? ?? '',
    );
  }
}

class ManagerBankService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<BankModel>> getBanks() async {
    try {
      final response = await _dio.get('/Bank');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BankModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ManagerBankInfo?> getManagerBankInfo(int managerId) async {
    try {
      final response = await _dio.get('/Manager/$managerId/bank-info');
      if (response.statusCode == 200) {
        return ManagerBankInfo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateManagerBankInfo(
    int managerId, {
    required String soTaiKhoan,
    required String tenTaiKhoan,
    required int maNganHang,
  }) async {
    try {
      final response = await _dio.put(
        '/Manager/$managerId/bank-info',
        data: {
          'soTaiKhoan': soTaiKhoan,
          'tenTaiKhoan': tenTaiKhoan,
          'maNganHang': maNganHang,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
