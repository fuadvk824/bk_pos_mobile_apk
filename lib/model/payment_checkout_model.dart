class PaymentMethodEntry {
  final String paymentMethod;
  final double amount;

  const PaymentMethodEntry({required this.paymentMethod, this.amount = 0});

  PaymentMethodEntry copyWith({String? paymentMethod, double? amount}) {
    return PaymentMethodEntry(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {'payment_method': paymentMethod, 'amount': amount};
  }
}

class PaymentCheckoutModel {
  final String paymentStatus;
  final List<PaymentMethodEntry> payments;
  final double nego;

  const PaymentCheckoutModel({
    this.paymentStatus = 'unpaid',
    this.payments = const [],
    this.nego = 0,
  });

  double get totalPayment {
    return payments.fold(0, (sum, payment) => sum + payment.amount);
  }

  PaymentCheckoutModel copyWith({
    String? paymentStatus,
    List<PaymentMethodEntry>? payments,
    double? nego,
  }) {
    return PaymentCheckoutModel(
      paymentStatus: paymentStatus ?? this.paymentStatus,
      payments: payments ?? this.payments,
      nego: nego ?? this.nego,
    );
  }
}

// class PaymentCheckoutModel {
//   final String paymentStatus;
//   final String paymentMethod;
//   final double paymentAmount;
//   final double nego;

//   const PaymentCheckoutModel({
//     this.paymentStatus = "unpaid",
//     this.paymentMethod = "cash",
//     this.paymentAmount = 0,
//     this.nego = 0,
//   });

//   PaymentCheckoutModel copyWith({
//     String? paymentStatus,
//     String? paymentMethod,
//     double? paymentAmount,
//     double? nego,
//   }) {
//     return PaymentCheckoutModel(
//       paymentStatus: paymentStatus ?? this.paymentStatus,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//       paymentAmount: paymentAmount ?? this.paymentAmount,
//       nego: nego ?? this.nego,
//     );
//   }
// }
