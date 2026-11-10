import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/transaction_provider.dart';

class TransactionFilterSection extends ConsumerWidget {
  const TransactionFilterSection({super.key});

  String getPaymentLabel(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return 'All';
      case TransactionFilter.paid:
        return 'Paid';
      case TransactionFilter.partial:
        return 'Partial';
      case TransactionFilter.unpaid:
        return 'Unpaid';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final notifier = ref.read(transactionProvider.notifier);

    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Transactions',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                IconButton(
                  tooltip: 'Refresh',
                  onPressed: state.isLoading ? null : notifier.load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            if (state.isLoading) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],

            const SizedBox(height: 10),

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const _TransactionFilterButton(),

                  const SizedBox(width: 8),

                  ...TransactionFilter.values
                      .where((filter) => filter != TransactionFilter.all)
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: state.selectedFilter == filter,
                            label: Text(getPaymentLabel(filter)),
                            onSelected: (_) {
                              notifier.setFilter(filter);
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.transparent,
                            checkmarkColor: AppColors.dark,
                            labelStyle: TextStyle(
                              color: state.selectedFilter == filter
                                  ? AppColors.dark
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: state.selectedFilter == filter
                                  ? Colors.transparent
                                  : AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionFilterButton extends ConsumerWidget {
  const _TransactionFilterButton();

  String getTimeLabel(TransactionState state) {
    switch (state.selectedTimeFilter) {
      case TransactionTimeFilter.all:
        return 'Semua Waktu';

      case TransactionTimeFilter.today:
        return 'Hari Ini';

      case TransactionTimeFilter.yesterday:
        return 'Kemarin';

      case TransactionTimeFilter.last7Days:
        return '7 Hari Terakhir';

      case TransactionTimeFilter.last30Days:
        return '30 Hari Terakhir';

      case TransactionTimeFilter.thisMonth:
        return 'Bulan Ini';

      case TransactionTimeFilter.lastMonth:
        return 'Bulan Lalu';

      case TransactionTimeFilter.thisYear:
        return 'Tahun Ini';

      case TransactionTimeFilter.custom:
        if (state.customStartDate != null && state.customEndDate != null) {
          return '${_formatDate(state.customStartDate!)} - '
              '${_formatDate(state.customEndDate!)}';
        }

        return 'Custom';
    }
  }

  String getTypeLabel(TransactionTypeFilter type) {
    switch (type) {
      case TransactionTypeFilter.all:
        return 'All';

      case TransactionTypeFilter.normal:
        return 'Normal';

      case TransactionTypeFilter.backorder:
        return 'Backorder';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isDefaultFilter(TransactionState state) {
    return state.selectedTimeFilter == TransactionTimeFilter.all &&
        state.selectedType == TransactionTypeFilter.all;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final isFiltered = !_isDefaultFilter(state);

    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () {
          _showFilterDialog(context);
        },
        icon: Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter'),

            if (isFiltered) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _TransactionFilterDialog(),
    );
  }
}

class _TransactionFilterDialog extends ConsumerStatefulWidget {
  const _TransactionFilterDialog();

  @override
  ConsumerState<_TransactionFilterDialog> createState() =>
      _TransactionFilterDialogState();
}

class _TransactionFilterDialogState
    extends ConsumerState<_TransactionFilterDialog> {
  late TransactionTimeFilter selectedTime;
  late TransactionTypeFilter selectedType;

  DateTime? customStartDate;
  DateTime? customEndDate;

  @override
  void initState() {
    super.initState();

    final state = ref.read(transactionProvider);

    selectedTime = state.selectedTimeFilter;
    selectedType = state.selectedType;

    customStartDate = state.customStartDate;
    customEndDate = state.customEndDate;
  }

  String getTimeLabel(TransactionTimeFilter filter) {
    switch (filter) {
      case TransactionTimeFilter.all:
        return 'Semua Waktu';

      case TransactionTimeFilter.today:
        return 'Hari Ini';

      case TransactionTimeFilter.yesterday:
        return 'Kemarin';

      case TransactionTimeFilter.last7Days:
        return '7 Hari Terakhir';

      case TransactionTimeFilter.last30Days:
        return '30 Hari Terakhir';

      case TransactionTimeFilter.thisMonth:
        return 'Bulan Ini';

      case TransactionTimeFilter.lastMonth:
        return 'Bulan Lalu';

      case TransactionTimeFilter.thisYear:
        return 'Tahun Ini';

      case TransactionTimeFilter.custom:
        return 'Custom';
    }
  }

  String getTypeLabel(TransactionTypeFilter type) {
    switch (type) {
      case TransactionTypeFilter.all:
        return 'All';

      case TransactionTypeFilter.normal:
        return 'Normal';

      case TransactionTypeFilter.backorder:
        return 'Backorder';
    }
  }

  Future<void> _selectCustomDate() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            ),
    );

    if (result == null) return;

    setState(() {
      selectedTime = TransactionTimeFilter.custom;
      customStartDate = result.start;
      customEndDate = result.end;
    });
  }

  void _resetFilter() {
    setState(() {
      selectedTime = TransactionTimeFilter.all;
      selectedType = TransactionTypeFilter.all;
      customStartDate = null;
      customEndDate = null;
    });
  }

  Future<void> _applyFilter() async {
    await ref
        .read(transactionProvider.notifier)
        .setTimeFilter(
          selectedTime,
          customStartDate: customStartDate,
          customEndDate: customEndDate,
        );

    ref.read(transactionProvider.notifier).setTransactionType(selectedType);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _timeOption(TransactionTimeFilter filter) {
    final selected = selectedTime == filter;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        if (filter == TransactionTimeFilter.custom) {
          await _selectCustomDate();
          return;
        }

        setState(() {
          selectedTime = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? AppColors.primary : Colors.grey.shade500,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                getTimeLabel(filter),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeOption(TransactionTypeFilter type) {
    final selected = selectedType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            getTypeLabel(type),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.dark : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      backgroundColor: AppColors.light,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pilih waktu dan tipe transaksi',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tipe Transaksi",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: TransactionTypeFilter.values.map((type) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: type != TransactionTypeFilter.backorder ? 8 : 0,
                      ),
                      child: _typeOption(type),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Waktu Transaksi",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: TransactionTimeFilter.values
                        .map(_timeOption)
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilter,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.dark,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
