import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/features/cashier/provider/delivery_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DeliveryForm extends ConsumerStatefulWidget {
  const DeliveryForm({super.key});

  @override
  ConsumerState<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends ConsumerState<DeliveryForm> {
  late final TextEditingController shippingController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();

    final delivery = ref.read(deliveryProvider).delivery;
    shippingController = TextEditingController(
      text: delivery.shippingCost == 0
          ? ''
          : formatRupiah(delivery.shippingCost),
    );
    notesController = TextEditingController(text: delivery.notes);
  }

  @override
  void dispose() {
    shippingController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryProvider);
    final notifier = ref.read(deliveryProvider.notifier);

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
              "Pengiriman",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(state.delivery.deliveryType),
              initialValue: state.delivery.deliveryType,
              decoration: inputDecoration(
                label: "Metode Pengiriman",
                icon: LucideIcons.truck,
              ),
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: "pickup", child: Text("Pickup")),
                DropdownMenuItem(value: "delivery", child: Text("Delivery")),
              ],
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                if (value != null) {
                  FocusScope.of(context).unfocus();
                  notifier.updateType(value);
                }
              },
            ),

            if (state.delivery.deliveryType == "delivery") ...[
              const SizedBox(height: 12),

              TextField(
                controller: shippingController,
                keyboardType: TextInputType.number,
                onTap: () {
                  shippingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: shippingController.text.length,
                  );
                },
                decoration: inputDecoration(
                  label: "Biaya Ongkir",
                  icon: LucideIcons.badgeDollarSign,
                ),
                onChanged: (value) {
                  final amount = parseRupiah(value);

                  notifier.updateShipping(amount);

                  final formatted = amount == 0 ? "" : formatRupiah(amount);

                  if (shippingController.text != formatted) {
                    shippingController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
              ),
            ],

            const SizedBox(height: 12),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: inputDecoration(
                label: "Catatan Pengiriman",
                icon: LucideIcons.notepadText,
              ),
              onChanged: notifier.updateNotes,
            ),
          ],
        ),
      ),
    );
  }
}
