class TienIchModel {
  final int maTienIch;
  final String tenTienIch;

  TienIchModel({
    required this.maTienIch,
    required this.tenTienIch,
  });

  factory TienIchModel.fromJson(Map<String, dynamic> json) {
    return TienIchModel(
      maTienIch: json['maTienIch'] ?? json['MaTienIch'] ?? 0,
      tenTienIch: json['tenTienIch'] ?? json['TenTienIch'] ?? '',
    );
  }
}