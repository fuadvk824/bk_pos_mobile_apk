import 'package:flutter/material.dart';
import 'package:bk_pos/features/transaction/presentation/transaction_detail_screen.dart';
import 'package:bk_pos/model/transaction_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel trx;

  const TransactionCard({super.key, required this.trx});

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

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(trx.paymentStatus);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transactionId: trx.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.scrollText,
                      color: AppColors.dark,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trx.invoiceNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trx.createdAt ?? "-",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trx.paymentStatus.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Divider(height: 1, color: Colors.grey.shade200),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _info(
                      LucideIcons.user,
                      trx.customerName ?? "Customer Umum",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _info(
                      LucideIcons.truck,
                      trx.driverName?.trim().isNotEmpty == true
                          ? trx.driverName!
                          : "Empty",
                      color: trx.driverName?.trim().isNotEmpty == true
                          ? Colors.black87
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _info(LucideIcons.packageCheck, trx.deliveryType ?? "-"),

              const SizedBox(height: 10),
              //================ PRICE =================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _price("Total", formatRupiah(trx.total), bold: true),

                    const SizedBox(height: 5),

                    _price("Paid", formatRupiah(trx.paidAmount)),

                    const SizedBox(height: 5),

                    _price(
                      "Remaining",
                      formatRupiah(trx.remainingAmount),
                      color: trx.remainingAmount > 0
                          ? Colors.red
                          : Colors.green,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text, {Color color = Colors.black87}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade700),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _price(String title, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
