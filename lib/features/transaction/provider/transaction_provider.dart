import 'package:bk_pos/model/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);

enum TransactionFilter { all, paid, partial, unpaid }

enum TransactionTypeFilter { all, normal, backorder }

enum TransactionTimeFilter {
  all,
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

const _unset = Object();

class TransactionState {
  final bool isLoading;

  final List<TransactionModel> transactions;
  final List<TransactionModel> allTransactions;

  final TransactionFilter selectedFilter;
  final TransactionTypeFilter selectedType;

  final TransactionTimeFilter selectedTimeFilter;

  final DateTime? customStartDate;
  final DateTime? customEndDate;

  final String? error;

  TransactionState({
    this.isLoading = false,
    this.transactions = const [],
    this.allTransactions = const [],
    this.selectedFilter = TransactionFilter.all,
    this.selectedType = TransactionTypeFilter.all,
    this.selectedTimeFilter = TransactionTimeFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.error,
  });

  TransactionState copyWith({
    bool? isLoading,
    List<TransactionModel>? transactions,
    List<TransactionModel>? allTransactions,

    TransactionFilter? selectedFilter,
    TransactionTypeFilter? selectedType,
    TransactionTimeFilter? selectedTimeFilter,

    Object? customStartDate = _unset,
    Object? customEndDate = _unset,

    Object? error = _unset,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedType: selectedType ?? this.selectedType,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,

      customStartDate: customStartDate == _unset
          ? this.customStartDate
          : customStartDate as DateTime?,

      customEndDate: customEndDate == _unset
          ? this.customEndDate
          : customEndDate as DateTime?,

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
        startDate: _getStartDate(),
        endDate: _getEndDate(),
      );

      state = state.copyWith(isLoading: false, allTransactions: transactions);

      _applyFilter();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  DateTime? _getStartDate() {
    final now = DateTime.now();

    switch (state.selectedTimeFilter) {
      case TransactionTimeFilter.all:
        return null;

      case TransactionTimeFilter.today:
        return DateTime(now.year, now.month, now.day);

      case TransactionTimeFilter.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));

        return DateTime(yesterday.year, yesterday.month, yesterday.day);

      case TransactionTimeFilter.last7Days:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));

        return start;

      case TransactionTimeFilter.last30Days:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 29));

        return start;

      case TransactionTimeFilter.thisMonth:
        return DateTime(now.year, now.month, 1);

      case TransactionTimeFilter.lastMonth:
        return DateTime(now.year, now.month - 1, 1);

      case TransactionTimeFilter.thisYear:
        return DateTime(now.year, 1, 1);

      case TransactionTimeFilter.custom:
        return state.customStartDate;
    }
  }

  DateTime? _getEndDate() {
    final now = DateTime.now();

    switch (state.selectedTimeFilter) {
      case TransactionTimeFilter.all:
        return null;

      case TransactionTimeFilter.today:
        return DateTime(now.year, now.month, now.day);

      case TransactionTimeFilter.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));

        return DateTime(yesterday.year, yesterday.month, yesterday.day);

      case TransactionTimeFilter.last7Days:
        return DateTime(now.year, now.month, now.day);

      case TransactionTimeFilter.last30Days:
        return DateTime(now.year, now.month, now.day);

      case TransactionTimeFilter.thisMonth:
        return DateTime(now.year, now.month + 1, 0);

      case TransactionTimeFilter.lastMonth:
        return DateTime(now.year, now.month, 0);

      case TransactionTimeFilter.thisYear:
        return DateTime(now.year, 12, 31);

      case TransactionTimeFilter.custom:
        return state.customEndDate;
    }
  }

  Future<void> setTimeFilter(
    TransactionTimeFilter filter, {
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    state = state.copyWith(
      selectedTimeFilter: filter,

      customStartDate: filter == TransactionTimeFilter.custom
          ? customStartDate
          : null,

      customEndDate: filter == TransactionTimeFilter.custom
          ? customEndDate
          : null,
    );

    await load();
  }

  void _applyFilter() {
    var filtered = [...state.allTransactions];

    switch (state.selectedType) {
      case TransactionTypeFilter.all:
        break;

      case TransactionTypeFilter.normal:
        filtered = filtered
            .where((e) => e.transactionType.toLowerCase() == 'normal')
            .toList();
        break;

      case TransactionTypeFilter.backorder:
        filtered = filtered
            .where((e) => e.transactionType.toLowerCase() == 'backorder')
            .toList();
        break;
    }

    switch (state.selectedFilter) {
      case TransactionFilter.all:
        break;

      case TransactionFilter.paid:
        filtered = filtered
            .where((e) => e.paymentStatus.toLowerCase() == 'paid')
            .toList();
        break;

      case TransactionFilter.unpaid:
        filtered = filtered.where((e) => e.paidAmount == 0).toList();
        break;

      case TransactionFilter.partial:
        filtered = filtered
            .where((e) => e.paidAmount > 0 && e.remainingAmount > 0)
            .toList();
        break;
    }

    state = state.copyWith(transactions: filtered);
  }

  void setTransactionType(TransactionTypeFilter type) {
    state = state.copyWith(selectedType: type);

    _applyFilter();
  }

  void setFilter(TransactionFilter filter) {
    state = state.copyWith(selectedFilter: filter);

    _applyFilter();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
      (ref) => TransactionNotifier(ref.read(transactionRepositoryProvider)),
    );

 