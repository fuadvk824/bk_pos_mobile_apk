import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionHeaderCard extends StatelessWidget {
  final TransactionDetailModel trx;

  const TransactionHeaderCard({super.key, required this.trx});

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "paid":
        return Icons.check_circle_rounded;
      case "partial":
        return Icons.schedule_rounded;
      case "unpaid":
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget infoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.light),
        const SizedBox(width: 6),
        Text(
          "$title :",
          style: const TextStyle(color: AppColors.light, fontSize: 12),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.light,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.secondary,
      surfaceTintColor: AppColors.primary,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.scrollText,
                    color: AppColors.secondary,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.light,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trx.createdAt ?? "-",
                        style: TextStyle(fontSize: 10, color: AppColors.light),
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
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trx.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            infoItem(LucideIcons.truck, "Driver", trx.driverName ?? "-"),
            const SizedBox(height: 10),
            infoItem(
              LucideIcons.packageCheck,
              "Delivery",
              trx.deliveryType ?? "-",
            ),

            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.light.withValues(alpha: .50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.fileText,
                    size: 16,
                    color: AppColors.light,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trx.notes ?? "Tidak ada pesan",
                      style: const TextStyle(
                        color: AppColors.light,
                        fontSize: 12,
                        height: 1.35,
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
