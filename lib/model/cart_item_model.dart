 
// import 'package:bk_pos/model/product_model.dart';

// class CartItemModel {
//   final ProductModel product;

//   int qty;

//   double? customPrice;

//   CartItemModel({required this.product, this.qty = 1, this.customPrice});

//   double get sellingPrice {
//     if (customPrice != null) {
//       return customPrice!;
//     }

//     if (product.discount > 0) {
//       return product.finalPrice;
//     }

//     return product.price;
//   }

//   double get subtotal => qty * sellingPrice;

//   bool get stockError => qty > product.stock;
// }


import 'package:bk_pos/model/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int qty;
  final double? customPrice;

  const CartItemModel({
    required this.product,
    this.qty = 1,
    this.customPrice,
  });

  double get sellingPrice {
    if (customPrice != null) {
      return customPrice!;
    }

    if (product.discount > 0) {
      return product.finalPrice;
    }

    return product.price;
  }

  double get subtotal => qty * sellingPrice;
  bool get stockError => qty > product.stock;

  CartItemModel copyWith({
    ProductModel? product,
    int? qty,
    double? customPrice,
    bool resetCustomPrice = false,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      qty: qty ?? this.qty,
      customPrice: resetCustomPrice
          ? null
          : (customPrice ?? this.customPrice),
    );
  }
}