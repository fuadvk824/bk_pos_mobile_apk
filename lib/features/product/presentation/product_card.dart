import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/features/product/presentation/product_scan_result.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final bool isBackorder;

  const ProductCard({
    super.key,
    required this.product,
    this.isBackorder = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductScanResultScreen(
                        product: product,
                        isBackorder: isBackorder,
                      ),
                    ),
                  );
                },

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                product.image != null &&
                                    product.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      size: 40,
                                    ),
                                  ),
                          ),

                          // Positioned(
                          //   left: 8,
                          //   bottom: 8,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 10,
                          //       vertical: 4,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: AppColors.light,
                          //       borderRadius: BorderRadius.circular(6),
                          //     ),
                          //     child: Text(
                          //       "Stok: ${product.stock}",
                          //       style: TextStyle(
                          //         fontSize: 11,
                          //         fontWeight: FontWeight.w600,
                          //         color: product.stock <= 0
                          //             ? Colors.red
                          //             : product.stock < 10
                          //             ? Colors.orange
                          //             : Colors.green,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      product.productCode,
                      style: TextStyle(color: AppColors.faded, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Stok: ${product.stock}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.stock <= 0
                            ? Colors.red
                            : product.stock < 10
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (product.discount > 0) ...[
                      Row(
                        children: [
                          Text(
                            formatRupiah(product.price),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.faded,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              formatRupiah(product.finalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "Hemat ${formatRupiah(product.discount)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      Text(
                        formatRupiah(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Text(
                        "Harga Normal",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  try {
                    final added = ref
                        .read(cartProvider.notifier)
                        .add(product, backorder: isBackorder);

                    if (!added) {
                      AppToast.error(
                        title: isBackorder
                            ? "Cart berisi produk normal"
                            : "Cart berisi produk backorder",
                        description: isBackorder
                            ? "Tidak bisa dicampur dengan produk backorder"
                            : "Tidak bisa dicampur dengan produk normal",
                      );

                      return;
                    }

                    AppToast.success(
                      title: isBackorder
                          ? "${product.name} ditambahkan sebagai Backorder"
                          : "${product.name} ditambahkan",
                    );
                  } catch (e) {
                    AppToast.error(
                      title: "Gagal menambahkan produk",
                      description: e.toString(),
                    );
                  }
                },

                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.dark,
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
