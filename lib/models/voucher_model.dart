class VoucherModel {
  String id;
  String code;
  double percentage;
  bool used;

  VoucherModel(
      {required this.id,
      required this.code,
      required this.percentage,
      required this.used});

  Map<String, dynamic> toMap() {
    return {'code': code, 'percentage': percentage, 'used': used};
  }
}
