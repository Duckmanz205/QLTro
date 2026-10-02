class PhongModel {
  final int maPhong;
  final String soPhong;
  final num giaThue;
  final String trangThai;
  final int maCoSo;
  final String? tenCoSo;

  final int? tang;
  final num? dienTich;
  final int? soNguoiToiDa;
  final String? moTa;
  final String? hinhAnhPhong;

  final List<String> tienIches;
  

  PhongModel({
    required this.maPhong,
    required this.soPhong,
    required this.giaThue,
    required this.trangThai,
    required this.maCoSo,
    this.tenCoSo,
    this.tang,
    this.dienTich,
    this.soNguoiToiDa,
    this.moTa,
    this.hinhAnhPhong,
    this.tienIches = const [],
    
  });

  factory PhongModel.fromJson(Map<String, dynamic> json) {
    dynamic get(String pascal, String camel) => json[pascal] ?? json[camel];

    return PhongModel(
      maPhong: get('MaPhong', 'maPhong') ?? 0,
      soPhong: '${get('SoPhong', 'soPhong') ?? ''}',
      giaThue: get('GiaThue', 'giaThue') ?? 0,
      trangThai: '${get('TrangThai', 'trangThai') ?? ''}',
      maCoSo: get('MaCoSo', 'maCoSo') ?? 0,
      tenCoSo: get('TenCoSo', 'tenCoSo'),
      tang: get('Tang', 'tang'),
      dienTich: get('DienTich', 'dienTich'),
      soNguoiToiDa: get('SoNguoiToiDa', 'soNguoiToiDa'),
      moTa: get('MoTa', 'moTa'),
      hinhAnhPhong: get('HinhAnhPhong', 'hinhAnhPhong'),
      tienIches: ((get('TienIches', 'tienIches') as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool get dangThue => trangThai.toLowerCase().trim() == 'đang thuê';
  bool get trong => trangThai.toLowerCase().trim() == 'trống';
  bool get baoTri => trangThai.toLowerCase().trim() == 'bảo trì';

  String get statusLabel {
    if (dangThue) return 'Đang thuê';
    if (trong) return 'Trống';
    if (baoTri) return 'Bảo trì';
    return trangThai;
  }
}