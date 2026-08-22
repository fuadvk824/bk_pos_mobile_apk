import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/cart_item_model.dart';
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

  // void add(ProductModel product, {int qty = 1}) {
  //   final items = [...state.items];
  //   final index = items.indexWhere((e) => e.product.id == product.id);

  //   if (index == -1) {
  //     items.add(CartItemModel(product: product, qty: qty));
  //   } else {
  //     final currentQty = items[index].qty + qty;

  //     items[index] = items[index].copyWith(
  //       qty: currentQty > product.stock ? product.stock : currentQty,
  //     );
  //   }

  //   state = state.copyWith(items: items);
  // }
  void add(ProductModel product, {int qty = 1, bool backorder = false}) {
    if (qty < 1) {
      qty = 1;
    }

    // Jangan mencampur produk normal dan backorder
    if (state.items.isNotEmpty && state.isBackorder != backorder) {
      throw Exception(
        'Tidak dapat mencampur produk normal dan backorder dalam satu transaksi.',
      );
    }

    final index = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      final current = state.items[index];

      final updated = current.copyWith(qty: current.qty + qty);

      final items = [...state.items];
      items[index] = updated;

      state = state.copyWith(items: items, isBackorder: backorder);

      return;
    }

    state = state.copyWith(
      items: [
        ...state.items,
        CartItemModel(product: product, qty: qty),
      ],
      isBackorder: backorder,
    );
  }

  void remove(int productId) {
    state = state.copyWith(
      items: state.items.where((e) => e.product.id != productId).toList(),
    );
  }

  void updateQty(int productId, int qty) {
    if (qty < 1) qty = 1;

    final items = [...state.items];
    final index = items.indexWhere((e) => e.product.id == productId);
    if (index == -1) return;

    items[index] = items[index].copyWith(qty: qty);
    state = state.copyWith(items: items);
  }

  // void updatePrice(int productId, double value) {
  //   if (value < 0) value = 0;

  //   final items = [...state.items];
  //   final index = items.indexWhere((e) => e.product.id == productId);

  //   if (index == -1) return;

  //   items[index] = items[index].copyWith(customPrice: value);
  //   state = state.copyWith(items: items);
  // }

  void updatePrice(int productId, double price) {
    final items = [...state.items];

    final index = items.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    items[index] = items[index].copyWith(customPrice: price);

    state = state.copyWith(items: items);
  }

  void resetPrice(int productId) {
    final items = [...state.items];
    final index = items.indexWhere((e) => e.product.id == productId);

    if (index == -1) return;

    items[index] = items[index].copyWith(resetCustomPrice: true);
    state = state.copyWith(items: items);
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../model/cart_item_model.dart';
// import '../../../model/product_model.dart';

// class CartState {
//   final List<CartItemModel> items;
//   const CartState({this.items = const []});

//   CartState copyWith({List<CartItemModel>? items}) {
//     return CartState(items: items ?? this.items);
//   }

//   int get itemCount => items.fold(0, (sum, e) => sum + e.qty);
//   double get subtotal => items.fold(0, (sum, e) => sum + e.subtotal);
//   bool get hasStockError => items.any((e) => e.stockError);
// }

// class CartNotifier extends StateNotifier<CartState> {
//   CartNotifier() : super(const CartState());

//   void add(ProductModel product, {int qty = 1}) {
//     final items = [...state.items];
//     final index = items.indexWhere((e) => e.product.id == product.id);

//     if (index == -1) {
//       items.add(CartItemModel(product: product, qty: qty));
//     } else {
//       final currentQty = items[index].qty + qty;

//       items[index] = items[index].copyWith(
//         qty: currentQty > product.stock ? product.stock : currentQty,
//       );
//     }

//     state = state.copyWith(items: items);
//   }

//   void remove(int productId) {
//     state = state.copyWith(
//       items: state.items.where((e) => e.product.id != productId).toList(),
//     );
//   }

//   void updateQty(int productId, int qty) {
//     if (qty < 1) qty = 1;

//     final items = [...state.items];
//     final index = items.indexWhere((e) => e.product.id == productId);
//     if (index == -1) return;

//     items[index] = items[index].copyWith(qty: qty);
//     state = state.copyWith(items: items);
//   }

//   void updatePrice(int productId, double value) {
//     if (value < 0) value = 0;

//     final items = [...state.items];
//     final index = items.indexWhere((e) => e.product.id == productId);

//     if (index == -1) return;

//     items[index] = items[index].copyWith(customPrice: value);
//     state = state.copyWith(items: items);
//   }

//   void resetPrice(int productId) {
//     final items = [...state.items];
//     final index = items.indexWhere((e) => e.product.id == productId);

//     if (index == -1) return;

//     items[index] = items[index].copyWith(resetCustomPrice: true);
//     state = state.copyWith(items: items);
//   }

//   void clear() {
//     state = const CartState();
//   }
// }

// final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
//   (ref) => CartNotifier(),
// );
