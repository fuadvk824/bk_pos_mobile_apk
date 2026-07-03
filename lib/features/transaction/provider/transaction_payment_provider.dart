import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

class TransactionPaymentState {
  final bool loading;

  const TransactionPaymentState({this.loading = false});

  TransactionPaymentState copyWith({bool? loading}) {
    return TransactionPaymentState(loading: loading ?? this.loading);
  }
}

class TransactionPaymentNotifier
    extends StateNotifier<TransactionPaymentState> {
  final TransactionRepository repo;

  TransactionPaymentNotifier(this.repo)
    : super(const TransactionPaymentState());

  Future<void> submit({
    required int transactionId,

    String? driverName,
    String? deliveryType,
    double? shippingCost,

    required String paymentMethod,

    required double amount,
  }) async {
    state = state.copyWith(loading: true);

    try {
      await repo.addPayment(
        transactionId: transactionId,
        driverName: driverName,
        deliveryType: deliveryType,
        shippingCost: shippingCost,
        paymentMethod: paymentMethod,
        amount: amount,
      );
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}

final transactionPaymentProvider =
    StateNotifierProvider<TransactionPaymentNotifier, TransactionPaymentState>((
      ref,
    ) {
      return TransactionPaymentNotifier(
        ref.read(transactionRepositoryProvider),
      );
    });
