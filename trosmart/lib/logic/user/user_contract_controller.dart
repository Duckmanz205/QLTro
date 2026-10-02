import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/api_constants.dart';
import '../auth/auth_service.dart';

class UserContractController extends ChangeNotifier {
  int _maHopDong = 0;
  int get maHopDong => _maHopDong;

  Map<String, dynamic>? _contract;
  Map<String, dynamic>? get contract => _contract;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  int _currentMaKhach = 1;
  int get currentMaKhach => _currentMaKhach;

  List<dynamic> _myContracts = [];
  List<dynamic> get myContracts => _myContracts;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  UserContractController() {
    loadContractFlow();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<void> selectContract(int index) async {
    if (index >= 0 && index < _myContracts.length) {
      _selectedIndex = index;
      await _loadSelectedContractDetails();

      final prefs = await SharedPreferences.getInstance();
      if (_contract != null) {
        final maPhong = _contract!['maPhong'] ?? _contract!['MaPhong'] ?? 0;
        await prefs.setInt('selected_ma_phong', maPhong);
      }
    }
  }

  Future<void> _loadSelectedContractDetails() async {
    if (_myContracts.isEmpty) {
      _contract = null;
      _maHopDong = 0;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final selected = _myContracts[_selectedIndex];
      var rawMaHopDong = selected['MaHopDong'] ?? selected['maHopDong'] ?? 0;
      _maHopDong = int.tryParse(rawMaHopDong.toString()) ?? 0;

      if (_maHopDong > 0) {
        final detailResponse = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/HopDong/$_maHopDong'),
          headers: await _getHeaders(),
        );
        if (detailResponse.statusCode == 200) {
          _contract = jsonDecode(detailResponse.body);
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải chi tiết hợp đồng: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadContractFlow() async {
    _isLoading = true;
    _maHopDong = 0;
    _contract = null;
    _myContracts = [];
    _selectedIndex = 0;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      var saved = prefs.getInt('maKhach') ?? prefs.getInt('ma_khach');
      if (saved != null && saved > 0) {
        _currentMaKhach = saved;
      } else {
        _currentMaKhach = 1;
      }

      final listResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/HopDong'),
        headers: await _getHeaders(),
      );
      if (listResponse.statusCode == 200) {
        final dynamic decoded = jsonDecode(listResponse.body);
        List<dynamic> contracts = [];
        if (decoded is List) {
          contracts = decoded;
        } else if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            contracts = decoded['data'];
          } else if (decoded.containsKey('value') && decoded['value'] is List) {
            contracts = decoded['value'];
          } else {
            contracts = [decoded];
          }
        }

        _myContracts = contracts.where((hd) {
          if (hd == null || hd is! Map) return false;
          var dynamicMaKhach = hd['MaKhach'] ?? hd['maKhach'] ?? hd['MAKHACH'] ?? hd['ma_khach'];
          return dynamicMaKhach != null && dynamicMaKhach.toString() == _currentMaKhach.toString();
        }).toList();

        if (_myContracts.isNotEmpty) {
          // Sắp xếp: Ưu tiên "Chờ khách ký" lên trước, sau đó sắp xếp theo ID hợp đồng mới nhất
          _myContracts.sort((a, b) {
            final aStatus = (a['trangThai'] ?? '').toString().trim();
            final bStatus = (b['trangThai'] ?? '').toString().trim();
            if (aStatus == 'Chờ khách ký' && bStatus != 'Chờ khách ký') return -1;
            if (aStatus != 'Chờ khách ký' && bStatus == 'Chờ khách ký') return 1;
            
            final aId = int.tryParse((a['maHopDong'] ?? a['MaHopDong'] ?? 0).toString()) ?? 0;
            final bId = int.tryParse((b['maHopDong'] ?? b['MaHopDong'] ?? 0).toString()) ?? 0;
            return bId.compareTo(aId);
          });

          _selectedIndex = 0;
          final selected = _myContracts[_selectedIndex];
          var rawMaHopDong = selected['MaHopDong'] ?? selected['maHopDong'] ?? 0;
          _maHopDong = int.tryParse(rawMaHopDong.toString()) ?? 0;

          if (_maHopDong > 0) {
            final detailResponse = await http.get(
              Uri.parse('${ApiConstants.baseUrl}/HopDong/$_maHopDong'),
              headers: await _getHeaders(),
            );
            if (detailResponse.statusCode == 200) {
              _contract = jsonDecode(detailResponse.body);
              if (_contract != null) {
                final maPhong = _contract!['maPhong'] ?? _contract!['MaPhong'] ?? 0;
                await prefs.setInt('selected_ma_phong', maPhong);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải thông tin hợp đồng: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> yeuCauGiaHan(int maHopDong) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/HopDong/$maHopDong/yeu-cau-gia-han'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        await loadContractFlow();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi gửi yêu cầu gia hạn: $e");
    }
    return false;
  }

  Future<bool> yeuCauKetThucSom(
    int maHopDong,
    String lyDo,
    DateTime ngayMuonKetThuc,
  ) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';
      final body = {
        'lyDo': lyDo,
        'ngayMuonKetThuc': ngayMuonKetThuc.toIso8601String().substring(0, 10),
      };
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/HopDong/$maHopDong/yeu-cau-ket-thuc-som',
        ),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        await loadContractFlow();
        return true;
      }
      debugPrint("Lỗi gửi yêu cầu kết thúc sớm: ${response.body}");
    } catch (e) {
      debugPrint("Lỗi gửi yêu cầu kết thúc sớm: $e");
    }
    return false;
  }
}
