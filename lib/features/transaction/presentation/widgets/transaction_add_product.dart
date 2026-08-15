import 'package:bk_pos/features/product/presentation/product_scan_screen.dart';
import 'package:bk_pos/features/product/provider/product_provider.dart';
import 'package:bk_pos/features/transaction/data/transaction_repository.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/model/transaction_cart_item_model.dart';
import 'package:bk_pos/model/transaction_item_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionAddProduct extends ConsumerStatefulWidget {
  final int transactionId;
  final List<TransactionItemModel> existingItems;

  const TransactionAddProduct({
    super.key,
    required this.transactionId,
    required this.existingItems,
  });

  @override
  ConsumerState<TransactionAddProduct> createState() =>
      _TransactionAddProductState();
}

class _TransactionAddProductState extends ConsumerState<TransactionAddProduct> {
  final TransactionRepository repository = TransactionRepository();

  final TextEditingController searchController = TextEditingController();

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<TransactionCartItem> cart = [];

  bool isSaving = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void addProduct(ProductModel product) {
    final index = cart.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      setState(() {
        cart[index].quantity++;
        _resetSearch();
      });
      return;
    }

    setState(() {
      cart.add(TransactionCartItem(product: product));

      _resetSearch();
    });
  }

  void _resetSearch() {
    searchController.clear();
  }

  void removeProduct(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  void increaseQty(int index) {
    final item = cart[index];

    if (item.quantity >= item.product.stock) {
      AppToast.error(
        title: 'Stok Tidak Cukup',
        description: 'Jumlah melebihi stok tersedia',
      );
      return;
    }

    setState(() {
      item.quantity++;
    });
  }

  void decreaseQty(int index) {
    final item = cart[index];

    if (item.quantity <= 1) {
      removeProduct(index);
      return;
    }

    setState(() {
      item.quantity--;
    });
  }

  Future<void> openScanner() async {
    final product = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductScanScreen(returnProductOnly: true),
      ),
    );

    if (product != null) {
      addProduct(product);
    }
  }

  Future<void> saveCart() async {
    if (cart.isEmpty) {
      AppToast.error(
        title: 'Cart Kosong',
        description: 'Tambahkan minimal satu produk',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      for (final item in cart) {
        await repository.addProductToTransaction(
          transactionId: widget.transactionId,
          productId: item.product.id,
          quantity: item.quantity,
        );
      }

      if (!mounted) return;

      AppToast.success(title: 'Produk Berhasil Ditambahkan');

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(
        title: 'Gagal Menyimpan',
        description: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final search = searchController.text.trim().toLowerCase();

    final searchResults = search.isEmpty
        ? <ProductModel>[]
        : productState.allProducts.where((product) {
            return product.name.toLowerCase().contains(search) ||
                product.productCode.toLowerCase().contains(search);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Tambah Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) {
                        setState(() {});
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau kode produk...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),

                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Icon(
                            LucideIcons.search,
                            size: 21,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),

                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Hapus pencarian',
                                onPressed: () {
                                  setState(() {
                                    _resetSearch();
                                  });
                                },
                                icon: Icon(
                                  LucideIcons.x,
                                  size: 19,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,

                        border: InputBorder.none,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 17,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  height: 56,
                  width: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .25),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: FilledButton(
                      onPressed: openScanner,

                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.dark,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: Icon(Icons.qr_code_scanner, size: 27),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              children: [
                if (productState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                if (!productState.isLoading && search.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Hasil Pencarian',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${searchResults.length}',
                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ...searchResults.map((product) {
                    final isOutOfStock = product.stock <= 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .035),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),

                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? Colors.grey.shade100
                                : AppColors.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.package,
                            size: 21,
                            color: isOutOfStock
                                ? Colors.grey.shade400
                                : AppColors.primary,
                          ),
                        ),

                        title: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Text(
                                currency.format(product.finalPrice),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Text(
                                isOutOfStock
                                    ? 'Stok habis'
                                    : 'Stok ${product.stock}',
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? Colors.red.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        trailing: IconButton(
                          tooltip: isOutOfStock
                              ? 'Stok habis'
                              : 'Tambah produk',

                          onPressed: isOutOfStock
                              ? null
                              : () {
                                  addProduct(product);
                                },

                          style: IconButton.styleFrom(
                            backgroundColor: isOutOfStock
                                ? Colors.grey.shade100
                                : AppColors.primary.withValues(alpha: .1),
                            foregroundColor: isOutOfStock
                                ? Colors.grey.shade400
                                : AppColors.primary,
                            disabledForegroundColor: Colors.grey.shade400,
                            fixedSize: const Size(42, 42),
                          ),

                          icon: Icon(
                            isOutOfStock
                                ? LucideIcons.packageX
                                : LucideIcons.plus,
                            size: 21,
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
                ],

                const Text(
                  'Produk Dalam Transaksi',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                ...widget.existingItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),

                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.package,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),

                      title: Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${item.quantity} × ${currency.format(item.price)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      trailing: Text(
                        currency.format(item.subtotal),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                const Text(
                  'Produk Baru',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                if (cart.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Column(
                      children: [
                        Icon(
                          Icons.add_shopping_cart,

                          size: 50,

                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Belum ada produk baru',

                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                ...List.generate(cart.length, (index) {
                  final item = cart[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Row(
                                  children: [
                                    Text(
                                      currency.format(item.product.finalPrice),
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      ' (Stok: ${item.product.stock})',
                                      style: TextStyle(
                                        color: item.product.stock > 0
                                            ? Colors.grey.shade600
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    decreaseQty(index);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 38,
                                  ),
                                  icon: Icon(
                                    LucideIcons.minus,
                                    size: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    increaseQty(index);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 38,
                                  ),
                                  icon: Icon(
                                    LucideIcons.plus,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 4),

                          IconButton(
                            tooltip: 'Hapus produk',
                            onPressed: () {
                              removeProduct(index);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 38,
                              minHeight: 38,
                            ),
                            icon: Icon(
                              LucideIcons.trash2,
                              size: 19,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: isSaving ? null : saveCart,

              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.save, size: 20),

              label: Text(
                isSaving ? 'Menyimpan...' : 'Simpan Produk',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
