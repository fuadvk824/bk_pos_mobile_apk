import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/transaction_provider.dart';

class TransactionFilterSection extends ConsumerWidget {
  const TransactionFilterSection({super.key});

  static const List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  String getFilterLabel(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return "All";
      case TransactionFilter.paid:
        return "Paid";
      case TransactionFilter.partial:
        return "Partial";
      case TransactionFilter.unpaid:
        return "Unpaid";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final notifier = ref.read(transactionProvider.notifier);

    final currentYear = DateTime.now().year;

    return Material(
      elevation: 2,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Transactions",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: state.isLoading ? null : notifier.load,
                  icon: const Icon(Icons.refresh),
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
                  ...TransactionFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: state.selectedFilter == filter,
                        label: Text(getFilterLabel(filter)),
                        onSelected: (_) => notifier.setFilter(filter),

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
                    );
                  }),

                  const SizedBox(width: 4),

                  _PeriodFilterButton(
                    state: state,
                    notifier: notifier,
                    currentYear: currentYear,
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

class _PeriodFilterButton extends StatefulWidget {
  const _PeriodFilterButton({
    required this.state,
    required this.notifier,
    required this.currentYear,
  });

  final TransactionState state;
  final TransactionNotifier notifier;
  final int currentYear;

  @override
  State<_PeriodFilterButton> createState() => _PeriodFilterButtonState();
}

class _PeriodFilterButtonState extends State<_PeriodFilterButton> {
  late int? tempMonth;
  late int? tempYear;

  @override
  void initState() {
    super.initState();
    tempMonth = widget.state.selectedMonth;
    tempYear = widget.state.selectedYear;
  }

  @override
  void didUpdateWidget(covariant _PeriodFilterButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    tempMonth = widget.state.selectedMonth;
    tempYear = widget.state.selectedYear;
  }

  @override
  Widget build(BuildContext context) {
    final monthText = widget.state.selectedMonth == null
        ? "Semua"
        : TransactionFilterSection.months[widget.state.selectedMonth! - 1];

    final yearText = widget.state.selectedYear?.toString() ?? "Semua";

    return PopupMenuButton(
      padding: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 55),
      constraints: const BoxConstraints(minWidth: 340, maxWidth: 340),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (context, popupSetState) {
              Widget monthChip(String label, int? value) {
                final selected = tempMonth == value;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(label),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    checkmarkColor: AppColors.dark,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.dark : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? Colors.transparent : AppColors.primary,
                    ),
                    onSelected: (_) {
                      popupSetState(() {
                        tempMonth = value;
                      });
                    },
                  ),
                );
              }

              Widget yearChip(String label, int? value) {
                final selected = tempYear == value;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(label),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    checkmarkColor: AppColors.dark,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.dark : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? Colors.transparent : AppColors.primary,
                    ),
                    onSelected: (_) {
                      popupSetState(() {
                        tempYear = value;
                      });
                    },
                  ),
                );
              }

              return SizedBox(
                width: 340,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bulan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            monthChip("Semua", null),

                            ...List.generate(
                              12,
                              (index) => monthChip(
                                TransactionFilterSection.months[index],
                                index + 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Tahun",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            yearChip("Semua", null),

                            ...List.generate(5, (index) {
                              final year = widget.currentYear - index;

                              return yearChip(year.toString(), year);
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Terapkan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.dark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            widget.notifier.setPeriod(
                              month: tempMonth,
                              year: tempYear,
                            );

                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
      child: SizedBox(
        height: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                "$monthText • $yearText",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

