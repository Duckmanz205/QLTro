class ManagerModel {
  final int maQuanLy;
  final String tenQuanLy;
  final String? soDienThoai;
  final String? email;
  final int soCoSo;

  ManagerModel({
    required this.maQuanLy,
    required this.tenQuanLy,
    required this.soDienThoai,
    required this.email,
    required this.soCoSo,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      maQuanLy: json['maQuanLy'] ?? json['MaQuanLy'] ?? 0,
      tenQuanLy: json['tenQuanLy'] ?? json['TenQuanLy'] ?? '',
      soDienThoai: json['soDienThoai'] ?? json['SoDienThoai'],
      email: json['email'] ?? json['Email'],
      soCoSo: json['soCoSo'] ?? json['SoCoSo'] ?? 0,
    );
  }
}