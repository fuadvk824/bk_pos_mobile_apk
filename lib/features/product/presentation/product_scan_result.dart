import 'package:bk_pos/features/product/presentation/widgets/thermal_product_screen.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/product_model.dart';
import '../../../utils/format_rupiah.dart';
import '../../cashier/provider/cart_provider.dart';

class ProductScanResultScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  // const ProductScanResultScreen({super.key, required this.product});
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
  bool _showFullDescription = false;
  int _qty = 1;
  // bool get _stockError => _qty > widget.product.stock;
  bool get _stockError => !widget.isBackorder && _qty > widget.product.stock;

  final TextEditingController _qtyController = TextEditingController(text: "1");
  final FocusNode _qtyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _qtyController.text = _qty.toString();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  void _updateQty(int value) {
    if (value < 1) value = 1;

    setState(() {
      _qty = value;
      _qtyController.text = value.toString();
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    });
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
                SliverAppBar(
                  expandedHeight: 380,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  centerTitle: true,

                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final visible =
                          constraints.biggest.height <=
                          kToolbarHeight +
                              MediaQuery.of(context).padding.top +
                              20;

                      return FlexibleSpaceBar(
                        title: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: visible ? 1 : 0,
                          child: Text(
                            "Detail Produk",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (widget.product.image != null &&
                                widget.product.image!.isNotEmpty)
                              Image.network(
                                widget.product.image!,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.inventory_2, size: 120),
                              ),

                            // gradient agar tulisan lebih jelas
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
                                    colors: [
                                      Colors.transparent,
                                      Colors.black45,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (widget.product.discount > 0)
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
                                    "-${formatRupiah(widget.product.discount)}",
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
                ),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -25),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
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
                              backgroundColor: Colors.orange.shade50,
                              avatar: const Icon(
                                Icons.category,
                                color: Colors.deepOrange,
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
                              SizedBox(width: 10),
                              if (widget.product.discount > 0) ...[
                                Text(
                                  formatRupiah(widget.product.price),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 30),

                          Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  _infoTile(
                                    Icons.qr_code,
                                    "Kode Produk",
                                    widget.product.productCode,
                                  ),

                                  Divider(),

                                  // _infoTile(
                                  //   Icons.inventory,
                                  //   "Stok",
                                  //   "${widget.product.stock}",
                                  // ),
                                  _infoTile(
                                    Icons.inventory,
                                    "Stok",
                                    widget.isBackorder
                                        ? "Backorder"
                                        : "${widget.product.stock}",
                                  ),

                                  Divider(),

                                  _infoTile(
                                    Icons.scale,
                                    "Satuan",
                                    widget.product.unit,
                                  ),

                                  Divider(),

                                  _infoTile(
                                    Icons.local_fire_department,
                                    "Terjual",
                                    "${widget.product.sold}",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            "Deskripsi Produk",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // const SizedBox(height: 10),
                          Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    child: Text(
                                      widget.product.description != null &&
                                              widget.product.description!
                                                  .trim()
                                                  .isNotEmpty
                                          ? widget.product.description!
                                          : "Belum ada deskripsi untuk produk ini.",
                                      maxLines: _showFullDescription ? null : 3,
                                      overflow: _showFullDescription
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.8,
                                      ),
                                    ),
                                  ),

                                  if ((widget.product.description ?? "")
                                          .length >
                                      120)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _showFullDescription =
                                                !_showFullDescription;
                                          });
                                        },
                                        child: Text(
                                          _showFullDescription
                                              ? "Tampilkan Lebih Sedikit"
                                              : "Lihat Selengkapnya",
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            "Informasi Harga",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  _infoTile(
                                    Icons.payments_outlined,
                                    "Harga Jual",
                                    formatRupiah(widget.product.price),
                                  ),

                                  const Divider(),

                                  _infoTile(
                                    Icons.discount,
                                    "Diskon",
                                    formatRupiah(widget.product.discount),
                                    valueColor: Colors.red,
                                  ),

                                  const Divider(),

                                  _infoTile(
                                    Icons.attach_money,
                                    "Harga Akhir",
                                    formatRupiah(widget.product.finalPrice),
                                    valueColor: Colors.deepOrange,
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
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
                  if (_stockError)
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
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Jumlah melebihi stok (${widget.product.stock})",
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
                            builder: (_) =>
                                ThermalProductScreen(product: widget.product),
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
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _qty > 1
                                  ? () {
                                      _updateQty(_qty - 1);
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),

                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: _qtyController,
                                focusNode: _qtyFocus,
                                keyboardType: TextInputType.number,

                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],

                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  final qty = int.tryParse(value);

                                  if (qty != null) {
                                    setState(() {
                                      _qty = qty;
                                    });
                                  }
                                },
                                onEditingComplete: () {
                                  final qty =
                                      int.tryParse(_qtyController.text) ?? 1;
                                  _updateQty(qty);
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                _updateQty(_qty + 1);
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
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
                          label: const Text("Tambah Keranjang"),
                          // onPressed: _stockError
                          //     ? null
                          //     : () {
                          //         ref
                          //             .read(cartProvider.notifier)
                          //             .add(widget.product, qty: _qty);

                          //         Navigator.pop(context);

                          //         Future.delayed(
                          //           const Duration(milliseconds: 100),
                          //           () {
                          //             AppToast.success(
                          //               title:
                          //                   "${widget.product.name} ditambahkan",
                          //             );
                          //           },
                          //         );
                          //       },
                          onPressed: _stockError
                              ? null
                              : () {
                                  try {
                                    ref
                                        .read(cartProvider.notifier)
                                        .add(
                                          widget.product,
                                          qty: _qty,
                                          backorder: widget.isBackorder,
                                        );

                                    Navigator.pop(context);

                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () {
                                        AppToast.success(
                                          title: widget.isBackorder
                                              ? "${widget.product.name} ditambahkan sebagai Backorder"
                                              : "${widget.product.name} ditambahkan",
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    AppToast.error(
                                      title: 'Gagal menambahkan produk',
                                      description: e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepOrange),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
