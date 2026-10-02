class InvoiceModel {
  final int maHoaDon;
  final int maPhong;
  final int? maKhach;
  final String tenPhong;
  final String tenCoSo;
  final String tenKhachThue;
  final int thang;
  final int nam;
  final double soDienCu;
  final double soDienMoi;
  final double soNuocCu;
  final double soNuocMoi;
  final double donGiaDien;
  final double donGiaNuoc;
  final double tienPhong;
  final double tienDichVu;
  final String? moTaDichVu;
  final double phuPhi;
  final String? moTaPhuPhi;
  final double tongTien;
  final String trangThai;
  final String? ngayLap;
  final String? hanThanhToan;
  final String? ngayThanhToan;

  // Banking Details
  final String? soTaiKhoan;
  final String? tenTaiKhoan;
  final String? maBin;
  final String? tenVietTat;

  InvoiceModel({
    required this.maHoaDon,
    required this.maPhong,
    this.maKhach,
    required this.tenPhong,
    this.tenCoSo = '',
    this.tenKhachThue = '',
    required this.thang,
    required this.nam,
    required this.soDienCu,
    required this.soDienMoi,
    required this.soNuocCu,
    required this.soNuocMoi,
    this.donGiaDien = 3500,
    this.donGiaNuoc = 20000,
    required this.tienPhong,
    this.tienDichVu = 0,
    this.moTaDichVu,
    required this.phuPhi,
    this.moTaPhuPhi,
    required this.tongTien,
    required this.trangThai,
    this.ngayLap,
    this.hanThanhToan,
    this.ngayThanhToan,
    this.soTaiKhoan,
    this.tenTaiKhoan,
    this.maBin,
    this.tenVietTat,
  });

  /// Tiền điện tính toán
  double get tienDien => (soDienMoi - soDienCu) * donGiaDien;

  /// Tiền nước tính toán
  double get tienNuoc => (soNuocMoi - soNuocCu) * donGiaNuoc;

  /// Hạn thanh toán dạng hiển thị dd/MM/yyyy
  String get hanThanhToanDisplay {
    if (hanThanhToan == null || hanThanhToan!.isEmpty) return 'Chưa xác định';
    try {
      final parts = hanThanhToan!.split('-');
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {
      return hanThanhToan!;
    }
  }

  /// Ngày lập dạng hiển thị dd/MM/yyyy
  String get ngayLapDisplay {
    if (ngayLap == null || ngayLap!.isEmpty) return 'Chưa xác định';
    try {
      final parts = ngayLap!.split('-');
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {
      return ngayLap!;
    }
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      maHoaDon: json['maHoaDon'] ?? 0,
      maPhong: json['maPhong'] ?? 0,
      maKhach: json['maKhach'],
      tenPhong: json['tenPhong'] ?? '',
      tenCoSo: json['tenCoSo'] ?? '',
      tenKhachThue: json['tenKhachThue'] ?? '',
      thang: json['thang'] ?? 1,
      nam: json['nam'] ?? 2024,
      soDienCu: (json['soDienCu'] ?? 0).toDouble(),
      soDienMoi: (json['soDienMoi'] ?? 0).toDouble(),
      soNuocCu: (json['soNuocCu'] ?? 0).toDouble(),
      soNuocMoi: (json['soNuocMoi'] ?? 0).toDouble(),
      donGiaDien: (json['donGiaDien'] ?? 3500).toDouble(),
      donGiaNuoc: (json['donGiaNuoc'] ?? 20000).toDouble(),
      tienPhong: (json['tienPhong'] ?? 0).toDouble(),
      tienDichVu: (json['tienDichVu'] ?? 0).toDouble(),
      moTaDichVu: json['moTaDichVu'],
      phuPhi: (json['phuPhi'] ?? 0).toDouble(),
      moTaPhuPhi: json['moTaPhuPhi'],
      tongTien: (json['tongTien'] ?? 0).toDouble(),
      trangThai: json['trangThai'] ?? 'Chưa thanh toán',
      ngayLap: json['ngayLap'],
      hanThanhToan: json['hanThanhToan'],
      ngayThanhToan: json['ngayThanhToan'],
      soTaiKhoan: json['soTaiKhoan'] as String?,
      tenTaiKhoan: json['tenTaiKhoan'] as String?,
      maBin: json['maBin'] as String?,
      tenVietTat: json['tenVietTat'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maHoaDon': maHoaDon,
      'maPhong': maPhong,
      'maKhach': maKhach,
      'tenPhong': tenPhong,
      'tenCoSo': tenCoSo,
      'tenKhachThue': tenKhachThue,
      'thang': thang,
      'nam': nam,
      'soDienCu': soDienCu,
      'soDienMoi': soDienMoi,
      'soNuocCu': soNuocCu,
      'soNuocMoi': soNuocMoi,
      'donGiaDien': donGiaDien,
      'donGiaNuoc': donGiaNuoc,
      'tienPhong': tienPhong,
      'tienDichVu': tienDichVu,
      'moTaDichVu': moTaDichVu,
      'phuPhi': phuPhi,
      'moTaPhuPhi': moTaPhuPhi,
      'tongTien': tongTien,
      'trangThai': trangThai,
      'ngayLap': ngayLap,
      'hanThanhToan': hanThanhToan,
      'ngayThanhToan': ngayThanhToan,
      'soTaiKhoan': soTaiKhoan,
      'tenTaiKhoan': tenTaiKhoan,
      'maBin': maBin,
      'tenVietTat': tenVietTat,
    };
  }
}
