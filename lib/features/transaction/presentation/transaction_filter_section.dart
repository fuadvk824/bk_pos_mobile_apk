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
      color: AppColors.background,
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

// ==========================================================================
// FILTER DIALOG
// ==========================================================================

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

  // ========================================================================
  // LABEL
  // ========================================================================

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

  // ========================================================================
  // CUSTOM DATE
  // ========================================================================

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

  // ========================================================================
  // RESET
  // ========================================================================

  void _resetFilter() {
    setState(() {
      selectedTime = TransactionTimeFilter.all;
      selectedType = TransactionTypeFilter.all;
      customStartDate = null;
      customEndDate = null;
    });
  }

  // ========================================================================
  // APPLY
  // ========================================================================

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

  // ========================================================================
  // SECTION TITLE
  // ========================================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ========================================================================
  // TIME OPTION
  // ========================================================================

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

  // ========================================================================
  // TYPE OPTION
  // ========================================================================

  Widget _typeOption(TransactionTypeFilter type) {
    final selected = selectedType == type;

    return Expanded(
      child: InkWell(
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
      ),
    );
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================================
              // HEADER
              // ============================================================
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

              // ============================================================
              // TYPE
              // ============================================================
              Align(
                alignment: Alignment.centerLeft,
                child: _sectionTitle(
                  icon: Icons.category_rounded,
                  title: 'Tipe Transaksi',
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: TransactionTypeFilter.values
                    .map(
                      (type) => Padding(
                        padding: EdgeInsets.only(
                          right: type != TransactionTypeFilter.backorder
                              ? 8
                              : 0,
                        ),
                        child: _typeOption(type),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              // ============================================================
              // TIME
              // ============================================================
              Align(
                alignment: Alignment.centerLeft,
                child: _sectionTitle(
                  icon: Icons.calendar_month_rounded,
                  title: 'Waktu Transaksi',
                ),
              ),

              const SizedBox(height: 10),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: TransactionTimeFilter.values
                        .map(_timeOption)
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ============================================================
              // ACTIONS
              // ============================================================
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
/////////////////////////////////////////////////////////////////////////////

// import 'package:bk_pos/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../provider/transaction_provider.dart';

// class TransactionFilterSection extends ConsumerWidget {
//   const TransactionFilterSection({super.key});

//   String getFilterLabel(TransactionFilter filter) {
//     switch (filter) {
//       case TransactionFilter.all:
//         return "All";
//       case TransactionFilter.paid:
//         return "Paid";
//       case TransactionFilter.partial:
//         return "Partial";
//       case TransactionFilter.unpaid:
//         return "Unpaid";
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(transactionProvider);
//     final notifier = ref.read(transactionProvider.notifier);

//     return Material(
//       elevation: 2,
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Expanded(
//                   child: Text(
//                     "Transactions",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                 ),

//                 IconButton(
//                   onPressed: state.isLoading ? null : notifier.load,
//                   icon: const Icon(Icons.refresh),
//                 ),
//               ],
//             ),

//             if (state.isLoading) ...[
//               const SizedBox(height: 8),
//               const LinearProgressIndicator(),
//             ],

//             const SizedBox(height: 10),

//             SizedBox(
//               height: 40,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   // TYPE
//                   const _TransactionTypeDropdown(),

//                   const SizedBox(width: 8),

//                   // PAYMENT STATUS
//                   ...TransactionFilter.values
//                       .where((filter) => filter != TransactionFilter.all)
//                       .map(
//                         (filter) => Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child: ChoiceChip(
//                             selected: state.selectedFilter == filter,
//                             label: Text(getFilterLabel(filter)),
//                             onSelected: (_) {
//                               notifier.setFilter(filter);
//                             },
//                             selectedColor: AppColors.primary,
//                             backgroundColor: Colors.transparent,
//                             checkmarkColor: AppColors.dark,
//                             labelStyle: TextStyle(
//                               color: state.selectedFilter == filter
//                                   ? AppColors.dark
//                                   : AppColors.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             side: BorderSide(
//                               color: state.selectedFilter == filter
//                                   ? Colors.transparent
//                                   : AppColors.primary,
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),

//                   const SizedBox(width: 4),

//                   // TIME
//                   _TimeFilterButton(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TimeFilterButton extends ConsumerWidget {
//   const _TimeFilterButton();

//   String getLabel(TransactionState state) {
//     switch (state.selectedTimeFilter) {
//       case TransactionTimeFilter.all:
//         return "Semua Waktu";

//       case TransactionTimeFilter.today:
//         return "Hari Ini";

//       case TransactionTimeFilter.yesterday:
//         return "Kemarin";

//       case TransactionTimeFilter.last7Days:
//         return "7 Hari Terakhir";

//       case TransactionTimeFilter.last30Days:
//         return "30 Hari Terakhir";

//       case TransactionTimeFilter.thisMonth:
//         return "Bulan Ini";

//       case TransactionTimeFilter.lastMonth:
//         return "Bulan Lalu";

//       case TransactionTimeFilter.thisYear:
//         return "Tahun Ini";

//       case TransactionTimeFilter.custom:
//         if (state.customStartDate != null && state.customEndDate != null) {
//           return "${_formatDate(state.customStartDate!)} - "
//               "${_formatDate(state.customEndDate!)}";
//         }

//         return "Custom";
//     }
//   }

//   static String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}/"
//         "${date.month.toString().padLeft(2, '0')}/"
//         "${date.year}";
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(transactionProvider);

//     return SizedBox(
//       height: 40,
//       child: OutlinedButton.icon(
//         onPressed: () {
//           _showFilterDialog(context, ref);
//         },
//         icon: const Icon(Icons.calendar_month_outlined, size: 18),
//         label: Text(getLabel(state)),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           side: const BorderSide(color: AppColors.primary, width: 1.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//         ),
//       ),
//     );
//   }

//   void _showFilterDialog(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const _TimeFilterDialog();
//       },
//     );
//   }
// }

// class _TimeFilterDialog extends ConsumerStatefulWidget {
//   const _TimeFilterDialog();

//   @override
//   ConsumerState<_TimeFilterDialog> createState() => _TimeFilterDialogState();
// }

// class _TimeFilterDialogState extends ConsumerState<_TimeFilterDialog> {
//   late TransactionTimeFilter selected;

//   DateTime? customStartDate;
//   DateTime? customEndDate;

//   @override
//   void initState() {
//     super.initState();

//     final state = ref.read(transactionProvider);

//     selected = state.selectedTimeFilter;
//     customStartDate = state.customStartDate;
//     customEndDate = state.customEndDate;
//   }

//   String getLabel(TransactionTimeFilter filter) {
//     switch (filter) {
//       case TransactionTimeFilter.all:
//         return "Semua Waktu";

//       case TransactionTimeFilter.today:
//         return "Hari Ini";

//       case TransactionTimeFilter.yesterday:
//         return "Kemarin";

//       case TransactionTimeFilter.last7Days:
//         return "7 Hari Terakhir";

//       case TransactionTimeFilter.last30Days:
//         return "30 Hari Terakhir";

//       case TransactionTimeFilter.thisMonth:
//         return "Bulan Ini";

//       case TransactionTimeFilter.lastMonth:
//         return "Bulan Lalu";

//       case TransactionTimeFilter.thisYear:
//         return "Tahun Ini";

//       case TransactionTimeFilter.custom:
//         return "Custom";
//     }
//   }

//   Future<void> _selectCustomDate() async {
//     final now = DateTime.now();

//     final result = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: now,
//       initialDateRange: customStartDate != null && customEndDate != null
//           ? DateTimeRange(start: customStartDate!, end: customEndDate!)
//           : DateTimeRange(
//               start: now.subtract(const Duration(days: 6)),
//               end: now,
//             ),
//     );

//     if (result == null) return;

//     setState(() {
//       selected = TransactionTimeFilter.custom;
//       customStartDate = result.start;
//       customEndDate = result.end;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text(
//         "Filter Waktu",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),

//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: TransactionTimeFilter.values.map((filter) {
//             return RadioListTile<TransactionTimeFilter>(
//               value: filter,
//               groupValue: selected,
//               contentPadding: EdgeInsets.zero,
//               title: Text(getLabel(filter)),
//               activeColor: AppColors.primary,
//               onChanged: (value) async {
//                 if (value == null) return;

//                 if (value == TransactionTimeFilter.custom) {
//                   await _selectCustomDate();
//                 } else {
//                   setState(() {
//                     selected = value;
//                   });
//                 }
//               },
//             );
//           }).toList(),
//         ),
//       ),

//       actions: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () async {
//               await ref
//                   .read(transactionProvider.notifier)
//                   .setTimeFilter(
//                     selected,
//                     customStartDate: customStartDate,
//                     customEndDate: customEndDate,
//                   );

//               if (context.mounted) {
//                 Navigator.pop(context);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.dark,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text("Terapkan"),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TransactionTypeDropdown extends ConsumerWidget {
//   const _TransactionTypeDropdown();

//   String getLabel(TransactionTypeFilter type) {
//     switch (type) {
//       case TransactionTypeFilter.all:
//         return 'All';

//       case TransactionTypeFilter.normal:
//         return 'Normal';

//       case TransactionTypeFilter.backorder:
//         return 'Backorder';
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(transactionProvider);
//     final notifier = ref.read(transactionProvider.notifier);

//     return Container(
//       height: 40,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.primary, width: 1.5),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<TransactionTypeFilter>(
//           value: state.selectedType,
//           borderRadius: BorderRadius.circular(16),
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           icon: const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: AppColors.primary,
//           ),
//           items: TransactionTypeFilter.values.map((type) {
//             return DropdownMenuItem<TransactionTypeFilter>(
//               value: type,
//               child: Text(
//                 getLabel(type),
//                 style: const TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             if (value != null) {
//               notifier.setTransactionType(value);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////////////////////////////////////////////////

// import 'package:bk_pos/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../provider/transaction_provider.dart';

// class TransactionFilterSection extends ConsumerWidget {
//   const TransactionFilterSection({super.key});

//   static const List<String> months = [
//     "Jan",
//     "Feb",
//     "Mar",
//     "Apr",
//     "Mei",
//     "Jun",
//     "Jul",
//     "Agu",
//     "Sep",
//     "Okt",
//     "Nov",
//     "Des",
//   ];

//   String getFilterLabel(TransactionFilter filter) {
//     switch (filter) {
//       case TransactionFilter.all:
//         return "All";
//       case TransactionFilter.paid:
//         return "Paid";
//       case TransactionFilter.partial:
//         return "Partial";
//       case TransactionFilter.unpaid:
//         return "Unpaid";
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(transactionProvider);
//     final notifier = ref.read(transactionProvider.notifier);

//     final currentYear = DateTime.now().year;

//     return Material(
//       elevation: 2,
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Expanded(
//                   child: Text(
//                     "Transactions",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: state.isLoading ? null : notifier.load,
//                   icon: const Icon(Icons.refresh),
//                 ),
//               ],
//             ),

//             if (state.isLoading) ...[
//               const SizedBox(height: 8),
//               const LinearProgressIndicator(),
//             ],

//             const SizedBox(height: 10),

//             SizedBox(
//               height: 40,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   ...TransactionFilter.values.map((filter) {
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ChoiceChip(
//                         selected: state.selectedFilter == filter,
//                         label: Text(getFilterLabel(filter)),
//                         onSelected: (_) => notifier.setFilter(filter),

//                         selectedColor: AppColors.primary,
//                         backgroundColor: Colors.transparent,
//                         checkmarkColor: AppColors.dark,

//                         labelStyle: TextStyle(
//                           color: state.selectedFilter == filter
//                               ? AppColors.dark
//                               : AppColors.primary,
//                           fontWeight: FontWeight.w600,
//                         ),

//                         side: BorderSide(
//                           color: state.selectedFilter == filter
//                               ? Colors.transparent
//                               : AppColors.primary,
//                           width: 1.5,
//                         ),
//                       ),
//                     );
//                   }),

//                   const SizedBox(width: 4),

//                   _PeriodFilterButton(
//                     state: state,
//                     notifier: notifier,
//                     currentYear: currentYear,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PeriodFilterButton extends StatefulWidget {
//   const _PeriodFilterButton({
//     required this.state,
//     required this.notifier,
//     required this.currentYear,
//   });

//   final TransactionState state;
//   final TransactionNotifier notifier;
//   final int currentYear;

//   @override
//   State<_PeriodFilterButton> createState() => _PeriodFilterButtonState();
// }

// class _PeriodFilterButtonState extends State<_PeriodFilterButton> {
//   late int? tempMonth;
//   late int? tempYear;

//   @override
//   void initState() {
//     super.initState();
//     tempMonth = widget.state.selectedMonth;
//     tempYear = widget.state.selectedYear;
//   }

//   @override
//   void didUpdateWidget(covariant _PeriodFilterButton oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     tempMonth = widget.state.selectedMonth;
//     tempYear = widget.state.selectedYear;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final monthText = widget.state.selectedMonth == null
//         ? "Semua"
//         : TransactionFilterSection.months[widget.state.selectedMonth! - 1];

//     final yearText = widget.state.selectedYear?.toString() ?? "Semua";

//     return PopupMenuButton(
//       padding: EdgeInsets.zero,
//       color: Theme.of(context).cardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       offset: const Offset(0, 55),
//       constraints: const BoxConstraints(minWidth: 340, maxWidth: 340),
//       itemBuilder: (_) => [
//         PopupMenuItem(
//           enabled: false,
//           padding: EdgeInsets.zero,
//           child: StatefulBuilder(
//             builder: (context, popupSetState) {
//               Widget monthChip(String label, int? value) {
//                 final selected = tempMonth == value;

//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: ChoiceChip(
//                     selected: selected,
//                     label: Text(label),
//                     selectedColor: AppColors.primary,
//                     backgroundColor: Colors.transparent,
//                     checkmarkColor: AppColors.dark,
//                     labelStyle: TextStyle(
//                       color: selected ? AppColors.dark : AppColors.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     side: BorderSide(
//                       color: selected ? Colors.transparent : AppColors.primary,
//                     ),
//                     onSelected: (_) {
//                       popupSetState(() {
//                         tempMonth = value;
//                       });
//                     },
//                   ),
//                 );
//               }

//               Widget yearChip(String label, int? value) {
//                 final selected = tempYear == value;

//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: ChoiceChip(
//                     selected: selected,
//                     label: Text(label),
//                     selectedColor: AppColors.primary,
//                     backgroundColor: Colors.transparent,
//                     checkmarkColor: AppColors.dark,
//                     labelStyle: TextStyle(
//                       color: selected ? AppColors.dark : AppColors.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     side: BorderSide(
//                       color: selected ? Colors.transparent : AppColors.primary,
//                     ),
//                     onSelected: (_) {
//                       popupSetState(() {
//                         tempYear = value;
//                       });
//                     },
//                   ),
//                 );
//               }

//               return SizedBox(
//                 width: 340,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Bulan",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             monthChip("Semua", null),

//                             ...List.generate(
//                               12,
//                               (index) => monthChip(
//                                 TransactionFilterSection.months[index],
//                                 index + 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       const Text(
//                         "Tahun",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             yearChip("Semua", null),

//                             ...List.generate(5, (index) {
//                               final year = widget.currentYear - index;

//                               return yearChip(year.toString(), year);
//                             }),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.check),
//                           label: const Text("Terapkan"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: AppColors.dark,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onPressed: () {
//                             widget.notifier.setPeriod(
//                               month: tempMonth,
//                               year: tempYear,
//                             );

//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//       child: SizedBox(
//         height: 40,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: AppColors.primary, width: 1.5),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.calendar_month_outlined,
//                 color: AppColors.primary,
//                 size: 18,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 "$monthText • $yearText",
//                 style: const TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(width: 2),
//               const Icon(
//                 Icons.keyboard_arrow_down_rounded,
//                 color: AppColors.primary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
