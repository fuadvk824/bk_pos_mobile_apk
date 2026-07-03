import 'package:bk_pos/model/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);

enum TransactionFilter { all, paid, partial, unpaid }

class TransactionState {
  final bool isLoading;

  final List<TransactionModel> transactions;
  final List<TransactionModel> allTransactions;

  final TransactionFilter selectedFilter;

  TransactionState({
    this.isLoading = false,
    this.transactions = const [],
    this.allTransactions = const [],
    this.selectedFilter = TransactionFilter.all,
  });

  TransactionState copyWith({
    bool? isLoading,
    List<TransactionModel>? transactions,
    List<TransactionModel>? allTransactions,
    TransactionFilter? selectedFilter,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository repo;

  TransactionNotifier(this.repo) : super(TransactionState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final transactions = await repo.getTransactions();

    state = state.copyWith(
      isLoading: false,
      transactions: transactions,
      allTransactions: transactions,
    );
  }

  void setFilter(TransactionFilter filter) {
    List<TransactionModel> filtered = [];

    switch (filter) {
      case TransactionFilter.all:
        filtered = List.from(state.allTransactions);
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

    state = state.copyWith(selectedFilter: filter, transactions: filtered);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
      (ref) => TransactionNotifier(ref.read(transactionRepositoryProvider)),
    );
