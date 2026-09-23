
class PaymentCheckoutModel {
  final String paymentStatus;
  final String paymentMethod;
  final double paymentAmount;
  final double nego;

  const PaymentCheckoutModel({
    this.paymentStatus = "unpaid",
    this.paymentMethod = "cash",
    this.paymentAmount = 0,
    this.nego = 0,
  });

  PaymentCheckoutModel copyWith({
    String? paymentStatus,
    String? paymentMethod,
    double? paymentAmount,
    double? nego,
  }) {
    return PaymentCheckoutModel(
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      nego: nego ?? this.nego,
    );
  }
}
