import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/payment_checkout_model.dart';

class PaymentState {
  final PaymentCheckoutModel payment;

  const PaymentState({this.payment = const PaymentCheckoutModel()});

  PaymentState copyWith({PaymentCheckoutModel? payment}) {
    return PaymentState(payment: payment ?? this.payment);
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  void updateStatus(String status) {
    state = state.copyWith(
      payment: state.payment.copyWith(paymentStatus: status),
    );
  }

  void updateMethod(String method) {
    state = state.copyWith(
      payment: state.payment.copyWith(paymentMethod: method),
    );
  }

   
  void updateAmount(double amount, double maxAmount) {
    if (amount < 0) amount = 0;

    if (amount > maxAmount) {
      amount = maxAmount;
    }

    state = state.copyWith(
      payment: state.payment.copyWith(paymentAmount: amount),
    );
  }

  void clear() {
    state = const PaymentState();
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(),
);
