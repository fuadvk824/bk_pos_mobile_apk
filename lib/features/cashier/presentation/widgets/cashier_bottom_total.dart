import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CashierBottomTotal extends StatelessWidget {
  final CartState cart;
  final String Function(double value) formatRupiah;
  final VoidCallback onCheckout;

  const CashierBottomTotal({
    super.key,
    required this.cart,
    required this.formatRupiah,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final canCheckout =
        cart.items.isNotEmpty && (!cart.hasStockError || cart.isBackorder);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.light,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, -2),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 13)),

                const Spacer(),

                Text(
                  formatRupiah(cart.subtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (cart.isBackorder)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 15,
                      color: Colors.orange.shade700,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      'Transaksi akan diproses sebagai Backorder',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: canCheckout ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.dark,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cart.isBackorder
                          ? Icons.local_shipping_outlined
                          : Icons.shopping_cart_checkout,
                      size: 19,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      cart.isBackorder ? 'Proses Backorder' : 'Proses Checkout',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
