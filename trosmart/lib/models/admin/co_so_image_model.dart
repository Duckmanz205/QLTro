class CoSoImageModel {
  final int maAnh;
  final int maCoSo;
  final String urlAnh;
  final bool isMain;

  CoSoImageModel({
    required this.maAnh,
    required this.maCoSo,
    required this.urlAnh,
    required this.isMain,
  });

  factory CoSoImageModel.fromJson(Map<String, dynamic> json) {
    return CoSoImageModel(
      maAnh: json['maAnh'] ?? json['MaAnh'] ?? 0,
      maCoSo: json['maCoSo'] ?? json['MaCoSo'] ?? 0,
      urlAnh: json['urlAnh'] ?? json['UrlAnh'] ?? '',
      isMain: json['isMain'] ?? json['IsMain'] ?? false,
    );
  }
}