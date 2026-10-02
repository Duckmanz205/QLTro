class CoSoDashboardModel {
  final int maCoSo;
  final String tenCoSo;
  final String diaChi;
  final String status;

  final int tongPhong;
  final int phongTrong;
  final int daThue;

  final double? lapDay;
  final num? doanhThu;
  final String? hinhAnhCoSo;

  final List<String> tienIches;

  CoSoDashboardModel({
    required this.maCoSo,
    required this.tenCoSo,
    required this.diaChi,
    required this.status,
    required this.tongPhong,
    required this.phongTrong,
    required this.daThue,
    this.lapDay,
    this.doanhThu,
    this.hinhAnhCoSo,
    this.tienIches = const [],
  });

  factory CoSoDashboardModel.fromJson(Map<String, dynamic> json) {
    dynamic get(String camel, String pascal) => json[camel] ?? json[pascal];

    return CoSoDashboardModel(
      maCoSo: get('maCoSo', 'MaCoSo') ?? 0,
      tenCoSo: get('tenCoSo', 'TenCoSo') ?? '',
      diaChi: get('diaChi', 'DiaChi') ?? '',
      status: get('status', 'Status') ?? 'Hoạt động',
      tongPhong: get('tongPhong', 'TongPhong') ?? 0,
      phongTrong: get('phongTrong', 'PhongTrong') ?? 0,
      daThue: get('daThue', 'DaThue') ?? 0,
      lapDay: (get('lapDay', 'LapDay') as num?)?.toDouble(),
      doanhThu: get('doanhThu', 'DoanhThu'),
      hinhAnhCoSo: get('hinhAnhCoSo', 'HinhAnhCoSo'),
      tienIches: ((get('tienIches', 'TienIches') as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}