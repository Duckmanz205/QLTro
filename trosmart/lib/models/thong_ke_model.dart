class AdminThongKeModel {
  final double tongDoanhThuDaThu;
  final double tongDoanhThuChuaThu;
  final int tongSoCoSo;
  final int tongSoPhong;
  final double tiLeLapDay;
  final int phongDangThue;
  final int phongTrong;
  final int phongBaoTri;
  final List<DoanhThuThangModel> doanhThuTheoThang;
  final int tongSuCo;
  final int suCoChuaXuLy;

  AdminThongKeModel({
    required this.tongDoanhThuDaThu,
    required this.tongDoanhThuChuaThu,
    required this.tongSoCoSo,
    required this.tongSoPhong,
    required this.tiLeLapDay,
    required this.phongDangThue,
    required this.phongTrong,
    required this.phongBaoTri,
    required this.doanhThuTheoThang,
    required this.tongSuCo,
    required this.suCoChuaXuLy,
  });

  factory AdminThongKeModel.fromJson(Map<String, dynamic> json) {
    var dtList = json['doanhThuTheoThang'] as List? ?? [];
    List<DoanhThuThangModel> listDt = dtList.map((i) => DoanhThuThangModel.fromJson(i)).toList();

    return AdminThongKeModel(
      tongDoanhThuDaThu: (json['tongDoanhThuDaThu'] as num? ?? 0).toDouble(),
      tongDoanhThuChuaThu: (json['tongDoanhThuChuaThu'] as num? ?? 0).toDouble(),
      tongSoCoSo: json['tongSoCoSo'] as int? ?? 0,
      tongSoPhong: json['tongSoPhong'] as int? ?? 0,
      tiLeLapDay: (json['tiLeLapDay'] as num? ?? 0).toDouble(),
      phongDangThue: json['phongDangThue'] as int? ?? 0,
      phongTrong: json['phongTrong'] as int? ?? 0,
      phongBaoTri: json['phongBaoTri'] as int? ?? 0,
      doanhThuTheoThang: listDt,
      tongSuCo: json['tongSuCo'] as int? ?? 0,
      suCoChuaXuLy: json['suCoChuaXuLy'] as int? ?? 0,
    );
  }
}

class DoanhThuThangModel {
  final int thang;
  final double daThanhToan;
  final double chuaThanhToan;

  DoanhThuThangModel({
    required this.thang,
    required this.daThanhToan,
    required this.chuaThanhToan,
  });

  factory DoanhThuThangModel.fromJson(Map<String, dynamic> json) {
    return DoanhThuThangModel(
      thang: json['thang'] as int? ?? 0,
      daThanhToan: (json['daThanhToan'] as num? ?? 0).toDouble(),
      chuaThanhToan: (json['chuaThanhToan'] as num? ?? 0).toDouble(),
    );
  }
}

class UserThongKeModel {
  final double tongTienDaThanhToan;
  final double tongTienChuaThanhToan;
  final double tienCocHienTai;
  final String tenPhongHienTai;
  final String tenCoSoHienTai;
  final List<ChiTieuThangModel> lichSuChiTieu;
  final List<TieuThuDienNuocModel> lichSuTieuThu;

  UserThongKeModel({
    required this.tongTienDaThanhToan,
    required this.tongTienChuaThanhToan,
    required this.tienCocHienTai,
    required this.tenPhongHienTai,
    required this.tenCoSoHienTai,
    required this.lichSuChiTieu,
    required this.lichSuTieuThu,
  });

  factory UserThongKeModel.fromJson(Map<String, dynamic> json) {
    var ctList = json['lichSuChiTieu'] as List? ?? [];
    List<ChiTieuThangModel> listCt = ctList.map((i) => ChiTieuThangModel.fromJson(i)).toList();

    var ttList = json['lichSuTieuThu'] as List? ?? [];
    List<TieuThuDienNuocModel> listTt = ttList.map((i) => TieuThuDienNuocModel.fromJson(i)).toList();

    return UserThongKeModel(
      tongTienDaThanhToan: (json['tongTienDaThanhToan'] as num? ?? 0).toDouble(),
      tongTienChuaThanhToan: (json['tongTienChuaThanhToan'] as num? ?? 0).toDouble(),
      tienCocHienTai: (json['tienCocHienTai'] as num? ?? 0).toDouble(),
      tenPhongHienTai: json['tenPhongHienTai'] as String? ?? 'Chưa thuê',
      tenCoSoHienTai: json['tenCoSoHienTai'] as String? ?? 'Chưa có',
      lichSuChiTieu: listCt,
      lichSuTieuThu: listTt,
    );
  }
}

class ChiTieuThangModel {
  final String kyThanhToan;
  final double tongTien;

  ChiTieuThangModel({
    required this.kyThanhToan,
    required this.tongTien,
  });

  factory ChiTieuThangModel.fromJson(Map<String, dynamic> json) {
    return ChiTieuThangModel(
      kyThanhToan: json['kyThanhToan'] as String? ?? '',
      tongTien: (json['tongTien'] as num? ?? 0).toDouble(),
    );
  }
}

class TieuThuDienNuocModel {
  final String kyThanhToan;
  final int soDienTieuThu;
  final int soNuocTieuThu;

  TieuThuDienNuocModel({
    required this.kyThanhToan,
    required this.soDienTieuThu,
    required this.soNuocTieuThu,
  });

  factory TieuThuDienNuocModel.fromJson(Map<String, dynamic> json) {
    return TieuThuDienNuocModel(
      kyThanhToan: json['kyThanhToan'] as String? ?? '',
      soDienTieuThu: json['soDienTieuThu'] as int? ?? 0,
      soNuocTieuThu: json['soNuocTieuThu'] as int? ?? 0,
    );
  }
}
