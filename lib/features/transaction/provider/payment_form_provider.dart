import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/transaction_detail_model.dart';
import '../data/transaction_repository.dart';
import 'transaction_provider.dart';

final paymentFormProvider =
    StateNotifierProvider.autoDispose<PaymentFormNotifier, PaymentFormState>(
      (ref) => PaymentFormNotifier(ref.read(transactionRepositoryProvider)),
    );

class PaymentFormState {
  final bool loading;
  final String deliveryType;
  final String paymentMethod;
  final double shippingCost;
  final double amount;
  final bool amountEdited;
  final String driver;
  final String notes;

  const PaymentFormState({
    this.loading = false,
    this.deliveryType = "pickup",
    this.paymentMethod = "cash",
    this.shippingCost = 0,
    this.amount = 0,
    this.amountEdited = false,
    this.driver = "",
    this.notes = "",
  });

  PaymentFormState copyWith({
    bool? loading,
    String? deliveryType,
    String? paymentMethod,
    double? shippingCost,
    double? amount,
    bool? amountEdited,
    String? driver,
    String? notes,
  }) {
    return PaymentFormState(
      loading: loading ?? this.loading,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingCost: shippingCost ?? this.shippingCost,
      amount: amount ?? this.amount,
      amountEdited: amountEdited ?? this.amountEdited,
      driver: driver ?? this.driver,
      notes: notes ?? this.notes,
    );
  }
}

class PaymentFormNotifier extends StateNotifier<PaymentFormState> {
  final TransactionRepository repo;

  PaymentFormNotifier(this.repo) : super(const PaymentFormState());

  void initialize(TransactionDetailModel trx) {
    state = state.copyWith(
      deliveryType: trx.deliveryType ?? "pickup",
      shippingCost: trx.shippingCost,
      driver: trx.driverName ?? "",
      notes: trx.notes ?? "",
      amount: remaining(trx),
      amountEdited: false,
    );
  }

  void setDelivery(String value) {
    state = state.copyWith(
      deliveryType: value,
      shippingCost: value == "pickup" ? 0 : state.shippingCost,
    );
  }

  void setPaymentMethod(String value) {
    state = state.copyWith(paymentMethod: value);
  }

  void setShipping(double value) {
    state = state.copyWith(shippingCost: value);
  }

  void setDriver(String value) {
    state = state.copyWith(driver: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void setAmount(double value) {
    state = state.copyWith(amount: value, amountEdited: true);
  }

  void refreshAmount(TransactionDetailModel trx) {
    if (state.amountEdited) return;

    state = state.copyWith(amount: remaining(trx));
  }

  /// ===============================
  /// Calculator
  /// ===============================

  double paid(TransactionDetailModel trx) {
    return trx.payments.fold<double>(0, (sum, e) => sum + e.amount);
  }

  double total(TransactionDetailModel trx) {
    if (trx.paymentStatus == "unpaid") {
      return trx.subtotal +
          (state.deliveryType == "delivery" ? state.shippingCost : 0);
    }

    return trx.total;
  }

  double remaining(TransactionDetailModel trx) {
    return total(trx) - paid(trx);
  }

  /// ===============================
  /// Validation
  /// ===============================

  String? validate(TransactionDetailModel trx) {
    //tambahan
    final isPaid = trx.paymentStatus.toLowerCase() == 'paid';

    if (isPaid) {
      if (state.deliveryType == 'delivery' && state.driver.trim().isEmpty) {
        return "Driver wajib diisi";
      }

      return null;
    }
    //tambahan

    if (state.amount <= 0) {
      return "Nominal tidak valid";
    }

    if (state.deliveryType == "delivery" && state.driver.trim().isEmpty) {
      return "Driver wajib diisi";
    }

    if (state.amount > remaining(trx)) {
      return "Nominal melebihi sisa pembayaran";
    }

    return null;
  }

  /// ===============================
  /// Submit
  /// ===============================

  Future<void> submit(TransactionDetailModel trx) async {
    //tambahan
    final isPaid = trx.paymentStatus.toLowerCase() == 'paid';

    if (isPaid) {
      if (state.deliveryType == 'pickup') {
        await repo.updateNotes(
          transactionId: trx.id,
          notes: state.notes.trim(),
        );
        return;
      }

      final driver = state.driver.trim();

      if (driver.isEmpty) {
        throw Exception("Driver wajib diisi");
      }

      state = state.copyWith(loading: true);

      try {
        await repo.updateDriver(transactionId: trx.id, driverName: driver);
        await repo.updateNotes(
          transactionId: trx.id,
          notes: state.notes.trim(),
        );
      } finally {
        state = state.copyWith(loading: false);
      }

      return;
    }
    //tambahan

    final error = validate(trx);

    if (error != null) {
      throw Exception(error);
    }

    state = state.copyWith(loading: true);

    try {
      await repo.addPayment(
        transactionId: trx.id,
        paymentMethod: state.paymentMethod,
        amount: state.amount > remaining(trx) ? remaining(trx) : state.amount,
        driverName: state.deliveryType == "delivery"
            ? state.driver.trim()
            : null,
        deliveryType: trx.paymentStatus == "unpaid" ? state.deliveryType : null,
        shippingCost:
            trx.paymentStatus == "unpaid" && state.deliveryType == "delivery"
            ? state.shippingCost
            : null,
        notes: state.notes.trim(),
      );
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  /// Reset ketika BottomSheet ditutup
  void reset() {
    state = const PaymentFormState();
  }
}
