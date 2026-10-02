class ThongBao {
  final int maThongBao;
  final int maKhach;
  final String tieuDe;
  final String? noiDung;
  final bool daDoc;
  final DateTime? ngayGui;
  
  // Optional fields that might be used by UI but not in DB
  final String loaiThongBao;

  ThongBao({
    required this.maThongBao,
    required this.maKhach,
    required this.tieuDe,
    this.noiDung,
    this.daDoc = false,
    this.ngayGui,
    this.loaiThongBao = 'Hệ thống',
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      maThongBao: json['maThongBao'] ?? 0,
      maKhach: json['maKhach'] ?? 0,
      tieuDe: json['tieuDe'] ?? '',
      noiDung: json['noiDung'],
      daDoc: json['daDoc'] ?? false,
      ngayGui: json['ngayGui'] != null ? DateTime.tryParse(json['ngayGui']) : null,
      loaiThongBao: json['loaiThongBao'] ?? 'Hệ thống',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maThongBao': maThongBao,
      'maKhach': maKhach,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'daDoc': daDoc,
      'ngayGui': ngayGui?.toIso8601String(),
      'loaiThongBao': loaiThongBao,
    };
  }
}
