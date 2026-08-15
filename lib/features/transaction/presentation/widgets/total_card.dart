import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TotalCard extends StatelessWidget {
  final TransactionDetailModel trx;
  final NumberFormat currency;

  const TotalCard({super.key, required this.trx, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// Header
            Row(
              children: const [
                Icon(
                  LucideIcons.receiptText,
                  color: AppColors.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Ringkasan Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 10),

            _row("Subtotal", currency.format(trx.subtotal)),
            const SizedBox(height: 10),

            _row("Ongkir", currency.format(trx.shippingCost)),
            const SizedBox(height: 10),

            _row(
              "Potongan Point",
              "- ${currency.format(trx.pointsUsed)}",
              valueColor: Colors.orange.shade700,
            ),
            const SizedBox(height: 10),

            _row(
              "Sisa",
              currency.format(trx.remainingAmount),
              valueColor: trx.remainingAmount > 0 ? Colors.red : Colors.green,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),
                  Text(
                    currency.format(trx.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.secondary,
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

  Widget _row(String title, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
