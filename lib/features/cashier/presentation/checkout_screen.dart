import 'package:bk_pos/features/cashier/presentation/checkout_summary.dart';
import 'package:bk_pos/features/cashier/presentation/customer_form.dart';
import 'package:bk_pos/features/cashier/presentation/delivery_form.dart';
import 'package:bk_pos/features/cashier/presentation/payment_form.dart';
import 'package:bk_pos/features/cashier/provider/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text(
            "Data Customer",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const CustomerForm(),

          const SizedBox(height: 20),

          const Text(
            "Pengiriman",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const DeliveryForm(),

          const SizedBox(height: 20),

          const Text(
            "Pembayaran",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const PaymentForm(),

          const SizedBox(height: 20),

          const CheckoutSummary(),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final error = notifier.validateCheckout();

                      if (error != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));

                        return;
                      }

                      try {
                        await notifier.submit();

                        notifier.clearAll();

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Transaksi berhasil")),
                        );

                        Navigator.popUntil(context, (route) => route.isFirst);
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Simpan Transaksi"),
            ),
          ),
        ],
      ),
    );
  }
}
