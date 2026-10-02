class PhongViewModel {
  final int maPhong;
  final int maCoSo;
  final String tenCoSo;
  final String diaChi;
  final String soPhong;
  final int tang;
  final double dienTich;
  final double giaThue;
  final int soNguoiToiDa;
  final String trangThai;
  final String? moTa;
  final int nguoiQuanLyId;
  final String tenNguoiQuanLy;

  final String? hinhAnhPhong;
  final List<String> tienIches;

  final double latitude;
  final double longitude;
  final String? hinhAnhCoSo;

  const PhongViewModel({
    required this.maPhong,
    required this.maCoSo,
    required this.tenCoSo,
    required this.diaChi,
    required this.soPhong,
    required this.tang,
    required this.dienTich,
    required this.giaThue,
    required this.soNguoiToiDa,
    required this.trangThai,
    required this.moTa,
    required this.nguoiQuanLyId,
    required this.tenNguoiQuanLy,
    required this.hinhAnhPhong,
    required this.tienIches,
    required this.latitude,
    required this.longitude,
    required this.hinhAnhCoSo,
  });

  factory PhongViewModel.fromJson(Map<String, dynamic> json) {
    return PhongViewModel(
      maPhong: _toInt(json['maPhong']),
      maCoSo: _toInt(json['maCoSo']),
      tenCoSo: _toString(json['tenCoSo']),
      diaChi: _toString(json['diaChi']),
      soPhong: _toString(json['soPhong']),
      tang: _toInt(json['tang']),
      dienTich: _toDouble(json['dienTich']),
      giaThue: _toDouble(json['giaThue']),
      soNguoiToiDa: _toInt(json['soNguoiToiDa']),
      trangThai: _toString(json['trangThai']),
      moTa: json['moTa']?.toString(),
      nguoiQuanLyId: _toInt(json['nguoiQuanLyId']),
      tenNguoiQuanLy: _toString(json['tenNguoiQuanLy']),
      hinhAnhPhong: json['hinhAnhPhong']?.toString(),
      tienIches: _toStringList(json['tienIches']),

      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      hinhAnhCoSo: json['hinhAnhCoSo']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _toString(dynamic value) {
    return value?.toString() ?? '';
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .where((e) => e != null)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  bool get isTrong {
    return trangThai.toLowerCase().trim() == 'trống';
  }

  bool get isDangThue {
    return trangThai.toLowerCase().trim() == 'đang thuê';
  }

  bool get isBaoTri {
    return trangThai.toLowerCase().trim() == 'bảo trì';
  }

  String get giaThueText {
    final million = giaThue / 1000000;
    final text = million.toStringAsFixed(1).replaceAll('.0', '');
    return '${text}tr';
  }

  String get dienTichText {
    final text = dienTich.toStringAsFixed(1).replaceAll('.0', '');
    return '${text}m²';
  }

  String get displayStatus {
    if (isTrong) return 'Còn trống';
    if (isDangThue) return 'Đang thuê';
    if (isBaoTri) return 'Bảo trì';
    return trangThai;
  }

  bool get hasImage {
    return hinhAnhPhong != null && hinhAnhPhong!.trim().isNotEmpty;
  }

  bool get hasCoSoImage {
    return hinhAnhCoSo != null && hinhAnhCoSo!.trim().isNotEmpty;
  }

  bool get hasLocation {
    return latitude != 0 && longitude != 0;
  }

  String get tienIchText {
    if (tienIches.isEmpty) return 'Chưa có tiện ích';
    return tienIches.join(', ');
  }
}