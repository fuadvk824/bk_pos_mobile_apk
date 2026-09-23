import 'package:bk_pos/features/cashier/provider/payment_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../provider/cart_provider.dart';
import '../provider/customer_provider.dart';
import '../provider/delivery_provider.dart';

class CheckoutSummary extends ConsumerWidget {
  const CheckoutSummary({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final customer = ref.watch(customerProvider);
    final delivery = ref.watch(deliveryProvider);

    final payment = ref.watch(paymentProvider);

    final shipping = delivery.delivery.deliveryType == "delivery"
        ? delivery.delivery.shippingCost
        : 0;

    final points = customer.pointsUsed;
    final nego = payment.payment.nego;
    final totalDiscount = points + nego;
    final total = cart.subtotal + shipping - totalDiscount;

    Widget summaryItem({
      required IconData icon,
      required String title,
      required String value,
      Color? color,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Pembayaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            summaryItem(
              icon: LucideIcons.shoppingBasket,
              title: "Subtotal",
              value: formatRupiah(cart.subtotal),
            ),
            summaryItem(
              icon: LucideIcons.truck,
              title: "Ongkir",
              value: formatRupiah(shipping),
            ),
            summaryItem(
              icon: LucideIcons.tags,
              title: "Point & Diskon",
              value: "- ${formatRupiah(totalDiscount)}",
              color: Colors.orange.shade700,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.walletCards, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    formatRupiah(total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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

 