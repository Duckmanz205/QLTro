import 'package:flutter/foundation.dart';
import '../../models/admin/invoice_model.dart';
import 'invoice_service.dart';
import 'utility_service.dart';

class InvoiceController extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> get invoices => _invoices;

  String _searchText = "";
  String get searchText => _searchText;

  String _selectedFilter = "Tất cả";
  String get selectedFilter => _selectedFilter;

  void updateSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  void updateSelectedFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  List<InvoiceModel> get filteredInvoices {
    return _invoices.where((inv) {
      // 1. Filter by status
      if (_selectedFilter != "Tất cả") {
        if (_selectedFilter == "Đã thanh toán" && inv.trangThai != "Đã thanh toán") {
          return false;
        }
        if (_selectedFilter == "Chờ thu" && inv.trangThai != "Chưa thanh toán" && inv.trangThai != "Chờ thanh toán") {
          return false;
        }
        if (_selectedFilter == "Quá hạn" && inv.trangThai != "Quá hạn") {
          return false;
        }
      }

      // 2. Filter by search text
      if (_searchText.isNotEmpty) {
        final query = _searchText.toLowerCase();
        final matchRoom = inv.tenPhong.toLowerCase().contains(query) || inv.maPhong.toString().contains(query);
        final matchTenant = inv.tenKhachThue.toLowerCase().contains(query);
        final matchCoSo = inv.tenCoSo.toLowerCase().contains(query);
        return matchRoom || matchTenant || matchCoSo;
      }

      return true;
    }).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Tháng/Năm đang xem
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  // Form State
  int? selectedRoomId;
  double soDienCu = 0;
  double soDienMoi = 0;
  double soNuocCu = 0;
  double soNuocMoi = 0;
  bool isDienMoiEntered = false;
  bool isNuocMoiEntered = false;
  double tienPhong = 0;
  double donGiaDien = 3500;
  double donGiaNuoc = 20000;

  List<IncidentalFeeItem> incidentalItems = [IncidentalFeeItem()];

  double get totalIncidentalAmount => 
    incidentalItems.fold<double>(0, (sum, item) => sum + item.amount);

  String get concatenatedIncidentalDescription =>
    incidentalItems
      .where((item) => item.name.trim().isNotEmpty)
      .map((item) => "${item.name.trim()} (${item.amount.toStringAsFixed(0)}đ)")
      .join(', ');

  double get phuPhi => totalIncidentalAmount;
  String get tenPhuPhi => concatenatedIncidentalDescription;

  double get tongTien => 
    tienPhong + 
    ((soDienMoi > soDienCu ? soDienMoi - soDienCu : 0) * donGiaDien) + 
    ((soNuocMoi > soNuocCu ? soNuocMoi - soNuocCu : 0) * donGiaNuoc) + 
    phuPhi;

  List<Map<String, dynamic>> availableRooms = [];

  // === THỐNG KÊ TÍNH TOÁN TỪ DANH SÁCH HÓA ĐƠN ===
  double get totalDaThu {
    double total = 0;
    for (var inv in _invoices) {
      if (inv.trangThai == 'Đã thanh toán') total += inv.tongTien;
    }
    return total;
  }

  double get totalChoThu {
    double total = 0;
    for (var inv in _invoices) {
      if (inv.trangThai == 'Chưa thanh toán') total += inv.tongTien;
    }
    return total;
  }

  double get totalQuaHan {
    double total = 0;
    for (var inv in _invoices) {
      if (inv.trangThai == 'Quá hạn') total += inv.tongTien;
    }
    return total;
  }

  int get countDaThu => _invoices.where((i) => i.trangThai == 'Đã thanh toán').length;
  int get countChoThu => _invoices.where((i) => i.trangThai == 'Chưa thanh toán').length;
  int get countQuaHan => _invoices.where((i) => i.trangThai == 'Quá hạn').length;

  InvoiceController() {
    fetchAvailableRooms();
    fetchInvoices(_selectedMonth, _selectedYear);
  }

  /// Thay đổi tháng/năm đang xem và tải lại dữ liệu
  void changeMonthYear(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    fetchInvoices(month, year);
  }

  Future<void> fetchAvailableRooms() async {
    _setLoading(true);
    _setError(null);
    try {
      availableRooms = await _invoiceService.getAvailableRooms();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectRoom(int roomId) async {
    selectedRoomId = roomId;
    final room = availableRooms.firstWhere((r) => r['id'] == roomId);
    tienPhong = room['tienPhong'] ?? 0.0;
    
    // Set default initial values first
    soDienCu = 0.0;
    soNuocCu = 0.0;
    soDienMoi = 0;
    soNuocMoi = 0;
    isDienMoiEntered = false;
    isNuocMoiEntered = false;
    incidentalItems = [IncidentalFeeItem()];
    notifyListeners();

    // 1. Thử lấy chỉ số điện nước đã nhập của tháng hiện tại từ UtilityService
    try {
      final now = DateTime.now();
      final readings = await UtilityService().getReadings(now.month, now.year);
      final roomReading = readings.firstWhere(
        (r) => r['maPhong'] == roomId,
        orElse: () => <String, dynamic>{},
      );
      if (roomReading.isNotEmpty) {
        if (roomReading['chiSoDienCu'] != null) {
          soDienCu = (roomReading['chiSoDienCu'] as num).toDouble();
        }
        if (roomReading['chiSoNuocCu'] != null) {
          soNuocCu = (roomReading['chiSoNuocCu'] as num).toDouble();
        }
        if (roomReading['donGiaDien'] != null) {
          donGiaDien = (roomReading['donGiaDien'] as num).toDouble();
        }
        if (roomReading['donGiaNuoc'] != null) {
          donGiaNuoc = (roomReading['donGiaNuoc'] as num).toDouble();
        }
        
        // Chỉ return early nếu thực sự đã có bản ghi chỉ số tháng này trên hệ thống
        if (roomReading['maChiSo'] != null) {
          if (roomReading['chiSoDienMoi'] != null) {
            soDienMoi = (roomReading['chiSoDienMoi'] as num).toDouble();
            isDienMoiEntered = true;
          }
          if (roomReading['chiSoNuocMoi'] != null) {
            soNuocMoi = (roomReading['chiSoNuocMoi'] as num).toDouble();
            isNuocMoiEntered = true;
          }
          notifyListeners();
          return; // Đã tìm thấy chỉ số tiêu thụ đầy đủ tháng này, bỏ qua fallback hóa đơn cũ
        }
      }
    } catch (e) {
      debugPrint("Error fetching current month utility readings: $e");
    }

    // 2. Fallback: Lấy chỉ số mới nhất từ hóa đơn trước đó nếu tháng này chưa có ghi nhận điện nước
    try {
      final allInvoices = await _invoiceService.getInvoices(0, 0);
      final roomInvoices = allInvoices.where((inv) => inv.maPhong == roomId).toList();
      if (roomInvoices.isNotEmpty) {
        // Sắp xếp giảm dần theo năm và tháng để lấy hóa đơn gần nhất
        roomInvoices.sort((a, b) {
          if (a.nam != b.nam) {
            return b.nam.compareTo(a.nam);
          }
          return b.thang.compareTo(a.thang);
        });
        
        final latestInvoice = roomInvoices.first;
        soDienCu = latestInvoice.soDienMoi;
        soNuocCu = latestInvoice.soNuocMoi;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching latest readings for room: $e");
    }
  }

  void updateDienMoi(String value) {
    soDienMoi = double.tryParse(value) ?? 0;
    isDienMoiEntered = value.trim().isNotEmpty;
    notifyListeners();
  }

  void updateNuocMoi(String value) {
    soNuocMoi = double.tryParse(value) ?? 0;
    isNuocMoiEntered = value.trim().isNotEmpty;
    notifyListeners();
  }

  void addIncidentalItem() {
    incidentalItems.add(IncidentalFeeItem());
    notifyListeners();
  }

  void removeIncidentalItem(int index) {
    if (incidentalItems.length > 1) {
      incidentalItems.removeAt(index);
    } else {
      incidentalItems[0] = IncidentalFeeItem();
    }
    notifyListeners();
  }

  void updateIncidentalItemName(int index, String value) {
    if (index >= 0 && index < incidentalItems.length) {
      incidentalItems[index].name = value;
      notifyListeners();
    }
  }

  void updateIncidentalItemAmount(int index, String value) {
    if (index >= 0 && index < incidentalItems.length) {
      incidentalItems[index].amount = double.tryParse(value) ?? 0;
      notifyListeners();
    }
  }

  // Lấy danh sách hóa đơn theo tháng và năm
  Future<void> fetchInvoices(int month, int year) async {
    _setLoading(true);
    _setError(null);
    try {
      final list = await _invoiceService.getInvoices(month, year);
      
      // Tự động kiểm tra hóa đơn quá hạn
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final todayDate = DateTime.parse(todayStr);

      for (var i = 0; i < list.length; i++) {
        final inv = list[i];
        if (inv.trangThai == 'Chưa thanh toán' && inv.hanThanhToan != null) {
          try {
            final dueDate = DateTime.parse(inv.hanThanhToan!.substring(0, 10));
            if (dueDate.isBefore(todayDate)) {
              // Cập nhật trạng thái "Quá hạn" lên database
              await _invoiceService.updateInvoiceStatus(inv.maHoaDon, 'Quá hạn');
              // Cập nhật representation cục bộ
              list[i] = InvoiceModel(
                maHoaDon: inv.maHoaDon,
                maPhong: inv.maPhong,
                maKhach: inv.maKhach,
                tenPhong: inv.tenPhong,
                tenCoSo: inv.tenCoSo,
                tenKhachThue: inv.tenKhachThue,
                thang: inv.thang,
                nam: inv.nam,
                soDienCu: inv.soDienCu,
                soDienMoi: inv.soDienMoi,
                soNuocCu: inv.soNuocCu,
                soNuocMoi: inv.soNuocMoi,
                donGiaDien: inv.donGiaDien,
                donGiaNuoc: inv.donGiaNuoc,
                tienPhong: inv.tienPhong,
                tienDichVu: inv.tienDichVu,
                moTaDichVu: inv.moTaDichVu,
                phuPhi: inv.phuPhi,
                moTaPhuPhi: inv.moTaPhuPhi,
                tongTien: inv.tongTien,
                trangThai: 'Quá hạn',
                ngayLap: inv.ngayLap,
                hanThanhToan: inv.hanThanhToan,
                ngayThanhToan: inv.ngayThanhToan,
                soTaiKhoan: inv.soTaiKhoan,
                tenTaiKhoan: inv.tenTaiKhoan,
                maBin: inv.maBin,
                tenVietTat: inv.tenVietTat,
              );
            }
          } catch (_) {
            // Bỏ qua lỗi định dạng ngày
          }
        }
      }
      _invoices = list;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Lấy chi tiết hóa đơn
  Future<InvoiceModel?> fetchInvoiceDetail(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      final invoice = await _invoiceService.getInvoiceById(id);
      return invoice;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  String? validateRoomForInvoice(int roomId, int month, int year) {
    final room = availableRooms.firstWhere((r) => r['id'] == roomId, orElse: () => <String, dynamic>{});
    if (room.isEmpty) return 'Không tìm thấy thông tin phòng.';

    final trangThai = room['trangThai']?.toString().toLowerCase() ?? '';
    if (trangThai == 'trống' || trangThai.contains('trống')) {
      return 'Không thể lập hóa đơn cho phòng đang trống.';
    }
    if (trangThai == 'bảo trì' || trangThai.contains('bảo trì') || trangThai.contains('sửa chữa')) {
      return 'Không thể lập hóa đơn cho phòng đang bảo trì/sửa chữa.';
    }
    if (trangThai != 'đang thuê' && !trangThai.contains('đang thuê')) {
      return 'Chỉ có thể lập hóa đơn cho phòng đang ở trạng thái "Đang thuê".';
    }

    // Kiểm tra xem phòng này đã có hóa đơn trong tháng này chưa
    final alreadyInvoiced = _invoices.any((inv) => inv.maPhong == roomId && inv.thang == month && inv.nam == year);
    if (alreadyInvoiced) {
      return 'Phòng này đã được lập hóa đơn trong tháng $month/$year rồi.';
    }

    return null;
  }

  // Tạo hóa đơn mới
  Future<InvoiceModel?> createInvoice({
    required int maPhong,
    required int thang,
    required int nam,
    required double soDienCu,
    required double soDienMoi,
    required double soNuocCu,
    required double soNuocMoi,
    required double donGiaDien,
    required double donGiaNuoc,
    required double phuPhi,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newInvoice = await _invoiceService.createInvoice(
        maPhong: maPhong,
        thang: thang,
        nam: nam,
        soDienCu: soDienCu,
        soDienMoi: soDienMoi,
        soNuocCu: soNuocCu,
        soNuocMoi: soNuocMoi,
        donGiaDien: donGiaDien,
        donGiaNuoc: donGiaNuoc,
        phuPhi: phuPhi,
        moTaPhuPhi: tenPhuPhi.isNotEmpty ? tenPhuPhi : null,
      );
      
      // Thêm luôn vào danh sách nếu đang xem cùng tháng/năm
      if (thang == _selectedMonth && nam == _selectedYear) {
        _invoices.add(newInvoice);
      }
      notifyListeners();
      return newInvoice;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật hóa đơn
  Future<bool> updateInvoice({
    required int maHoaDon,
    required double soDienMoi,
    required double soNuocMoi,
    required double phuPhi,
    String? moTaPhuPhi,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _invoiceService.updateInvoice(
        maHoaDon: maHoaDon,
        soDienMoi: soDienMoi,
        soNuocMoi: soNuocMoi,
        phuPhi: phuPhi,
        moTaPhuPhi: moTaPhuPhi,
      );
      
      // Cập nhật hóa đơn trong list local
      final index = _invoices.indexWhere((inv) => inv.maHoaDon == maHoaDon);
      if (index != -1) {
        final current = _invoices[index];
        double soDienTieuThu = soDienMoi - current.soDienCu;
        double soNuocTieuThu = soNuocMoi - current.soNuocCu;
        double tienDien = soDienTieuThu * current.donGiaDien;
        double tienNuoc = soNuocTieuThu * current.donGiaNuoc;
        double totalNew = current.tienPhong + tienDien + tienNuoc + current.tienDichVu + phuPhi;

        _invoices[index] = InvoiceModel(
          maHoaDon: current.maHoaDon,
          maPhong: current.maPhong,
          maKhach: current.maKhach,
          tenPhong: current.tenPhong,
          tenCoSo: current.tenCoSo,
          tenKhachThue: current.tenKhachThue,
          thang: current.thang,
          nam: current.nam,
          soDienCu: current.soDienCu,
          soDienMoi: soDienMoi,
          soNuocCu: current.soNuocCu,
          soNuocMoi: soNuocMoi,
          donGiaDien: current.donGiaDien,
          donGiaNuoc: current.donGiaNuoc,
          tienPhong: current.tienPhong,
          tienDichVu: current.tienDichVu,
          moTaDichVu: current.moTaDichVu,
          phuPhi: phuPhi,
          moTaPhuPhi: moTaPhuPhi,
          tongTien: totalNew,
          trangThai: current.trangThai,
          ngayLap: current.ngayLap,
          hanThanhToan: current.hanThanhToan,
          ngayThanhToan: current.ngayThanhToan,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật trạng thái thanh toán
  Future<bool> updateStatus(int id, String trangThai) async {
    _setLoading(true);
    _setError(null);
    try {
      await _invoiceService.updateInvoiceStatus(id, trangThai);
      
      // Cập nhật UI list nếu tồn tại trong danh sách hiện tại
      final index = _invoices.indexWhere((inv) => inv.maHoaDon == id);
      if (index != -1) {
        final current = _invoices[index];
        _invoices[index] = InvoiceModel(
          maHoaDon: current.maHoaDon,
          maPhong: current.maPhong,
          maKhach: current.maKhach,
          tenPhong: current.tenPhong,
          tenCoSo: current.tenCoSo,
          tenKhachThue: current.tenKhachThue,
          thang: current.thang,
          nam: current.nam,
          soDienCu: current.soDienCu,
          soDienMoi: current.soDienMoi,
          soNuocCu: current.soNuocCu,
          soNuocMoi: current.soNuocMoi,
          donGiaDien: current.donGiaDien,
          donGiaNuoc: current.donGiaNuoc,
          tienPhong: current.tienPhong,
          tienDichVu: current.tienDichVu,
          moTaDichVu: current.moTaDichVu,
          phuPhi: current.phuPhi,
          moTaPhuPhi: current.moTaPhuPhi,
          tongTien: current.tongTien,
          trangThai: trangThai,
          ngayLap: current.ngayLap,
          hanThanhToan: current.hanThanhToan,
          ngayThanhToan: trangThai == 'Đã thanh toán' 
            ? DateTime.now().toIso8601String().substring(0, 10) 
            : current.ngayThanhToan,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa hóa đơn
  Future<bool> deleteInvoice(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _invoiceService.deleteInvoice(id);
      _invoices.removeWhere((inv) => inv.maHoaDon == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper cho trạng thái Loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper cho lỗi
  void _setError(String? message) {
    if (message != null && message.startsWith('Exception: ')) {
      _errorMessage = message.substring(11);
    } else {
      _errorMessage = message;
    }
    notifyListeners();
  }
}

class IncidentalFeeItem {
  String name;
  double amount;
  IncidentalFeeItem({this.name = '', this.amount = 0});
}
