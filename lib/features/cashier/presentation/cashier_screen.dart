import 'package:bk_pos/features/cashier/presentation/checkout_screen.dart';
import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/features/cashier/provider/checkout_provider.dart';
import 'package:bk_pos/model/cart_item_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  final Map<int, TextEditingController> priceControllers = {};

  TextEditingController controllerFor(CartItemModel item) {
    return priceControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(text: item.sellingPrice.toInt().toString()),
    );
  }

  @override
  void dispose() {
    for (final c in priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Keranjang Kasir",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.grey.shade300),

          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Belum ada produk'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      final controller = controllerFor(item);
                      final value = item.sellingPrice.toInt().toString();
                      if (controller.text != value) {
                        controller.text = value;
                      }
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: item.stockError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Stack(
                              children: [
                                /// nomor pojok kanan
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: ClipPath(
                                    clipper: TriangleClipper(),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      color: Colors.black,
                                      child: Center(
                                        child: Transform.translate(
                                          offset: const Offset(
                                            8,
                                            -5,
                                          ), // sesuaikan jika perlu
                                          child: Text(
                                            "${index + 1}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      if (item.product.discount > 0) ...[
                                        Text(
                                          "Rp ${item.product.price.toInt()}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),

                                        Text(
                                          "Harga Diskon : ${formatRupiah(item.product.finalPrice)}",
                                          
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          "Harga : ${formatRupiah(item.product.price)}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),

                                      const SizedBox(height: 18),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Quantity"),
                                          Text(
                                            "(Stok : ${item.product.stock})",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 42,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        cartNotifier.updateQty(
                                                          item.product.id,
                                                          item.qty - 1,
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.remove,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    width: 1,
                                                    color: Colors.grey.shade300,
                                                  ),

                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        item.qty.toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    width: 1,
                                                    color: Colors.grey.shade300,
                                                  ),

                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        cartNotifier.updateQty(
                                                          item.product.id,
                                                          item.qty + 1,
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          SizedBox(
                                            height: 42,
                                            width: 42,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                cartNotifier.remove(
                                                  item.product.id,
                                                );
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                color: AppColors.dark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (item.stockError)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            "Jumlah melebihi stok tersedia (${item.product.stock})",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.dark,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 12),

                                      Text(
                                        "Subtotal : ${formatRupiah(item.subtotal)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.light,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text("Subtotal"),
                  const Spacer(),
                  Text(" ${formatRupiah(cart.subtotal)}"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    " ${formatRupiah(checkoutNotifier.total)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    foregroundColor: AppColors.dark, 
                    disabledBackgroundColor:
                        AppColors.muted, // Saat disabled
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: cart.items.isEmpty || cart.hasStockError
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                  child: const Text("Proses Checkout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
