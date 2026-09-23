import 'package:bk_pos/features/cashier/presentation/widgets/cashier_price_fields.dart';
import 'package:bk_pos/features/cashier/presentation/widgets/cashier_package_section.dart';
import 'package:bk_pos/features/cashier/presentation/widgets/cashier_quantity_control.dart';
import 'package:bk_pos/model/cart_item_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CashierCartItem extends StatelessWidget {
  final CartItemModel item;
  final int index;
  final bool isBackorder;

  final TextEditingController qtyController;
  final TextEditingController packageQtyController;
  final TextEditingController packageSizeController;
  final TextEditingController packagePriceController;
  final TextEditingController retailPriceController;

  final FocusNode qtyFocusNode;
  final FocusNode packageQtyFocusNode;
  final FocusNode packageSizeFocusNode;
  final FocusNode packagePriceFocusNode;
  final FocusNode retailPriceFocusNode;

  final String Function(double value) formatRupiah;

  final ValueChanged<String> onUpdateQty;
  final VoidCallback onIncreaseQty;
  final VoidCallback onDecreaseQty;

  final ValueChanged<String> onUpdatePackageQty;
  final ValueChanged<String> onUpdatePackageSize;
  final ValueChanged<String> onUpdatePackagePrice;
  final ValueChanged<String> onUpdateRetailPrice;

  final ValueChanged<bool> onTogglePackagePricing;
  final VoidCallback onRemove;
  final VoidCallback onResetPackagePricing;

  const CashierCartItem({
    super.key,
    required this.item,
    required this.index,
    required this.isBackorder,

    required this.qtyController,
    required this.packageQtyController,
    required this.packageSizeController,
    required this.packagePriceController,
    required this.retailPriceController,

    required this.qtyFocusNode,
    required this.packageQtyFocusNode,
    required this.packageSizeFocusNode,
    required this.packagePriceFocusNode,
    required this.retailPriceFocusNode,

    required this.formatRupiah,

    required this.onUpdateQty,
    required this.onIncreaseQty,
    required this.onDecreaseQty,

    required this.onUpdatePackageQty,
    required this.onUpdatePackageSize,
    required this.onUpdatePackagePrice,
    required this.onUpdateRetailPrice,

    required this.onTogglePackagePricing,
    required this.onRemove,
    required this.onResetPackagePricing,
  });

  String get packageUnitName {
    final unit = item.product.unit2?.trim();

    if (unit == null || unit.isEmpty) {
      return 'Bundle';
    }

    return unit;
  }

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    final packageQty = item.packageCount;
    final retailQty = item.retailQty;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.stockError && !isBackorder ? Colors.red : Colors.black,
          // : Colors.grey.shade300,
        ),
      ),
      child: Stack(
        children: [
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
                    offset: const Offset(8, -5),
                    child: Text(
                      '${index + 1}',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga / ${product.unit}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '(Default: ${formatRupiah(product.finalPrice)})',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                CashierPriceField(
                  controller: retailPriceController,
                  focusNode: retailPriceFocusNode,
                  onChanged: onUpdateRetailPrice,
                  onSubmitted: (_) {
                    retailPriceFocusNode.unfocus();
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '(Stok: ${product.stock})',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Expanded(
                      child: CashierQuantityControl(
                        item: item,
                        controller: qtyController,
                        focusNode: qtyFocusNode,
                        onChanged: onUpdateQty,
                        onIncrease: onIncreaseQty,
                        onDecrease: onDecreaseQty,
                      ),
                    ),

                    const SizedBox(width: 8),

                    SizedBox(
                      height: 44,
                      width: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.dark,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onRemove,
                        child: const Icon(Icons.delete, size: 20),
                      ),
                    ),
                  ],
                ),

                if (item.stockError && !isBackorder) ...[
                  const SizedBox(height: 10),
                  _buildStockError(),
                ],

                const SizedBox(height: 10),

                _buildPackageToggle(context),

                if (item.usePackagePricing) ...[
                  const SizedBox(height: 10),

                  CashierPackageSection(
                    item: item,
                    packageQty: packageQty,
                    retailQty: retailQty,

                    packageSizeController: packageSizeController,
                    packageQtyController: packageQtyController,
                    packagePriceController: packagePriceController,

                    packageSizeFocusNode: packageSizeFocusNode,
                    packageQtyFocusNode: packageQtyFocusNode,
                    packagePriceFocusNode: packagePriceFocusNode,

                    onUpdatePackageSize: onUpdatePackageSize,
                    onUpdatePackageQty: onUpdatePackageQty,
                    onUpdatePackagePrice: onUpdatePackagePrice,

                    onReset: onResetPackagePricing,
                    formatRupiah: formatRupiah,
                  ),
                ],

                const SizedBox(height: 12),

                Text(
                  'Subtotal : ${formatRupiah(item.subtotal)}',
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
    );
  }

  Widget _buildProductHeader() {
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            product.productCode,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: true,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
          value: item.usePackagePricing,
          title: Text(
            'Harga Bundle (1 $packageUnitName) = ${item.product.conv2 ?? 0} ${item.product.unit}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: (item.product.conv2 ?? 0) == 0
                  ? AppColors.primary
                  : AppColors.dark,
            ),
          ),

          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            onTogglePackagePricing(value ?? false);
          },
        ),
      ),
    );
  }

  Widget _buildStockError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Jumlah melebihi stok tersedia (${item.product.stock})',
        style: const TextStyle(fontSize: 11, color: AppColors.dark),
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
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
