// // import 'package:bk_pos/features/cashier/data/product_cashier_repository.dart';
// import 'package:bk_pos/features/cashier/data/checkout_repository.dart';
// import 'package:bk_pos/model/cart_item_model.dart';
// import 'package:bk_pos/model/customer_model.dart';
// import 'package:bk_pos/model/delivery_model.dart';
// import 'package:bk_pos/model/payment_checkout_model.dart';
// import 'package:bk_pos/model/product_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final cashierRepositoryProvider = Provider((ref) => CashierRepository());

// class CashierState {
//   final bool isLoading;
//   final List<CartItemModel> cart;
//   final CustomerModel customer;
//   final DeliveryModel delivery;
//   final PaymentCheckoutModel payment;
//   final int pointsUsed;

//   final List<CustomerModel> customers;
//   final bool showCustomerResult;
//   final bool customerLoading;

//   CashierState({
//     this.isLoading = false,
//     this.cart = const [],
//     this.customer = const CustomerModel(),
//     this.delivery = const DeliveryModel(),
//     this.payment = const PaymentCheckoutModel(),
//     this.pointsUsed = 0,

//     this.customers = const [],
//     this.showCustomerResult = false,
//     this.customerLoading = false,
//   });

//   int get cartItemCount => cart.fold(0, (sum, e) => sum + e.qty);
//   double get subtotal => cart.fold(0, (sum, e) => sum + e.subtotal);
//   double get shipping =>
//       delivery.deliveryType == 'delivery' ? delivery.shippingCost : 0;
//   double get total => subtotal + shipping - pointsUsed;
//   bool get hasStockError => cart.any((e) => e.stockError);

//   CashierState copyWith({
//     bool? isLoading,
//     List<CartItemModel>? cart,
//     CustomerModel? customer,
//     DeliveryModel? delivery,
//     PaymentCheckoutModel? payment,
//     int? pointsUsed,

//     List<CustomerModel>? customers,
//     bool? showCustomerResult,

//     bool? customerLoading,
//   }) {
//     return CashierState(
//       isLoading: isLoading ?? this.isLoading,
//       cart: cart ?? this.cart,
//       customer: customer ?? this.customer,
//       delivery: delivery ?? this.delivery,
//       payment: payment ?? this.payment,
//       pointsUsed: pointsUsed ?? this.pointsUsed,

//       customers: customers ?? this.customers,
//       showCustomerResult: showCustomerResult ?? this.showCustomerResult,
//       customerLoading: customerLoading ?? this.customerLoading,
//     );
//   }
// }

// class CashierNotifier extends StateNotifier<CashierState> {
//   final CashierRepository repo;

//   CashierNotifier(this.repo) : super(CashierState());

//   bool get canCheckout {
//     if (state.cart.isEmpty) return false;

//     if (state.hasStockError) return false;

//     return true;
//   }

//   Future<void> searchCustomer(String keyword) async {
//     if (keyword.trim().isEmpty) {
//       state = state.copyWith(
//         customers: [],
//         showCustomerResult: false,
//         customerLoading: false,
//       );

//       return;
//     }

//     state = state.copyWith(customerLoading: true);

//     try {
//       final result = await repo.searchCustomer(keyword);

//       state = state.copyWith(
//         customers: result,
//         showCustomerResult: true,
//         customerLoading: false,
//       );
//     } catch (_) {
//       state = state.copyWith(
//         customerLoading: false,
//         customers: [],
//         showCustomerResult: false,
//       );
//     }
//   }

//   void selectCustomer(CustomerModel customer) {
//     state = state.copyWith(
//       customer: customer,
//       pointsUsed: 0,
//       customers: [],
//       showCustomerResult: false,
//     );
//   }

//   void hideCustomerResult() {
//     state = state.copyWith(customers: [], showCustomerResult: false);
//   }

//   void clearCustomer() {
//     state = state.copyWith(
//       customer: const CustomerModel(),
//       customers: [],
//       showCustomerResult: false,
//       pointsUsed: 0,
//     );
//   }

//   Map<String, dynamic> checkoutPayload() {
//     return {
//       "name": state.customer.name,
//       "phone": state.customer.phone,
//       "address": state.customer.address,

//       "delivery_type": state.delivery.deliveryType,
//       "shipping_cost": state.delivery.shippingCost,
//       "notes": state.delivery.notes,

//       "payment_status": state.payment.paymentStatus,
//       "payment_method": state.payment.paymentStatus == "unpaid"
//           ? null
//           : state.payment.paymentMethod,

//       "payment_amount": state.payment.paymentStatus == "paid"
//           ? state.total
//           : state.payment.paymentStatus == "partial"
//           ? state.payment.paymentAmount
//           : null,

