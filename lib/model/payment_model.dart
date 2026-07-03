class PaymentModel {
  final int id;
  final double amount;
  final String paymentMethod;
  final String? paidAt;
  final String? cashierName;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paidAt,
    required this.cashierName,
  });

  factory PaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentModel(
      id: json['id'] ?? 0,

      amount:
          double.tryParse(
            json['amount'].toString(),
          ) ??
          0,

      paymentMethod:
          json['payment_method'] ?? '',

      paidAt: json['paid_at'],

      cashierName: json['cashier_name'],
    );
  }
}
