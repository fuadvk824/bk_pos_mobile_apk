import 'package:bk_pos/features/product/presentation/widgets/product_detail_header.dart';
import 'package:bk_pos/features/product/presentation/widgets/product_description_card.dart';
import 'package:bk_pos/features/product/presentation/widgets/product_info_card.dart';
import 'package:bk_pos/features/product/presentation/widgets/product_prince_card.dart';
import 'package:bk_pos/features/product/presentation/widgets/product_scan_bottom_bar.dart';
import 'package:bk_pos/features/product/presentation/widgets/product_store_stock.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/product_model.dart';
import '../../cashier/provider/cart_provider.dart';

class ProductScanResultScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  final bool isBackorder;

  const ProductScanResultScreen({
    super.key,
    required this.product,
    this.isBackorder = false,
  });

  @override
  ConsumerState<ProductScanResultScreen> createState() =>
      _ProductScanResultScreenState();
}

class _ProductScanResultScreenState
    extends ConsumerState<ProductScanResultScreen> {
  int _qty = 1;

  final TextEditingController _qtyController = TextEditingController(text: '1');
  final FocusNode _qtyFocus = FocusNode();

  bool get _stockError => !widget.isBackorder && _qty > widget.product.stock;

  @override
  void dispose() {
    _qtyController.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  void _updateQty(int value) {
    if (value < 1) {
      value = 1;
    }

    setState(() {
      _qty = value;

      _qtyController.text = value.toString();
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    });
  }

  void _addToCart() {
    if (_stockError) {
      return;
    }

    try {
      ref
          .read(cartProvider.notifier)
          .add(widget.product, qty: _qty, backorder: widget.isBackorder);

      Navigator.pop(context);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;

        AppToast.success(
          title: widget.isBackorder
              ? '${widget.product.name} ditambahkan sebagai Backorder'
              : '${widget.product.name} ditambahkan',
        );
      });
    } catch (e) {
      AppToast.error(
        title: 'Gagal menambahkan produk',
        description: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                ProductDetailHeader(product: widget.product),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -25),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 36, 12, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.category != null)
                            Chip(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: .5,
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              avatar: Icon(
                                Icons.category,
                                color: AppColors.primary,
                                size: 12,
                              ),
                              label: Text(
                                widget.product.category!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            children: [
                              Text(
                                formatRupiah(widget.product.finalPrice),
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (widget.product.discount > 0)
                                Text(
                                  formatRupiah(widget.product.price),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          ProductInfoCard(
                            product: widget.product,
                            isBackorder: widget.isBackorder,
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'Deskripsi Produk',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ProductDescriptionCard(
                            description: widget.product.description,
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'Informasi Harga',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ProductPriceCard(product: widget.product),

                          const SizedBox(height: 25),

                          const Text(
                            'Stock Per Cabang',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ProductStoreStock(product: widget.product),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          ProductScanBottomBar(
            product: widget.product,
            qty: _qty,
            qtyController: _qtyController,
            qtyFocus: _qtyFocus,
            isBackorder: widget.isBackorder,
            stockError: _stockError,
            onDecrease: _qty > 1 ? () => _updateQty(_qty - 1) : null,
            onIncrease: () => _updateQty(_qty + 1),
            onQtyChanged: (value) {
              final qty = int.tryParse(value);

              if (qty != null) {
                setState(() {
                  _qty = qty;
                });
              }
            },
            onEditingComplete: () {
              final qty = int.tryParse(_qtyController.text) ?? 1;
              _updateQty(qty);

              FocusScope.of(context).unfocus();
            },
            onAddToCart: _addToCart,
          ),
        ],
      ),
    );
  }
}
