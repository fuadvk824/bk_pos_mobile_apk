import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final shipping =
        delivery.delivery.deliveryType == "delivery"
            ? delivery.delivery.shippingCost
            : 0;

    final total =
        cart.subtotal +
        shipping -
        customer.pointsUsed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Subtotal"),
                const Spacer(),
                Text(
                  "Rp ${cart.subtotal.toInt()}",
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text("Ongkir"),
                const Spacer(),
                Text(
                  "Rp ${shipping.toInt()}",
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text("Point"),
                const Spacer(),
                Text(
                  "-Rp ${customer.pointsUsed}",
                ),
              ],
            ),

            const Divider(),

            Row(
              children: [
                const Text(
                  "TOTAL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Rp ${total.toInt()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
