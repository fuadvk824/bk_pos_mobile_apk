import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/cart_item_model.dart';
import '../../../model/cart_price_line.dart';
import '../../../model/product_model.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isBackorder;

  const CartState({this.items = const [], this.isBackorder = false});

  CartState copyWith({List<CartItemModel>? items, bool? isBackorder}) {
    return CartState(
      items: items ?? this.items,
      isBackorder: isBackorder ?? this.isBackorder,
    );
  }

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  bool get hasStockError {
    if (isBackorder) {
      return false;
    }

    return items.any((item) => item.stockError);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  bool add(ProductModel product, {int qty = 1, bool backorder = false}) {
    final normalizedQty = qty < 1 ? 1 : qty;

    if (state.items.isNotEmpty && state.isBackorder != backorder) {
      return false;
    }

    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final oldItem = items[index];
      final newQty = oldItem.qty + normalizedQty;
      final newPriceLines = _rebuildForQty(item: oldItem, newQty: newQty);

      items[index] = oldItem.copyWith(qty: newQty, priceLines: newPriceLines);
    } else {
      items.add(
        CartItemModel(
          product: product,
          qty: normalizedQty,
          priceLines: [
            CartPriceLine(
              quantity: normalizedQty,
              price: _defaultRetailPrice(product),
              label: 'Eceran',
            ),
          ],
        ),
      );
    }

    state = state.copyWith(items: items, isBackorder: backorder);

    return true;
  }

  void remove(int productId) {
    final items = state.items
        .where((item) => item.product.id != productId)
        .toList();

    state = state.copyWith(
      items: items,
      isBackorder: items.isEmpty ? false : state.isBackorder,
    );
  }

  void updateQty(int productId, int qty) {
    if (qty < 1) {
      return;
    }

    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) {
      return;
    }

    final oldItem = items[index];
    final newPriceLines = _rebuildForQty(item: oldItem, newQty: qty);
    items[index] = oldItem.copyWith(qty: qty, priceLines: newPriceLines);
    state = state.copyWith(items: items);
  }

  void setUsePackagePricing(int productId, bool enabled) {
    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index < 0) return;

    final item = items[index];

     
    if (!enabled) {
      items[index] = item.copyWith(
        usePackagePricing: false,
        priceLines: [
          CartPriceLine(
            quantity: item.qty,
            price: item.retailPrice,
            label: 'Eceran',
            unitSize: 1,
          ),
        ],
        clearPackageUnitPrice: true,
      );

      state = state.copyWith(items: items);
      return;
    }

    final packageSize = item.packageSizeValue;

    // Kalau produk BELUM punya conv2,
    // tetap boleh mengaktifkan bundle pricing.
    //
    // Kasir nanti akan mengisi "Isi 1 Bundle".
    if (packageSize <= 0) {
      items[index] = item.copyWith(
        usePackagePricing: true,
        priceLines: [
          CartPriceLine(
            quantity: item.qty,
            price: item.retailPrice,
            label: 'Eceran',
            unitSize: 1,
          ),
        ],
      );

      state = state.copyWith(items: items);
      return;
    }

    // =========================
    // SUDAH ADA conv2
    // =========================
    final maxPackageCount = item.qty ~/ packageSize;

    final defaultPackageCount = maxPackageCount;

    final lines = _buildPackagePriceLines(
      item: item,
      packageCount: defaultPackageCount,
      packageSize: packageSize,
      packagePrice: item.packagePrice,
    );

    items[index] = item.copyWith(
      usePackagePricing: true,
      packageSize: packageSize,
      priceLines: lines,
    );

    state = state.copyWith(items: items);
  }

  void setPackageQty(int productId, int packageCount) {
    if (packageCount < 0) return;

    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index < 0) return;

    final oldItem = items[index];

    final packageSize = oldItem.packageSizeValue;

    if (packageSize <= 0) return;

    // qty = total pcs
    // packageSize = pcs per pack
    // hasil = maksimal jumlah pack
    final maxPackageCount = oldItem.qty ~/ packageSize;

    final actualPackageCount = packageCount.clamp(0, maxPackageCount).toInt();

    final lines = _buildPackagePriceLines(
      item: oldItem,
      packageCount: actualPackageCount,
      packageSize: packageSize,
      packagePrice: oldItem.packagePrice,
    );

    items[index] = oldItem.copyWith(
      usePackagePricing: true,
      packageSize: packageSize,
      priceLines: lines,
    );

    state = state.copyWith(items: items);
  }

  void setPackageSize(int productId, int packageSize) {
    if (packageSize < 1) return;

    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index < 0) return;

    final oldItem = items[index];

    final maxPackageCount = oldItem.qty ~/ packageSize;

    final actualPackageCount = oldItem.packageCount > 0
        ? oldItem.packageCount.clamp(0, maxPackageCount).toInt()
        : maxPackageCount;

    final lines = _buildPackagePriceLines(
      item: oldItem,
      packageCount: actualPackageCount,
      packageSize: packageSize,
      packagePrice: oldItem.packagePrice,
    );

    items[index] = oldItem.copyWith(
      usePackagePricing: true,
      packageSize: packageSize,
      priceLines: lines,
    );

    state = state.copyWith(items: items);
  }

  void setPackagePrice(int productId, double price) {
    if (price < 0) return;

    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index < 0) return;

    final item = items[index];

    final lines = item.priceLines.map((line) {
      if (line.label.toLowerCase() == 'dus') {
        return line.copyWith(price: price);
      }

      return line;
    }).toList();

    items[index] = item.copyWith(packageUnitPrice: price, priceLines: lines);

    state = state.copyWith(items: items);
  }

  void setRetailPrice(int productId, double price) {
    if (price < 0) return;

    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index < 0) return;

    final item = items[index];

    final lines = item.priceLines.map((line) {
      if (line.label.toLowerCase() == 'eceran') {
        return line.copyWith(price: price);
      }

      return line;
    }).toList();

    items[index] = item.copyWith(retailUnitPrice: price, priceLines: lines);

    state = state.copyWith(items: items);
  }

  void resetPrice(int productId) {
    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index < 0) {
      return;
    }

    final item = items[index];

    final retailPrice = _defaultRetailPrice(item.product);

   
    if (!item.usePackagePricing) {
      items[index] = item.copyWith(
        retailUnitPrice: retailPrice,
        priceLines: [
          CartPriceLine(
            quantity: item.qty,
            price: retailPrice,
            label: 'Eceran',
            unitSize: 1,
          ),
        ],
      );

      state = state.copyWith(items: items);
      return;
    }

    // ==========================================================
    // PACKAGE / BUNDLE
    // ==========================================================
    final packageSize = item.packageSizeValue;

    if (packageSize <= 0) {
      items[index] = item.copyWith(
        retailUnitPrice: retailPrice,
        priceLines: [
          CartPriceLine(
            quantity: item.qty,
            price: retailPrice,
            label: 'Eceran',
            unitSize: 1,
          ),
        ],
      );

      state = state.copyWith(items: items);
      return;
    }

    final oldPackageLine = item.priceLines.cast<CartPriceLine?>().firstWhere(
      (line) => line?.label.toLowerCase() == 'dus',
      orElse: () => null,
    );

    final packageCount = oldPackageLine?.quantity ?? 0;

    final maxPackageCount = item.qty ~/ packageSize;

    final actualPackageCount = packageCount.clamp(0, maxPackageCount);

    final packagePrice = item.packagePrice;

    final lines = _buildPackagePriceLines(
      item: item,
      packageCount: actualPackageCount,
      packageSize: packageSize,
      packagePrice: packagePrice,
    );

    items[index] = item.copyWith(
      retailUnitPrice: retailPrice,
      priceLines: lines,
    );

    state = state.copyWith(items: items);
  }

  void resetPackagePricing(int productId) {
    setUsePackagePricing(productId, false);
  }

  void clear() {
    state = const CartState();
  }

  double _defaultRetailPrice(ProductModel product) {
    if (product.discount > 0) {
      return product.finalPrice;
    }

    return product.price;
  }

  List<CartPriceLine> _rebuildForQty({
    required CartItemModel item,
    required int newQty,
  }) {
    if (!item.usePackagePricing) {
      return [
        CartPriceLine(
          quantity: newQty,
          price: item.retailPrice,
          label: 'Eceran',
          unitSize: 1,
        ),
      ];
    }

    final packageSize = item.packageSizeValue;

    if (packageSize <= 0) {
      return [
        CartPriceLine(
          quantity: newQty,
          price: item.retailPrice,
          label: 'Eceran',
          unitSize: 1,
        ),
      ];
    }

    final oldPackageLine = item.priceLines.cast<CartPriceLine?>().firstWhere(
      (line) => line?.label.toLowerCase() == 'dus',
      orElse: () => null,
    );

    final packageCount = oldPackageLine?.quantity ?? 0;
    final maxPackageCount = newQty ~/ packageSize;

    final actualPackageCount = packageCount.clamp(0, maxPackageCount).toInt();

    return _buildPackagePriceLines(
      item: item.copyWith(qty: newQty),
      packageCount: actualPackageCount,
      packageSize: packageSize,
      packagePrice: item.packagePrice,
    );
  }

  List<CartPriceLine> _buildPackagePriceLines({
    required CartItemModel item,
    required int packageCount,
    required int packageSize,
    required double packagePrice,
  }) {
    final lines = <CartPriceLine>[];

    // Jumlah pcs yang masuk ke bundle
    final packagePcs = packageCount * packageSize;

    // Sisa pcs yang dijual satuan
    final retailQty = item.qty - packagePcs;

    if (packageCount > 0) {
      lines.add(
        CartPriceLine(
          quantity: packageCount,
          price: packagePrice,
          label: 'Dus',
          unitSize: packageSize,
        ),
      );
    }

    if (retailQty > 0) {
      lines.add(
        CartPriceLine(
          quantity: retailQty,
          price: item.retailPrice,
          label: 'Eceran',
          unitSize: 1,
        ),
      );
    }

    if (lines.isEmpty) {
      lines.add(
        CartPriceLine(
          quantity: item.qty,
          price: item.retailPrice,
          label: 'Eceran',
          unitSize: 1,
        ),
      );
    }

    return lines;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
  