class CoSoDetailModel {
  final int maCoSo;
  final String tenCoSo;
  final String diaChi;
  final String loaiHinh;
  final int? maQuanLy;
  final String? moTa;
  final double? latitude;
  final double? longitude;

  final String? tenQuanLy;
  final String? soDienThoaiQuanLy;
  final String? emailQuanLy;

  final String? hinhAnhCoSo;

  final int tongPhong;
  final int phongTrong;
  final int daThue;

  final List<TienIchMiniModel> tienIches;
  final List<PhongMiniModel> phongs;

  CoSoDetailModel({
    required this.maCoSo,
    required this.tenCoSo,
    required this.diaChi,
    required this.loaiHinh,
    required this.maQuanLy,
    required this.moTa,
    required this.latitude,
    required this.longitude,
    required this.tenQuanLy,
    required this.soDienThoaiQuanLy,
    required this.emailQuanLy,
    required this.hinhAnhCoSo,
    required this.tongPhong,
    required this.phongTrong,
    required this.daThue,
    required this.tienIches,
    required this.phongs,
  });

  factory CoSoDetailModel.fromJson(Map<String, dynamic> json) {
    dynamic get(String camel, String pascal) => json[camel] ?? json[pascal];

    return CoSoDetailModel(
      maCoSo: get('maCoSo', 'MaCoSo') ?? 0,
      tenCoSo: get('tenCoSo', 'TenCoSo') ?? '',
      diaChi: get('diaChi', 'DiaChi') ?? '',
      loaiHinh: get('loaiHinh', 'LoaiHinh') ?? '',
      maQuanLy: get('maQuanLy', 'MaQuanLy'),
      moTa: get('moTa', 'MoTa'),
      latitude: (get('latitude', 'Latitude') as num?)?.toDouble(),
      longitude: (get('longitude', 'Longitude') as num?)?.toDouble(),
      tenQuanLy: get('tenQuanLy', 'TenQuanLy'),
      soDienThoaiQuanLy: get('soDienThoaiQuanLy', 'SoDienThoaiQuanLy'),
      emailQuanLy: get('emailQuanLy', 'EmailQuanLy'),
      hinhAnhCoSo: get('hinhAnhCoSo', 'HinhAnhCoSo'),
      tongPhong: get('tongPhong', 'TongPhong') ?? 0,
      phongTrong: get('phongTrong', 'PhongTrong') ?? 0,
      daThue: get('daThue', 'DaThue') ?? 0,
      tienIches: ((get('tienIches', 'TienIches') as List?) ?? [])
          .map((e) => TienIchMiniModel.fromJson(e))
          .toList(),
      phongs: ((get('phongs', 'Phongs') as List?) ?? [])
          .map((e) => PhongMiniModel.fromJson(e))
          .toList(),
    );
  }
}

class TienIchMiniModel {
  final int maTienIch;
  final String tenTienIch;

  TienIchMiniModel({
    required this.maTienIch,
    required this.tenTienIch,
  });

  factory TienIchMiniModel.fromJson(Map<String, dynamic> json) {
    return TienIchMiniModel(
      maTienIch: json['maTienIch'] ?? json['MaTienIch'] ?? 0,
      tenTienIch: json['tenTienIch'] ?? json['TenTienIch'] ?? '',
    );
  }
}

class PhongMiniModel {
  final int maPhong;
  final String soPhong;
  final String trangThai;

  PhongMiniModel({
    required this.maPhong,
    required this.soPhong,
    required this.trangThai,
  });

  factory PhongMiniModel.fromJson(Map<String, dynamic> json) {
    return PhongMiniModel(
      maPhong: json['maPhong'] ?? json['MaPhong'] ?? 0,
      soPhong: json['soPhong'] ?? json['SoPhong'] ?? '',
      trangThai: json['trangThai'] ?? json['TrangThai'] ?? '',
    );
  }

  bool get trong => trangThai.trim().toLowerCase() == 'trống';
  bool get coNguoi => trangThai.trim().toLowerCase() == 'đang thuê';
  bool get baoTri => trangThai.trim().toLowerCase() == 'bảo trì';
}