import 'package:bk_pos/features/cashier/presentation/checkout_summary.dart';
import 'package:bk_pos/features/cashier/presentation/customer_form.dart';
import 'package:bk_pos/features/cashier/presentation/delivery_form.dart';
import 'package:bk_pos/features/cashier/presentation/payment_form.dart';
import 'package:bk_pos/features/cashier/provider/checkout_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.muted,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        children: const [
          CustomerForm(),
          SizedBox(height: 12),
          DeliveryForm(),
          SizedBox(height: 12),
          PaymentForm(),
          SizedBox(height: 12),
          CheckoutSummary(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton.icon(
             
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final result = await notifier.processCheckout();

                      if (!context.mounted) return;

                      if (result.success) {
                        AppToast.success(
                          title: 'Checkout Berhasil',
                          description: result.message,
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        AppToast.error(
                          title: 'Checkout Gagal',
                          description: result.message,
                        );
                      }
                    },

              icon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                state.isLoading ? "Menyimpan..." : "Simpan Transaksi",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.blue.shade300,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
