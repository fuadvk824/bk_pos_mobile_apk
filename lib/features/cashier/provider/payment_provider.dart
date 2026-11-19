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
      payment: state.payment.copyWith(
        paymentStatus: status,
        payments: status == 'unpaid' ? [] : state.payment.payments,
      ),
    );
  }

  void addPayment(String method) {
    final currentPayments = [...state.payment.payments];

    final alreadyExists = currentPayments.any(
      (payment) => payment.paymentMethod == method,
    );

    if (alreadyExists) return;

    currentPayments.add(PaymentMethodEntry(paymentMethod: method, amount: 0));

    state = state.copyWith(
      payment: state.payment.copyWith(payments: currentPayments),
    );
  }

  void updatePaymentMethod(int index, String method) {
    final currentPayments = [...state.payment.payments];

    if (index < 0 || index >= currentPayments.length) return;

    final duplicate = currentPayments.asMap().entries.any(
      (entry) => entry.key != index && entry.value.paymentMethod == method,
    );

    if (duplicate) return;

    currentPayments[index] = currentPayments[index].copyWith(
      paymentMethod: method,
    );

    state = state.copyWith(
      payment: state.payment.copyWith(payments: currentPayments),
    );
  }

  void updatePaymentAmount(int index, double amount, double maxAmount) {
    if (index < 0 || index >= state.payment.payments.length) {
      return;
    }

    if (amount < 0) amount = 0;

    final currentPayments = [...state.payment.payments];

    final otherPayments = currentPayments
        .asMap()
        .entries
        .where((entry) => entry.key != index)
        .fold<double>(0, (sum, entry) => sum + entry.value.amount);

    final remaining = maxAmount - otherPayments;

    if (amount > remaining) {
      amount = remaining < 0 ? 0 : remaining;
    }

    currentPayments[index] = currentPayments[index].copyWith(amount: amount);

    state = state.copyWith(
      payment: state.payment.copyWith(payments: currentPayments),
    );
  }

  void removePayment(int index) {
    final currentPayments = [...state.payment.payments];

    if (index < 0 || index >= currentPayments.length) return;

    currentPayments.removeAt(index);

    state = state.copyWith(
      payment: state.payment.copyWith(payments: currentPayments),
    );
  }

  void updateNego(double value, double maxAmount) {
    if (value < 0) value = 0;

    if (value > maxAmount) {
      value = maxAmount;
    }

    state = state.copyWith(payment: state.payment.copyWith(nego: value));
  }

  void clear() {
    state = const PaymentState();
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(),
);
 