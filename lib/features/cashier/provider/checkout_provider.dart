import 'package:bk_pos/model/checkout_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/checkout_repository.dart';

import 'cart_provider.dart';
import 'customer_provider.dart';
import 'delivery_provider.dart';
import 'payment_provider.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(),
);

class CheckoutState {
  final bool isLoading;

  const CheckoutState({this.isLoading = false});

  CheckoutState copyWith({bool? isLoading}) {
    return CheckoutState(isLoading: isLoading ?? this.isLoading);
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;
  final CheckoutRepository repo;

  CheckoutNotifier(this.ref, this.repo) : super(const CheckoutState());

  CartState get cart => ref.read(cartProvider);
  CustomerState get customer => ref.read(customerProvider);
  DeliveryState get delivery => ref.read(deliveryProvider);
  PaymentState get payment => ref.read(paymentProvider);

  double get subtotal => cart.subtotal;
  double get shipping {
    if (delivery.delivery.deliveryType == "delivery") {
      return delivery.delivery.shippingCost;
    }

    return 0;
  }

  int get pointsUsed => customer.pointsUsed;
  double get total => subtotal + shipping - pointsUsed;

  bool get canCheckout {
    if (cart.items.isEmpty) {
      return false;
    }

    if (cart.hasStockError) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> checkoutPayload() {
    final c = customer.customer;
    final d = delivery.delivery;
    final p = payment.payment;

    return {
      "transaction_type": cart.isBackorder ? "backorder" : "normal",
      "name": c.name,
      "phone": c.phone,
      "address": c.address,

      "delivery_type": d.deliveryType,
      "shipping_cost": shipping,
      "notes": d.notes,

      "payment_status": p.paymentStatus,

      "payment_method": p.paymentStatus == "unpaid" ? null : p.paymentMethod,

      "payment_amount": p.paymentStatus == "paid"
          ? total
          : p.paymentStatus == "partial"
          ? p.paymentAmount
          : null,

      "points_used": pointsUsed,

      "subtotal": subtotal,
      "total": total,

      "items": cart.items.map((e) {
        return {"id": e.product.id, "qty": e.qty, "price": e.sellingPrice};
      }).toList(),
    };
  }

  String? validateCheckout() {
    if (cart.items.isEmpty) {
      return "Cart kosong";
    }

    if (cart.hasStockError && !cart.isBackorder) {
      return "Masih ada stok yang kurang";
    }

    if (customer.customer.name.trim().isEmpty) {
      return "Nama customer wajib diisi";
    }

    if (customer.customer.phone.trim().isEmpty) {
      return "Nomor HP wajib diisi";
    }

    if (cart.isBackorder) {
      for (final item in cart.items) {
        if (item.sellingPrice <= 0) {
          return "Harga ${item.product.name} belum diisi";
        }
      }
    }

    final paymentState = payment.payment;

    if (paymentState.paymentStatus == "partial") {
      if (paymentState.paymentAmount <= 0) {
        return "Nominal DP belum diisi";
      }

      if (paymentState.paymentAmount > total) {
        return "Nominal DP melebihi total transaksi";
      }
    }

    return null;
  }

  Future<CheckoutResult> processCheckout() async {
    final error = validateCheckout();

    if (error != null) {
      return CheckoutResult(success: false, message: error);
    }

    state = state.copyWith(isLoading: true);

    try {
      await repo.submitTransaction(checkoutPayload());
      clearAll();

      return const CheckoutResult(success: true, message: "Transaksi berhasil");
    } catch (e) {
      return CheckoutResult(success: false, message: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearAll() {
    state = const CheckoutState();

    ref.read(cartProvider.notifier).clear();
    ref.read(customerProvider.notifier).clearCustomer();
    ref.read(deliveryProvider.notifier).clear();
    ref.read(paymentProvider.notifier).clear();
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    return CheckoutNotifier(ref, ref.read(checkoutRepositoryProvider));
  },
);


// import 'package:bk_pos/model/checkout_result_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../data/checkout_repository.dart';

// import 'cart_provider.dart';
// import 'customer_provider.dart';
// import 'delivery_provider.dart';
// import 'payment_provider.dart';

// final checkoutRepositoryProvider = Provider<CheckoutRepository>(
//   (ref) => CheckoutRepository(),
// );

// class CheckoutState {
//   final bool isLoading;

//   const CheckoutState({this.isLoading = false});

//   CheckoutState copyWith({bool? isLoading}) {
//     return CheckoutState(isLoading: isLoading ?? this.isLoading);
//   }
// }

// class CheckoutNotifier extends StateNotifier<CheckoutState> {
//   final Ref ref;
//   final CheckoutRepository repo;

//   CheckoutNotifier(this.ref, this.repo) : super(const CheckoutState());

//   CartState get cart => ref.read(cartProvider);
//   CustomerState get customer => ref.read(customerProvider);
//   DeliveryState get delivery => ref.read(deliveryProvider);
//   PaymentState get payment => ref.read(paymentProvider);

//   double get subtotal => cart.subtotal;
//   double get shipping {
//     if (delivery.delivery.deliveryType == "delivery") {
//       return delivery.delivery.shippingCost;
//     }

//     return 0;
//   }

//   int get pointsUsed => customer.pointsUsed;
//   double get total => subtotal + shipping - pointsUsed;

//   bool get canCheckout {
//     if (cart.items.isEmpty) {
//       return false;
//     }

//     if (cart.hasStockError) {
//       return false;
//     }

//     return true;
//   }

//   Map<String, dynamic> checkoutPayload() {
//     final c = customer.customer;
//     final d = delivery.delivery;
//     final p = payment.payment;

//     return {
//       "name": c.name,
//       "phone": c.phone,
//       "address": c.address,

//       "delivery_type": d.deliveryType,
//       "shipping_cost": shipping,
//       "notes": d.notes,

//       "payment_status": p.paymentStatus,

//       "payment_method": p.paymentStatus == "unpaid" ? null : p.paymentMethod,

//       "payment_amount": p.paymentStatus == "paid"
//           ? total
//           : p.paymentStatus == "partial"
//           ? p.paymentAmount
//           : null,

//       "points_used": pointsUsed,

//       "subtotal": subtotal,
//       "total": total,

//       "items": cart.items.map((e) {
//         return {"id": e.product.id, "qty": e.qty, "price": e.sellingPrice};
//       }).toList(),
//     };
//   }

//   String? validateCheckout() {
//     if (cart.items.isEmpty) {
//       return "Cart kosong";
//     }

//     if (cart.hasStockError) {
//       return "Masih ada stok yang kurang";
//     }

//     if (customer.customer.name.trim().isEmpty) {
//       return "Nama customer wajib diisi";
//     }

//     if (customer.customer.phone.trim().isEmpty) {
//       return "Nomor HP wajib diisi";
//     }

//     final paymentState = payment.payment;

//     if (paymentState.paymentStatus == "partial") {
//       if (paymentState.paymentAmount <= 0) {
//         return "Nominal DP belum diisi";
//       }

//       if (paymentState.paymentAmount > total) {
//         return "Nominal DP melebihi total transaksi";
//       }
//     }

//     return null;
//   }

//   Future<CheckoutResult> processCheckout() async {
//     final error = validateCheckout();

//     if (error != null) {
//       return CheckoutResult(success: false, message: error);
//     }

//     state = state.copyWith(isLoading: true);

//     try {
//       await repo.submitTransaction(checkoutPayload());
//       clearAll();

//       return const CheckoutResult(success: true, message: "Transaksi berhasil");
//     } catch (e) {
//       return CheckoutResult(success: false, message: e.toString());
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   void clearAll() {
//     state = const CheckoutState();

//     ref.read(cartProvider.notifier).clear();
//     ref.read(customerProvider.notifier).clearCustomer();
//     ref.read(deliveryProvider.notifier).clear();
//     ref.read(paymentProvider.notifier).clear();
//   }
// }

// final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
//   (ref) {
//     return CheckoutNotifier(ref, ref.read(checkoutRepositoryProvider));
//   },
// );
