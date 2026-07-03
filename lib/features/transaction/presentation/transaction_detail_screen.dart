import 'package:bk_pos/features/transaction/presentation/payment_bottom_sheet.dart';
import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/transaction_repository.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final repository = TransactionRepository();

  TransactionDetailModel? transaction;
  bool isLoading = true;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await repository.getTransactionDetail(widget.transactionId);

      setState(() {
        transaction = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> openPaymentSheet() async {
    if (transaction == null) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return PaymentBottomSheet(transaction: transaction!);
      },
    );

    if (result == true) {
      await load();
    }
  }

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

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (transaction == null) {
      return const Scaffold(
        body: Center(child: Text('Gagal memuat transaksi')),
      );
    }

    final trx = transaction!;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trx.invoiceNumber,
                          style: const TextStyle(
                            fontSize: 18,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  buildInfoRow("Tanggal", trx.createdAt ?? "-"),
                  buildInfoRow("Delivery", trx.deliveryType ?? "-"),
                  buildInfoRow("Driver", trx.driverName ?? "-"),
                  buildInfoRow("Catatan", trx.notes ?? "-"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// CUSTOMER
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  buildInfoRow("Nama", trx.customerName ?? "-"),
                  buildInfoRow("Telepon", trx.customerPhone ?? "-"),
                  buildInfoRow("Alamat", trx.customerAddress ?? "-"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// STORE
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Store",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  buildInfoRow("Store", trx.storeName ?? "-"),
                  buildInfoRow("Alamat", trx.storeAddress ?? "-"),
                  buildInfoRow("Kasir", trx.cashierName ?? "-"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// ITEMS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Item Transaksi",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ...trx.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 6),

                          Text("Qty : ${item.quantity}"),
                          Text("Harga : ${currency.format(item.price)}"),
                          Text("Diskon : ${currency.format(item.discount)}"),
                          Text("Subtotal : ${currency.format(item.subtotal)}"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// PAYMENTS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Riwayat Pembayaran",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ...trx.payments.map(
                    (payment) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.payments),
                      title: Text(currency.format(payment.amount)),
                      subtitle: Text(payment.paymentMethod),
                      trailing: Text(payment.cashierName ?? "-"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// TOTAL
          Card(
            color: Colors.blueGrey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildInfoRow("Subtotal", currency.format(trx.subtotal)),
                  buildInfoRow("Ongkir", currency.format(trx.shippingCost)),
                  const Divider(),
                  buildInfoRow("TOTAL", currency.format(trx.total)),
                ],
              ),
            ),
          ),
          if (trx.paymentStatus != "paid")
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payments),
                label: const Text("Tambah Pembayaran"),
                onPressed: openPaymentSheet,
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}