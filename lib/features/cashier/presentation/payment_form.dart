import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/payment_provider.dart';
import '../provider/checkout_provider.dart';

class PaymentForm extends ConsumerStatefulWidget {
  const PaymentForm({super.key});

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  late final TextEditingController dpController;

  @override
  void initState() {
    super.initState();
    dpController = TextEditingController();
  }

  @override
  void dispose() {
    dpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);
    final checkout = ref.read(checkoutProvider.notifier);

    final total = checkout.total;

    final text = state.payment.paymentAmount == 0
        ? ""
        : state.payment.paymentAmount.toInt().toString();

    if (dpController.text != text) {
      dpController.text = text;
      dpController.selection = TextSelection.fromPosition(
        TextPosition(offset: dpController.text.length),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: state.payment.paymentStatus,
              items: const [
                DropdownMenuItem(value: "unpaid", child: Text("Belum Bayar")),
                DropdownMenuItem(value: "partial", child: Text("DP")),
                DropdownMenuItem(value: "paid", child: Text("Lunas")),
              ],
              onChanged: (v) {
                if (v != null) {
                  notifier.updateStatus(v);
                }
              },
            ),

            if (state.payment.paymentStatus != "unpaid") ...[
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: state.payment.paymentMethod,
                items: const [
                  DropdownMenuItem(value: "cash", child: Text("Cash")),
                  DropdownMenuItem(value: "transfer", child: Text("Transfer")),
                  DropdownMenuItem(value: "qris", child: Text("QRIS")),
                ],
                onChanged: (v) {
                  if (v != null) {
                    notifier.updateMethod(v);
                  }
                },
              ),
            ],

            if (state.payment.paymentStatus == "partial") ...[
              const SizedBox(height: 12),

              TextFormField(
                controller: dpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nominal DP"),
                onChanged: (v) {
                  double amount = double.tryParse(v) ?? 0;

                  if (amount > total) {
                    amount = total;

                    dpController.text = amount.toInt().toString();
                    dpController.selection = TextSelection.fromPosition(
                      TextPosition(offset: dpController.text.length),
                    );
                  }

                  notifier.updateAmount(amount, total);
                },
              ),
            ],

            if (state.payment.paymentStatus == "paid") ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Pembayaran penuh Rp ${checkout.total.toInt()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
