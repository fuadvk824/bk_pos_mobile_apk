import 'cart_price_line.dart';
import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int qty;

  final List<CartPriceLine> priceLines;
  final bool usePackagePricing;
  final double? retailUnitPrice;
  final double? packageUnitPrice;

  /// Isi 1 bundle/dus dalam pcs.
  /// Nilainya berasal dari product.conv2.
  final int? packageSize;

  const CartItemModel({
    required this.product,
    required this.qty,
    required this.priceLines,
    this.usePackagePricing = false,
    this.retailUnitPrice,
    this.packageUnitPrice,
    this.packageSize,
  });

  double get defaultRetailPrice {
    return product.discount > 0 ? product.finalPrice : product.price;
  }

  double get currentRetailPrice {
    if (retailUnitPrice != null) {
      return retailUnitPrice!;
    }

    final line = priceLines.cast<CartPriceLine?>().firstWhere(
      (line) => line?.label.toLowerCase() == 'eceran',
      orElse: () => null,
    );

    return line?.price ?? defaultRetailPrice;
  }

  double get currentPackagePrice {
    if (packageUnitPrice != null) {
      return packageUnitPrice!;
    }

    final line = priceLines.cast<CartPriceLine?>().firstWhere(
      (line) => line?.label.toLowerCase() == 'dus',
      orElse: () => null,
    );

    return line?.price ?? 0;
  }

  /// Isi 1 bundle/dus.
  // int get packageSizeValue {
  //   return packageSize ?? product.conv2;
  // }
  int get packageSizeValue {
    return packageSize ?? product.conv2 ?? 0;
  }

  /// Jumlah bundle/dus yang sedang digunakan di cart.
  int get packageCount {
    final size = packageSizeValue;

    if (size <= 0) return 0;

    return qty ~/ size;
  }

  /// Total pcs yang masuk bundle.
  int get packagePcs {
    final size = packageSizeValue;

    if (size <= 0) return 0;

    return packageCount * size;
  }

  /// Sisa pcs yang dijual eceran.
  int get retailQty {
    final size = packageSizeValue;

    if (size <= 0) {
      return qty;
    }

    return qty % size;
  }

  double get retailPrice => currentRetailPrice;

  double get packagePrice => currentPackagePrice;

  bool get hasPackagePrice {
    return usePackagePricing && packageSizeValue > 0;
  }

  bool get hasMultiplePrices {
    return priceLines.length > 1;
  }

  int get pricedQty {
    return priceLines.fold(0, (sum, line) => sum + line.pcsQuantity);
  }

  bool get isPricingComplete {
    return pricedQty == qty;
  }

  double get subtotal {
    return priceLines.fold(0, (sum, line) => sum + line.subtotal);
  }

  double get sellingPrice {
    if (qty <= 0) return 0;

    return subtotal / qty;
  }

  bool get stockError {
    return qty > product.stock;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? qty,
    List<CartPriceLine>? priceLines,
    bool? usePackagePricing,
    double? retailUnitPrice,
    double? packageUnitPrice,
    int? packageSize,
    bool clearRetailUnitPrice = false,
    bool clearPackageUnitPrice = false,
    bool clearPackageSize = false,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      qty: qty ?? this.qty,
      priceLines: priceLines ?? this.priceLines,
      usePackagePricing: usePackagePricing ?? this.usePackagePricing,
      retailUnitPrice: clearRetailUnitPrice
          ? null
          : retailUnitPrice ?? this.retailUnitPrice,
      packageUnitPrice: clearPackageUnitPrice
          ? null
          : packageUnitPrice ?? this.packageUnitPrice,
      packageSize: clearPackageSize ? null : packageSize ?? this.packageSize,
    );
  }
}

// import 'cart_price_line.dart';
// import 'product_model.dart';

// class CartItemModel {
//   final ProductModel product;
//   final int qty;

//   final List<CartPriceLine> priceLines;
//   final bool usePackagePricing;
//   final double? retailUnitPrice;
//   final double? packageUnitPrice;
//   final int? packageSize;

//   const CartItemModel({
//     required this.product,
//     this.qty = 1,
//     this.priceLines = const [],
//     this.usePackagePricing = false,
//     this.retailUnitPrice,
//     this.packageUnitPrice,
//     this.packageSize,
//   });

//   double get defaultRetailPrice {
//     if (product.discount > 0) {
//       return product.finalPrice;
//     }

//     return product.price;
//   }

//   double get currentRetailPrice {
//     if (retailUnitPrice != null) {
//       return retailUnitPrice!;
//     }

//     for (final line in priceLines) {
//       if (line.label == 'Eceran') {
//         return line.price;
//       }
//     }

//     return defaultRetailPrice;
//   }

//   double get currentPackagePrice {
//     if (packageUnitPrice != null) {
//       return packageUnitPrice!;
//     }

//     for (final line in priceLines) {
//       if (line.label == 'Dus') {
//         return line.price;
//       }
//     }

//     return currentRetailPrice;
//   }

//   int get packageQty {
//     return packageSize ?? 0;
//   }

//   int get packageCount {
//     if (packageQty <= 0) {
//       return 0;
//     }

//     return qty ~/ packageQty;
//   }

//   int get packagePcs {
//     return packageCount * packageQty;
//   }

//   int get retailQty {
//     if (packageQty <= 0) {
//       return qty;
//     }

//     return qty % packageQty;
//   }

//   double get retailPrice => currentRetailPrice;
//   double get packagePrice => currentPackagePrice;

//   int get packageSizeValue {
//     return packageSize ?? 0;
//   }

//   bool get hasMultiplePrices => priceLines.length > 1;
//   bool get hasPackagePrice => usePackagePricing && packageSizeValue > 0;

//   int get pricedQty =>
//       priceLines.fold<int>(0, (sum, line) => sum + line.pcsQuantity);

//   bool get isPricingComplete => pricedQty == qty;

//   double get subtotal {
//     return priceLines.fold<double>(0, (sum, line) => sum + line.subtotal);
//   }

//   double get sellingPrice {
//     if (qty <= 0) {
//       return 0;
//     }

//     return subtotal / qty;
//   }

//   bool get stockError => qty > product.stock;

//   CartItemModel copyWith({
//     ProductModel? product,
//     int? qty,
//     List<CartPriceLine>? priceLines,
//     bool? usePackagePricing,
//     double? retailUnitPrice,
//     double? packageUnitPrice,
//     int? packageSize,
//     bool clearRetailUnitPrice = false,
//     bool clearPackageUnitPrice = false,
//     bool clearPackageSize = false,
//   }) {
//     return CartItemModel(
//       product: product ?? this.product,
//       qty: qty ?? this.qty,
//       priceLines: priceLines ?? this.priceLines,
//       usePackagePricing: usePackagePricing ?? this.usePackagePricing,
//       retailUnitPrice: clearRetailUnitPrice
//           ? null
//           : retailUnitPrice ?? this.retailUnitPrice,
//       packageUnitPrice: clearPackageUnitPrice
//           ? null
//           : packageUnitPrice ?? this.packageUnitPrice,
//       packageSize: clearPackageSize ? null : packageSize ?? this.packageSize,
//     );
//   }
// }
