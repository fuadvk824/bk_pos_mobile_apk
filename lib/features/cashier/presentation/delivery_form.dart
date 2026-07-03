import 'package:bk_pos/features/cashier/provider/delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryForm extends ConsumerWidget {
  const DeliveryForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryProvider);

    final notifier = ref.read(deliveryProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: state.delivery.deliveryType,
              items: const [
                DropdownMenuItem(value: "pickup", child: Text("Pickup")),
                DropdownMenuItem(value: "delivery", child: Text("Delivery")),
              ],
              onChanged: (v) {
                notifier.updateType(v!);
              },
            ),

            if (state.delivery.deliveryType == "delivery") ...[
              const SizedBox(height: 12),

              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: state.delivery.shippingCost.toInt().toString(),
                decoration: const InputDecoration(labelText: "Ongkir"),
                onChanged: (v) {
                  notifier.updateShipping(double.tryParse(v) ?? 0);
                },
              ),
            ],

            const SizedBox(height: 12),

            TextFormField(
              initialValue: state.delivery.notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Catatan"),
              onChanged: notifier.updateNotes,
            ),
          ],
        ),
      ),
    );
  }
}
 