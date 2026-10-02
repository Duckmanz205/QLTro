class CoSo {
  final int maCoSo;
  final String tenCoSo;
  final String diaChi;
  final String? moTa;
  final String? loaiHinh;
  final int? maQuanLy;
  final double? latitude;
  final double? longitude;
  final double? danhGia;
  final String? trangThai;
  final DateTime? ngayTao;

  CoSo({
    required this.maCoSo,
    required this.tenCoSo,
    required this.diaChi,
    this.moTa,
    this.loaiHinh,
    this.maQuanLy,
    this.latitude,
    this.longitude,
    this.danhGia,
    this.trangThai,
    this.ngayTao,
  });

  factory CoSo.fromJson(Map<String, dynamic> json) {
    return CoSo(
      maCoSo: json['maCoSo'],
      tenCoSo: json['tenCoSo'] ?? '',
      diaChi: json['diaChi'] ?? '',
      moTa: json['moTa'],
      loaiHinh: json['loaiHinh'],
      maQuanLy: json['maQuanLy'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      danhGia: json['danhGia']?.toDouble(),
      trangThai: json['trangThai'],
      ngayTao: json['ngayTao'] != null ? DateTime.tryParse(json['ngayTao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maCoSo': maCoSo,
      'tenCoSo': tenCoSo,
      'diaChi': diaChi,
      'moTa': moTa,
      'loaiHinh': loaiHinh,
      'maQuanLy': maQuanLy,
      'latitude': latitude,
      'longitude': longitude,
      'danhGia': danhGia,
      'trangThai': trangThai,
      'ngayTao': ngayTao?.toIso8601String(),
    };
  }
}
