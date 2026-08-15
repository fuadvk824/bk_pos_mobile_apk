import 'package:bk_pos/model/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);

enum TransactionFilter { all, paid, partial, unpaid }

const _unset = Object();

class TransactionState {
  final bool isLoading;
  final List<TransactionModel> transactions;
  final List<TransactionModel> allTransactions;
  final TransactionFilter selectedFilter;
  final int? selectedMonth;
  final int? selectedYear;
  final String? error;

  TransactionState({
    this.isLoading = false,
    this.transactions = const [],
    this.allTransactions = const [],
    this.selectedFilter = TransactionFilter.all,
    this.selectedMonth,
    this.selectedYear,
    this.error,
  });

  TransactionState copyWith({
    bool? isLoading,
    List<TransactionModel>? transactions,
    List<TransactionModel>? allTransactions,
    TransactionFilter? selectedFilter,
    Object? selectedMonth = _unset,
    Object? selectedYear = _unset,
    Object? error = _unset,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedMonth: selectedMonth == _unset
          ? this.selectedMonth
          : selectedMonth as int?,
      selectedYear: selectedYear == _unset
          ? this.selectedYear
          : selectedYear as int?,
      error: error == _unset ? this.error : error as String?,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository repo;

  TransactionNotifier(this.repo) : super(TransactionState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final transactions = await repo.getTransactions(
        month: state.selectedMonth,
        year: state.selectedYear,
      );

      state = state.copyWith(isLoading: false, allTransactions: transactions);

      _applyFilter();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _applyFilter() {
    List<TransactionModel> filtered = [];

    switch (state.selectedFilter) {
      case TransactionFilter.all:
        filtered = [...state.allTransactions];
        break;

      case TransactionFilter.paid:
        filtered = state.allTransactions
            .where((e) => e.paymentStatus.toLowerCase() == 'paid')
            .toList();
        break;

      case TransactionFilter.unpaid:
        filtered = state.allTransactions
            .where((e) => e.paidAmount == 0)
            .toList();
        break;

      case TransactionFilter.partial:
        filtered = state.allTransactions
            .where((e) => e.paidAmount > 0 && e.remainingAmount > 0)
            .toList();
        break;
    }

    state = state.copyWith(transactions: filtered);
  }

  void setFilter(TransactionFilter filter) {
    state = state.copyWith(selectedFilter: filter);

    _applyFilter();
  }

  Future<void> setPeriod({int? month, int? year}) async {
    if (month == state.selectedMonth && year == state.selectedYear) {
      return;
    }

    state = state.copyWith(selectedMonth: month, selectedYear: year);

    await load();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
      (ref) => TransactionNotifier(ref.read(transactionRepositoryProvider)),
    );
