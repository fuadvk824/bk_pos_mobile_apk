import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomerCard extends StatelessWidget {
  final TransactionDetailModel trx;

  const CustomerCard({super.key, required this.trx});

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.dark),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.isEmpty ? "-" : text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.dark,
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

            Row(
              children: [
                Icon(
                  LucideIcons.userRound,
                  color: AppColors.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "${trx.customerName ?? "-"} (Customer)",
                  
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 10),

            _infoRow(LucideIcons.phone, trx.customerPhone ?? "-"),

            const SizedBox(height: 10),

            _infoRow(LucideIcons.mapPin, trx.customerAddress ?? "-"),
          ],
        ),
      ),
    );
  }
}
