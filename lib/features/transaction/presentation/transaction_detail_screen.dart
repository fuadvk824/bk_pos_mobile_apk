import 'package:bk_pos/features/transaction/presentation/payment_bottom_sheet.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/customer_card.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/items_card.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/payment_button.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/payment_history_card.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/preview_sj_screen.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/thermal_receipt_screen.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/total_card.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/transaction_add_product.dart';
import 'package:bk_pos/features/transaction/presentation/widgets/transaction_header_card.dart';
import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

      if (mounted) {
        setState(() {
          transaction = data;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          title: 'Gagal Memuat Data',
          description: e.toString().replaceFirst('Exception: ', ''),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (transaction == null) {
      return const Scaffold(
        body: Center(child: Text("Gagal memuat transaksi")),
      );
    }

    final trx = transaction!;
    final paymentStatus = trx.paymentStatus.toLowerCase();

    final showAddProduct = paymentStatus == "unpaid";

    final canPrintReceipt =
        paymentStatus == "partial" || paymentStatus == "paid";
    final canSJ = paymentStatus == "paid";

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Detail Transaksi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
          children: [
            TransactionHeaderCard(trx: trx),
            const SizedBox(height: 10),

            CustomerCard(trx: trx),
            const SizedBox(height: 10),

            ItemsCard(trx: trx, currency: currency),
            const SizedBox(height: 10),

            PaymentHistoryCard(trx: trx, currency: currency),
            const SizedBox(height: 10),

            TotalCard(trx: trx, currency: currency),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAddProduct)
              PaymentButton(
                title: "Tambah Produk",
                icon: Icons.add_shopping_cart,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionAddProduct(
                        transactionId: trx.id,
                        existingItems: trx.items,
                      ),
                    ),
                  );

                  if (result == true) {
                    await load();
                  }
                },
              ),

            if (canPrintReceipt)
              Row(
                children: [
                  Expanded(
                    child: PaymentButton(
                      title: "Cetak Nota",
                      icon: LucideIcons.receiptText,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ThermalReceiptScreen(transaction: trx),
                          ),
                        );
                      },
                    ),
                  ),
                  if (canSJ) ...[
                    Expanded(
                      child: PaymentButton(
                        title: "Surat Jalan",
                        icon: LucideIcons.fileText,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreviewSjScreen(transaction: trx),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

            PaymentButton(
              title: "Tambah Pembayaran",
              icon: LucideIcons.banknote,
              onPressed: openPaymentSheet,
            ),
          ],
        ),
      ),
    );
  }
}
