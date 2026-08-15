
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/cart_item_model.dart';
import '../../../model/product_model.dart';

class CartState {
  final List<CartItemModel> items;
  const CartState({this.items = const []});

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }

  int get itemCount => items.fold(0, (sum, e) => sum + e.qty);
  double get subtotal => items.fold(0, (sum, e) => sum + e.subtotal);
  bool get hasStockError => items.any((e) => e.stockError);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void add(ProductModel product, {int qty = 1}) {
    final items = [...state.items];
    final index = items.indexWhere((e) => e.product.id == product.id);

    if (index == -1) {
      items.add(CartItemModel(product: product, qty: qty));
    } else {
      final currentQty = items[index].qty + qty;

      items[index] = items[index].copyWith(
        qty: currentQty > product.stock ? product.stock : currentQty,
      );
    }

    state = state.copyWith(items: items);
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

  void updatePrice(int productId, double value) {
    if (value < 0) value = 0;

    final items = [...state.items];
    final index = items.indexWhere((e) => e.product.id == productId);

    if (index == -1) return;

    items[index] = items[index].copyWith(customPrice: value);
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