//       "points_used": state.pointsUsed,

//       "subtotal": state.subtotal,
//       "total": state.total,

//       "items": state.cart
//           .map(
//             (e) => {"id": e.product.id, "qty": e.qty, "price": e.sellingPrice},
//           )
//           .toList(),
//     };
//   }

//   String? validateCheckout() {
//     if (state.cart.isEmpty) {
//       return "Cart kosong";
//     }

//     if (state.hasStockError) {
//       return "Masih ada stok yang kurang";
//     }

//     if (state.customer.name.trim().isEmpty) {
//       return "Nama customer wajib diisi";
//     }

//     if (state.customer.phone.trim().isEmpty) {
//       return "Nomor HP wajib diisi";
//     }

//     if (state.payment.paymentStatus == "partial") {
//       if (state.payment.paymentAmount <= 0) {
//         return "Nominal DP belum diisi";
//       }
//     }

//     return null;
//   }

//   Future<void> submit() async {
//     state = state.copyWith(isLoading: true);

//     try {
//       await repo.submitTransaction(checkoutPayload());
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   void addToCart(ProductModel product) {
//     final cart = [...state.cart];
//     final index = cart.indexWhere((e) => e.product.id == product.id);

//     if (index >= 0) {
//       cart[index].qty++;
//     } else {
//       cart.add(CartItemModel(product: product));
//     }

//     state = state.copyWith(cart: cart);
//   }

//   void updateQty(int productId, int qty) {
//     if (qty < 1) qty = 1;
//     final cart = [...state.cart];
//     final index = cart.indexWhere((e) => e.product.id == productId);

//     if (index == -1) return;

//     cart[index].qty = qty;
//     state = state.copyWith(cart: cart);
//   }

//   void updatePrice(int productId, double price) {
//     if (price < 0) price = 0;

//     final cart = [...state.cart];

//     final index = cart.indexWhere((e) => e.product.id == productId);

//     if (index == -1) return;

//     cart[index].customPrice = price;

//     state = state.copyWith(cart: cart);
//   }

//   void removeCart(int productId) {
//     state = state.copyWith(
//       cart: state.cart.where((e) => e.product.id != productId).toList(),
//     );
//   }

//   void updateCustomer({
//     int? id,
//     String? name,
//     String? phone,
//     String? address,
//     int? currentPoint,
//   }) {
//     state = state.copyWith(
//       customer: state.customer.copyWith(
//         id: id,
//         name: name,
//         phone: phone,
//         address: address,
//         currentPoint: currentPoint,
//       ),
//     );
//   }

//   void updatePointsUsed(int value) {
//     if (value < 0) value = 0;

//     if (value > state.customer.currentPoint) {
//       value = state.customer.currentPoint;
//     }

//     state = state.copyWith(pointsUsed: value);
//   }

//   void updateDeliveryType(String type) {
//     state = state.copyWith(
//       delivery: state.delivery.copyWith(
//         deliveryType: type,
//         shippingCost: type == 'pickup' ? 0 : state.delivery.shippingCost,
//       ),
//     );
//   }

//   void updateShipping(double value) {
//     if (value < 0) value = 0;

//     state = state.copyWith(
//       delivery: state.delivery.copyWith(shippingCost: value),
//     );
//   }

//   void updateNotes(String notes) {
//     state = state.copyWith(delivery: state.delivery.copyWith(notes: notes));
//   }

//   void updatePaymentStatus(String status) {
//     state = state.copyWith(
//       payment: state.payment.copyWith(paymentStatus: status),
//     );
//   }

//   void updatePaymentMethod(String method) {
//     state = state.copyWith(
//       payment: state.payment.copyWith(paymentMethod: method),
//     );
//   }

//   void updatePaymentAmount(double amount) {
//     if (amount < 0) amount = 0;

//     state = state.copyWith(
//       payment: state.payment.copyWith(paymentAmount: amount),
//     );
//   }

//   void clearCheckout() {
//     state = state.copyWith(
//       customer: const CustomerModel(),
//       delivery: const DeliveryModel(),
//       payment: const PaymentCheckoutModel(),
//       pointsUsed: 0,
//     );
//   }

//   void clearAll() {
//     state = CashierState();
//   }

//   void resetPrice(int productId) {
//     final cart = [...state.cart];
//     final index = cart.indexWhere((e) => e.product.id == productId);

//     if (index == -1) return;

//     cart[index].customPrice = null;
//     state = state.copyWith(cart: cart);
//   }
// }

// final cashierProvider = StateNotifierProvider<CashierNotifier, CashierState>((
//   ref,
// ) {
//   return CashierNotifier(ref.read(cashierRepositoryProvider));
// });
