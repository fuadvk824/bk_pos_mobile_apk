import 'package:bk_pos/features/transaction/presentation/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/transaction_provider.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(onPressed: notifier.load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: CustomScrollView(
          slivers: [
            
            SliverToBoxAdapter(
              child: SizedBox(
                height: 55,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: TransactionFilter.values.map((filter) {
                    final selected = state.selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          notifier.setFilter(filter);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(filter),
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
 
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final trx = state.transactions[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(transactionId: trx.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// HEADER
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    trx.invoiceNumber,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(trx.paymentStatus),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    trx.paymentStatus.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              trx.customerName ?? 'Customer Umum',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              trx.storeName ?? '-',
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(Icons.local_shipping, size: 16),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    trx.deliveryType ?? '-',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),

                            if (trx.driverName != null &&
                                trx.driverName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Driver: ${trx.driverName}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),

                            const Divider(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total"),
                                Text(
                                  "Rp ${trx.total.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Paid"),
                                Text("Rp ${trx.paidAmount.toStringAsFixed(0)}"),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Remaining"),
                                Text(
                                  "Rp ${trx.remainingAmount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                trx.createdAt ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: state.transactions.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
