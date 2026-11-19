
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_pos/features/customer/data/customer_repository.dart';
import 'package:bk_pos/model/customer_model.dart';

final customerRepositoryProvider =
    Provider((ref) => CustomerRepository());

class CustomerState {
  final List<CustomerModel> customers;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final bool hasMore;
  final String search;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.search = '',
  });

  CustomerState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    bool? hasMore,
    String? search,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerRepository repository;

  int _requestId = 0;

  CustomerNotifier(this.repository)
      : super(const CustomerState()) {
    loadCustomers();
  }

  Future<void> loadCustomers({
    String? search,
  }) async {
    final keyword = search ?? state.search;
    final requestId = ++_requestId;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      customers: [],
      currentPage: 0,
      hasMore: true,
      search: keyword,
    );

    try {
      final result = await repository.getCustomers(
        search: keyword,
        page: 1,
      );

      if (requestId != _requestId) return;

      state = state.copyWith(
        customers: result.customers,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
        isLoading: false,
      );
    } catch (e) {
      if (requestId != _requestId) return;

      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final requestId = _requestId;
    final nextPage = state.currentPage + 1;
    final keyword = state.search;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await repository.getCustomers(
        search: keyword,
        page: nextPage,
      );

      if (requestId != _requestId) return;

      state = state.copyWith(
        customers: [
          ...state.customers,
          ...result.customers,
        ],
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
        isLoadingMore: false,
      );
    } catch (e) {
      if (requestId != _requestId) return;

      state = state.copyWith(
        isLoadingMore: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadCustomers(search: state.search);
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
 