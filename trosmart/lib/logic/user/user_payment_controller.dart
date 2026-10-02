import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/admin/invoice_model.dart';
import '../admin/invoice_service.dart';

class UserPaymentController extends ChangeNotifier {
  final InvoiceService _service = InvoiceService();

  List<InvoiceModel> _allInvoices = [];
  List<InvoiceModel> get allInvoices => _allInvoices;

  /// Danh sách hóa đơn CHƯA thanh toán, sắp xếp theo mã hóa đơn giảm dần (mới nhất lên đầu)
  List<InvoiceModel> get unpaidInvoices {
    final list = _allInvoices.where((inv) => inv.trangThai != 'Đã thanh toán').toList();
    list.sort((a, b) => b.maHoaDon.compareTo(a.maHoaDon));
    return list;
  }

  /// Danh sách hóa đơn ĐÃ thanh toán, sắp xếp theo mã hóa đơn giảm dần (mới nhất lên đầu)
  List<InvoiceModel> get paidInvoices {
    final list = _allInvoices.where((inv) => inv.trangThai == 'Đã thanh toán').toList();
    list.sort((a, b) => b.maHoaDon.compareTo(a.maHoaDon));
    return list;
  }

  InvoiceModel? _activeInvoice;
  InvoiceModel? get activeInvoice => _activeInvoice;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Tên người dùng hiện tại (lấy từ SharedPreferences)
  String _currentUserName = '';
  String get currentUserName => _currentUserName;

  /// Mã khách thuê hiện tại
  int? _maKhach;
  int? get maKhach => _maKhach;

  UserPaymentController() {
    loadUserInvoices();
  }

  Future<void> loadUserInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Đọc maKhach từ SharedPreferences (đã lưu lúc đăng nhập)
      final prefs = await SharedPreferences.getInstance();
      _maKhach = prefs.getInt('ma_khach');
      _currentUserName = prefs.getString('ho_ten') ?? '';

      List<InvoiceModel> list;

      if (_maKhach != null) {
        // Lấy hóa đơn theo mã khách thuê (chỉ hóa đơn của user đang đăng nhập)
        list = await _service.getInvoicesByCustomer(_maKhach!);
      } else {
        // Fallback: nếu không có maKhach thì thông báo lỗi
        _allInvoices = [];
        _activeInvoice = null;
        _errorMessage = 'Không tìm thấy thông tin khách thuê. Vui lòng đăng nhập lại.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Lọc hóa đơn theo phòng đang được chọn trong hợp đồng
      final selectedMaPhong = prefs.getInt('selected_ma_phong');
      if (selectedMaPhong != null && selectedMaPhong > 0) {
        _allInvoices = list.where((inv) => inv.maPhong == selectedMaPhong).toList();
      } else {
        _allInvoices = list;
      }
      
      if (_allInvoices.isNotEmpty) {
        // Tìm hóa đơn chưa thanh toán mới nhất, nếu không có thì lấy hóa đơn mới nhất
        final pending = _allInvoices.where((inv) => inv.trangThai != 'Đã thanh toán').toList();
        if (pending.isNotEmpty) {
          // Lấy hóa đơn có mã lớn nhất
          pending.sort((a, b) => b.maHoaDon.compareTo(a.maHoaDon));
          _activeInvoice = pending.first;
        } else {
          _allInvoices.sort((a, b) => b.maHoaDon.compareTo(a.maHoaDon));
          _activeInvoice = _allInvoices.first;
        }
      } else {
        _activeInvoice = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsPaid(int invoiceId) async {
    try {
      await _service.updateInvoiceStatus(invoiceId, 'Đã thanh toán');
      // Tải lại danh sách
      await loadUserInvoices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitPaymentProof(int invoiceId) async {
    try {
      await _service.updateInvoiceStatus(invoiceId, 'Chờ duyệt');
      // Tải lại danh sách
      await loadUserInvoices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
