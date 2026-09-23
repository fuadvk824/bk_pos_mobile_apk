import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';

class ProductDetailHeader extends StatelessWidget {
  final ProductModel product;

  const ProductDetailHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      centerTitle: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final visible =
              constraints.biggest.height <=
              kToolbarHeight + MediaQuery.of(context).padding.top + 20;

          return FlexibleSpaceBar(
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: visible ? 1 : 0,
              child: const Text(
                'Detail Produk',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (product.image != null && product.image!.isNotEmpty)
                  Image.network(product.image!, fit: BoxFit.cover)
                else
                  Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.inventory_2, size: 120),
                  ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black45],
                      ),
                    ),
                  ),
                ),

                if (product.discount > 0)
                  Positioned(
                    left: 16,
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '-${formatRupiah(product.discount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
