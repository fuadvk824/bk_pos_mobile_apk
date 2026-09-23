import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ItemsCard extends StatelessWidget {
  final TransactionDetailModel trx;
  final NumberFormat currency;

  const ItemsCard({super.key, required this.trx, required this.currency});

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
                Icon(
                  LucideIcons.shoppingBag,
                  color: AppColors.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Item Transaksi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 10),

            ...List.generate(trx.items.length, (index) {
              final item = trx.items[index];
              final showQtyUnit = item.quantity / item.qtyUnit != 1;
              final qtyUnitText = showQtyUnit ? ' (${item.qtyUnit}${item.unit})' : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.package,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                   
                                  Text(
                                    "${item.quantity} ${item.satuanUnit}$qtyUnitText × ",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),

                                  if (item.discount > 0)
                                    Text(
                                      currency.format(item.basePrice),
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),

                                  if (item.discount > 0)
                                    const SizedBox(width: 6),

                                  Text(
                                    currency.format(item.price),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: item.discount > 0
                                          ? Colors.red
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Subtotal",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currency.format(item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (index != trx.items.length - 1) ...[
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
