class NguoiQuanLy {
  final int maQuanLy;
  final String hoTen;
  final String? sdt;
  final String? email;
  final String? tenNganHang;
  final String? soTaiKhoan;
  final String? chuTaiKhoan;

  NguoiQuanLy({
    required this.maQuanLy,
    required this.hoTen,
    this.sdt,
    this.email,
    this.tenNganHang,
    this.soTaiKhoan,
    this.chuTaiKhoan,
  });

  factory NguoiQuanLy.fromJson(Map<String, dynamic> json) {
    return NguoiQuanLy(
      maQuanLy: json['maQuanLy'] ?? 0,
      hoTen: json['hoTen'] ?? '',
      sdt: json['sdt'],
      email: json['email'],
      tenNganHang: json['tenNganHang'],
      soTaiKhoan: json['soTaiKhoan'],
      chuTaiKhoan: json['tenTaiKhoan'], // Changed from chuTaiKhoan
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maQuanLy': maQuanLy,
      'hoTen': hoTen,
      'sdt': sdt,
      'email': email,
      'tenNganHang': tenNganHang,
      'soTaiKhoan': soTaiKhoan,
      'tenTaiKhoan': chuTaiKhoan, // Changed from chuTaiKhoan
    };
  }
}
