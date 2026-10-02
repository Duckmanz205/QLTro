class TinNhan {
  final int maTinNhan;
  final int? maNguoiGui;
  final String vaiTroNguoiGui;
  final int? maNguoiNhan;
  final String vaiTroNguoiNhan;
  final String noiDung;
  final String ngayGui;
  final bool daDoc;

  TinNhan({
    required this.maTinNhan,
    this.maNguoiGui,
    required this.vaiTroNguoiGui,
    this.maNguoiNhan,
    required this.vaiTroNguoiNhan,
    required this.noiDung,
    required this.ngayGui,
    required this.daDoc,
  });

  factory TinNhan.fromJson(Map<String, dynamic> json) {
    return TinNhan(
      maTinNhan: json['maTinNhan'] ?? 0,
      maNguoiGui: json['maNguoiGui'],
      vaiTroNguoiGui: json['vaiTroNguoiGui'] ?? 'User',
      maNguoiNhan: json['maNguoiNhan'],
      vaiTroNguoiNhan: json['vaiTroNguoiNhan'] ?? 'Admin',
      noiDung: json['noiDung'] ?? '',
      ngayGui: json['ngayGui'] ?? '',
      daDoc: json['daDoc'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maTinNhan': maTinNhan,
      'maNguoiGui': maNguoiGui,
      'vaiTroNguoiGui': vaiTroNguoiGui,
      'maNguoiNhan': maNguoiNhan,
      'vaiTroNguoiNhan': vaiTroNguoiNhan,
      'noiDung': noiDung,
      'ngayGui': ngayGui,
      'daDoc': daDoc,
    };
  }
}
