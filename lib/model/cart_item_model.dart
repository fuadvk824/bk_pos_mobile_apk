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

   
  int get packageSizeValue {
    return packageSize ?? product.conv2 ?? 0;
  }

  int get packageCount {
    final size = packageSizeValue;
    if (size <= 0) return 0;

    return qty ~/ size;
  }

  int get packagePcs {
    final size = packageSizeValue;
    if (size <= 0) return 0;

    return packageCount * size;
  }

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
 