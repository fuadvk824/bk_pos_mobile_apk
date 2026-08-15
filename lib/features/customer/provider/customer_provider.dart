import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_pos/features/customer/data/customer_repository.dart';
import 'package:bk_pos/model/customer_model.dart';

final customerRepositoryProvider =
    Provider((ref) => CustomerRepository());

class CustomerState {
  final List<CustomerModel> customers;
  final bool isLoading;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
  });

  CustomerState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerRepository repository;

  CustomerNotifier(this.repository)
      : super(const CustomerState()) {
    loadCustomers();
  }

  Future<void> loadCustomers({
    String search = '',
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final customers =
          await repository.getCustomers(search: search);

      state = state.copyWith(
        customers: customers,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadCustomers();
  }

  Future<void> search(String keyword) async {
    await loadCustomers(search: keyword);
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) => CustomerNotifier(
    ref.read(customerRepositoryProvider),
  ),
);