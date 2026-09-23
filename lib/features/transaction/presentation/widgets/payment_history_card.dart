import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentHistoryCard extends StatelessWidget {
  final TransactionDetailModel trx;
  final NumberFormat currency;

  const PaymentHistoryCard({
    super.key,
    required this.trx,
    required this.currency,
  });

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
              children: const [
                Icon(LucideIcons.wallet, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  "Riwayat Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 10),

            if (trx.payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.receiptText,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Belum ada pembayaran",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(trx.payments.length, (index) {
                final payment = trx.payments[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == trx.payments.length - 1 ? 0 : 12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.walletCards,
                              color: Colors.green,
                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${StringHelper.titleCase(payment.paymentMethod)} • ${payment.cashierName ?? "-"}",

                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  payment.paidAt ?? "-",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          Text(
                            currency.format(payment.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),

                      if (index != trx.payments.length - 1) ...[
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey.shade200, height: 1),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
