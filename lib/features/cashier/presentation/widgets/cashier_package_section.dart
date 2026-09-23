import 'package:bk_pos/features/cashier/presentation/widgets/cashier_price_fields.dart';
import 'package:bk_pos/model/cart_item_model.dart';
import 'package:flutter/material.dart';

class CashierPackageSection extends StatelessWidget {
  final CartItemModel item;
  final int packageQty;
  final int retailQty;

  final TextEditingController packageSizeController;
  final TextEditingController packageQtyController;
  final TextEditingController packagePriceController;

  final FocusNode packageSizeFocusNode;
  final FocusNode packageQtyFocusNode;
  final FocusNode packagePriceFocusNode;

  final ValueChanged<String> onUpdatePackageSize;
  final ValueChanged<String> onUpdatePackageQty;
  final ValueChanged<String> onUpdatePackagePrice;

  final VoidCallback onReset;

  /// Formatter harga
  final String Function(double value) formatRupiah;

  const CashierPackageSection({
    super.key,
    required this.item,
    required this.packageQty,
    required this.retailQty,

    required this.packageSizeController,
    required this.packageQtyController,
    required this.packagePriceController,

    required this.packageSizeFocusNode,
    required this.packageQtyFocusNode,
    required this.packagePriceFocusNode,

    required this.onUpdatePackageSize,
    required this.onUpdatePackageQty,
    required this.onUpdatePackagePrice,

    required this.onReset,
    required this.formatRupiah,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QTY + HARGA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Isi 1 $packageUnitName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    CashierNumberField(
                      controller: packageSizeController,
                      focusNode: packageSizeFocusNode,
                      onChanged: onUpdatePackageSize,
                      onSubmitted: (_) {
                        packageSizeFocusNode.unfocus();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qty $packageUnitName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    CashierNumberField(
                      controller: packageQtyController,
                      focusNode: packageQtyFocusNode,
                      onChanged: onUpdatePackageQty,
                      onSubmitted: (_) {
                        packageQtyFocusNode.unfocus();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Harga / $packageUnitName',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          CashierPriceField(
            controller: packagePriceController,
            focusNode: packagePriceFocusNode,
            enabled: packageQty > 0,
            onChanged: onUpdatePackagePrice,
            onSubmitted: (_) {
              packagePriceFocusNode.unfocus();
            },
          ),

          // RINCIAN HARGA
          if (item.priceLines.isNotEmpty) ...[
            const SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in item.priceLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.label.toLowerCase() == 'dus'
                                ? 'Bundle: ${line.pcsQuantity} '
                                      '${item.product.unit}'
                                      ' (${line.quantity} $packageUnitName)'
                                : 'Satuan: ${line.quantity} '
                                      '${item.product.unit}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRupiah(line.subtotal),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
// import 'package:bk_pos/features/cashier/presentation/widgets/cashier_price_fields.dart';
// import 'package:bk_pos/model/cart_item_model.dart';
// import 'package:flutter/material.dart';

// class CashierPackageSection extends StatelessWidget {
//   final CartItemModel item;
//   final int packageQty;
//   final int retailQty;

//   final TextEditingController packageQtyController;
//   final TextEditingController packagePriceController;

//   final FocusNode packageQtyFocusNode;
//   final FocusNode packagePriceFocusNode;

//   final ValueChanged<String> onUpdatePackageQty;
//   final ValueChanged<String> onUpdatePackagePrice;

//   final VoidCallback onReset;

//   /// Formatter harga
//   final String Function(double value) formatRupiah;

//   const CashierPackageSection({
//     super.key,
//     required this.item,
//     required this.packageQty,
//     required this.retailQty,
//     required this.packageQtyController,
//     required this.packagePriceController,
//     required this.packageQtyFocusNode,
//     required this.packagePriceFocusNode,
//     required this.onUpdatePackageQty,
//     required this.onUpdatePackagePrice,
//     required this.onReset,
//     required this.formatRupiah,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(11),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // QTY + HARGA

//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 18,
//                       child: Row(
//                         children: [
//                           const Text(
//                             'Qty Bundle',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '(${item.priceLines.firstWhere((line) => line.label.toLowerCase() == 'dus', orElse: () => item.priceLines.first).quantity})',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     CashierNumberField(
//                       controller: packageQtyController,
//                       focusNode: packageQtyFocusNode,
//                       onChanged: onUpdatePackageQty,
//                       onSubmitted: (_) {
//                         packageQtyFocusNode.unfocus();
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(
//                       height: 18,
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Harga / pcs',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     CashierPriceField(
//                       controller: packagePriceController,
//                       focusNode: packagePriceFocusNode,
//                       enabled: packageQty > 0,
//                       onChanged: onUpdatePackagePrice,
//                       onSubmitted: (_) {
//                         packagePriceFocusNode.unfocus();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           // RINCIAN HARGA
//           if (item.priceLines.isNotEmpty) ...[
//             const SizedBox(height: 10),

//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 for (final line in item.priceLines)
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           line.label.toLowerCase() == 'dus'
//                               ? 'Bundle '
//                                     '(${line.quantity * line.unitSize}pcs) × '
//                                     '${formatRupiah(line.price)}'
//                               : 'Satuan '
//                                     '(${line.quantity}pcs) × '
//                                     '${formatRupiah(line.price)}',
//                           style: const TextStyle(fontSize: 11),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         formatRupiah(line.subtotal),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
