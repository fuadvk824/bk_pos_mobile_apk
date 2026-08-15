import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

    final payment = ref.read(paymentProvider).payment;

    dpController = TextEditingController(
      text: payment.paymentAmount == 0
          ? ''
          : formatRupiah(payment.paymentAmount),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   dpController = TextEditingController();
  // }

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

    // final text = state.payment.paymentAmount == 0
    //     ? ""
    //     : state.payment.paymentAmount.toInt().toString();

    // if (dpController.text != text) {
    //   dpController.text = text;
    //   dpController.selection = TextSelection.fromPosition(
    //     TextPosition(offset: dpController.text.length),
    //   );
    // }

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
              "Pembayaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              key: ValueKey(state.payment.paymentStatus),
              initialValue: state.payment.paymentStatus,
              decoration: inputDecoration(
                label: "Status Pembayaran",
                icon: LucideIcons.circleDollarSign,
              ),
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: "unpaid", child: Text("Belum Bayar")),
                DropdownMenuItem(value: "partial", child: Text("DP")),
                DropdownMenuItem(value: "paid", child: Text("Lunas")),
              ],
              onChanged: (v) {
                if (v != null) notifier.updateStatus(v);
              },
            ),

            if (state.payment.paymentStatus != "unpaid") ...[
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                key: ValueKey(state.payment.paymentMethod),
                initialValue: state.payment.paymentMethod,
                decoration: inputDecoration(
                  label: "Metode Pembayaran",
                  icon: LucideIcons.wallet,
                ),
                borderRadius: BorderRadius.circular(12),
                items: const [
                  DropdownMenuItem(value: "cash", child: Text("Cash")),
                  DropdownMenuItem(value: "transfer", child: Text("Transfer")),
                  DropdownMenuItem(value: "qris", child: Text("QRIS")),
                ],
                onChanged: (v) {
                  if (v != null) notifier.updateMethod(v);
                },
              ),
            ],

            // if (state.payment.paymentStatus == "partial") ...[
            //   const SizedBox(height: 12),

            //   TextField(
            //     controller: dpController,
            //     keyboardType: TextInputType.number,
            //     decoration: inputDecoration(
            //       label: "Nominal DP",
            //       icon: LucideIcons.handCoins,
            //     ),
            //     onChanged: (v) {
            //       double amount = double.tryParse(v) ?? 0;

            //       if (amount > total) {
            //         amount = total;

            //         dpController.text = amount.toInt().toString();

            //         dpController.selection = TextSelection.fromPosition(
            //           TextPosition(offset: dpController.text.length),
            //         );
            //       }

            //       notifier.updateAmount(amount, total);
            //     },
            //   ),
            // ],
            if (state.payment.paymentStatus == "partial") ...[
              const SizedBox(height: 12),

              TextField(
                controller: dpController,
                keyboardType: TextInputType.number,
                onTap: () {
                  dpController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: dpController.text.length,
                  );
                },
                decoration: inputDecoration(
                  label: "Nominal DP",
                  icon: LucideIcons.handCoins,
                ),
                onChanged: (value) {
                  double amount = parseRupiah(value);

                  if (amount > total) {
                    amount = total;
                  }

                  notifier.updateAmount(amount, total);

                  final formatted = amount == 0 ? "" : formatRupiah(amount);

                  if (dpController.text != formatted) {
                    dpController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
              ),
            ],

            if (state.payment.paymentStatus == "paid") ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.badgeCheck, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Pembayaran penuh\nRp ${checkout.total.toInt()}",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
