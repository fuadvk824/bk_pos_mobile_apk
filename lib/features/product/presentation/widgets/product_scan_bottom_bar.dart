import 'package:bk_pos/features/product/presentation/widgets/product_quantity_control.dart';
import 'package:bk_pos/features/product/presentation/widgets/thermal_product_screen.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ProductScanBottomBar extends StatelessWidget {
  final ProductModel product;
  final int qty;
  final TextEditingController qtyController;
  final FocusNode qtyFocus;
  final bool isBackorder;
  final bool stockError;

  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<String> onQtyChanged;
  final VoidCallback onEditingComplete;
  final VoidCallback onAddToCart;

  const ProductScanBottomBar({
    super.key,
    required this.product,
    required this.qty,
    required this.qtyController,
    required this.qtyFocus,
    required this.isBackorder,
    required this.stockError,
    required this.onDecrease,
    required this.onIncrease,
    required this.onQtyChanged,
    required this.onEditingComplete,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stockError)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jumlah melebihi stok (${product.stock})',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThermalProductScreen(product: product),
                    ),
                  );
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print Harga Produk'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                ProductQuantityControl(
                  qty: qty,
                  controller: qtyController,
                  focusNode: qtyFocus,
                  onDecrease: onDecrease,
                  onIncrease: onIncrease,
                  onChanged: onQtyChanged,
                  onEditingComplete: onEditingComplete,
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Tambah Keranjang'),
                    onPressed: stockError ? null : onAddToCart,
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
