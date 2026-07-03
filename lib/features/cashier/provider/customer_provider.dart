import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/customer_model.dart';
import '../data/customer_repository.dart';

class CustomerState {
  final CustomerModel customer;
  final List<CustomerModel> customers;
  final bool loading;
  final bool showResult;
  final int pointsUsed;

  const CustomerState({
    this.customer = const CustomerModel(),
    this.customers = const [],
    this.loading = false,
    this.showResult = false,
    this.pointsUsed = 0,
  });

  CustomerState copyWith({
    CustomerModel? customer,
    List<CustomerModel>? customers,
    bool? loading,
    bool? showResult,
    int? pointsUsed,
  }) {
    return CustomerState(
      customer: customer ?? this.customer,
      customers: customers ?? this.customers,
      loading: loading ?? this.loading,
      showResult: showResult ?? this.showResult,
      pointsUsed: pointsUsed ?? this.pointsUsed,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerRepository repo;

  CustomerNotifier(this.repo) : super(const CustomerState());

  Future<void> searchCustomer(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = state.copyWith(
        customers: const [],
        showResult: false,
        loading: false,
      );
      return;
    }

    state = state.copyWith(loading: true);

    try {
      final result = await repo.searchCustomer(keyword);

      state = state.copyWith(
        customers: result,
        loading: false,
        showResult: true,
      );
    } catch (_) {
      state = state.copyWith(
        customers: const [],
        loading: false,
        showResult: false,
      );
    }
  }

  void selectCustomer(CustomerModel customer) {
    state = state.copyWith(
      customer: customer,
      customers: const [],
      showResult: false,
      pointsUsed: 0,
    );
  }

  void clearCustomer() {
    state = const CustomerState();
  }

  void updateCustomer({
    int? id,
    String? name,
    String? phone,
    String? address,
    int? currentPoint,
  }) {
    state = state.copyWith(
      customer: state.customer.copyWith(
        id: id,
        name: name,
        phone: phone,
        address: address,
        currentPoint: currentPoint,
      ),
    );
  }

  void updatePointsUsed(int value) {
    if (value < 0) value = 0;

    if (value > state.customer.currentPoint) {
      value = state.customer.currentPoint;
    }

    state = state.copyWith(pointsUsed: value);
  }

  void hideCustomerResult() {
    state = state.copyWith(customers: const [], showResult: false);
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepository(),
);

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) {
    return CustomerNotifier(ref.read(customerRepositoryProvider));
  },
);
