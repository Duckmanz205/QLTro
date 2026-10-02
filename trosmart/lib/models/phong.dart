class Phong {
  final int maPhong;
  final int maCoSo;
  final String soPhong;
  final int? tang;
  final double? dienTich;
  final double giaThue;
  final int? soNguoiToiDa;
  final String? trangThai;
  final String? moTa;
  final DateTime? ngayTao;

  Phong({
    required this.maPhong,
    required this.maCoSo,
    required this.soPhong,
    this.tang,
    this.dienTich,
    required this.giaThue,
    this.soNguoiToiDa,
    this.trangThai,
    this.moTa,
    this.ngayTao,
  });

  factory Phong.fromJson(Map<String, dynamic> json) {
    return Phong(
      maPhong: json['maPhong'],
      maCoSo: json['maCoSo'],
      soPhong: json['soPhong'] ?? '',
      tang: json['tang'],
      dienTich: json['dienTich']?.toDouble(),
      giaThue: json['giaThue']?.toDouble() ?? 0.0,
      soNguoiToiDa: json['soNguoiToiDa'],
      trangThai: json['trangThai'],
      moTa: json['moTa'],
      ngayTao: json['ngayTao'] != null ? DateTime.tryParse(json['ngayTao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maPhong': maPhong,
      'maCoSo': maCoSo,
      'soPhong': soPhong,
      'tang': tang,
      'dienTich': dienTich,
      'giaThue': giaThue,
      'soNguoiToiDa': soNguoiToiDa,
      'trangThai': trangThai,
      'moTa': moTa,
      'ngayTao': ngayTao?.toIso8601String(),
    };
  }
}
