import 'package:bk_pos/features/cashier/provider/wilayah_provider.dart';
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
  WilayahState get wilayah => ref.read(wilayahProvider);

  String get customerName => customer.customer.name;
  String get customerPhone => customer.customer.phone;  
  String get customerAddress => customer.customer.address;

  String get deliveryType => delivery.delivery.deliveryType;
  double get shipping {
    if (deliveryType == 'delivery') {
      return delivery.delivery.shippingCost;
    }

    return 0;
  }

  String get notes => delivery.delivery.notes;

  String get paymentStatus => payment.payment.paymentStatus;
  String get paymentMethod => payment.payment.paymentMethod;
  double get paymentAmount => payment.payment.paymentAmount;
  double get nego => payment.payment.nego;

  int get pointsUsed => customer.pointsUsed;
  double get subtotal => cart.subtotal;
  double get totalDiscount {
    return pointsUsed + nego;
  }

  double get total {
    return subtotal + shipping - totalDiscount;
  }

  bool get canCheckout {
    if (cart.items.isEmpty) {
      return false;
    }

    if (!cart.isBackorder && cart.hasStockError) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> checkoutPayload() {
    return {
      'transaction_type': cart.isBackorder ? 'backorder' : 'normal',

      'name': customerName,
      'phone': customerPhone,
      'address': customerAddress,

      'provinsi_id': wilayah.selectedProvinsi?.id,
      'kabupaten_id': wilayah.selectedKabupaten?.id,
      'kecamatan_id': wilayah.selectedKecamatan?.id,
      'desa_id': wilayah.selectedDesa?.id,

      'delivery_type': deliveryType,
      'shipping_cost': shipping,
      'notes': notes,

      'payment_status': paymentStatus,
      'payment_method': paymentStatus == 'unpaid' ? null : paymentMethod,
      'payment_amount': paymentStatus == 'paid'
          ? total
          : paymentStatus == 'partial'
          ? paymentAmount 
          : null,

      'points_used': pointsUsed,
      'nego': nego,

      'subtotal': subtotal,
      'total': total,

      'items': cart.items.map((item) {
        return {
          'id': item.product.id,
          'qty': item.qty,

          'price_lines': item.priceLines.map((line) {
            return {
              'qty': line.quantity,
              'price': line.price,
              'label': line.label,
              'unit_size': line.unitSize,
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  String? validateCheckout() {
    final currentCart = ref.read(cartProvider);
    final currentCustomer = ref.read(customerProvider);
    final currentDelivery = ref.read(deliveryProvider);
    final currentPayment = ref.read(paymentProvider);

    if (currentCart.items.isEmpty) {
      return 'Keranjang masih kosong';
    }

    if (!currentCart.isBackorder && currentCart.hasStockError) {
      return 'Stok produk tidak mencukupi';
    }

    for (final item in currentCart.items) {
      if (item.qty <= 0) {
        return 'Qty produk ${item.product.name} tidak valid';
      }

      if (item.priceLines.isEmpty) {
        return 'Harga produk ${item.product.name} belum diatur';
      }

      final pricedQty = item.pricedQty;

      if (pricedQty != item.qty) {
        return 'Rincian harga produk ${item.product.name} tidak lengkap';
      }

      for (final line in item.priceLines) {
        if (line.quantity <= 0) {
          return 'Qty harga produk ${item.product.name} tidak valid';
        }

        if (line.price <= 0) {
          return 'Harga produk ${item.product.name} harus lebih dari 0';
        }
      }

      if (item.subtotal <= 0) {
        return 'Harga produk ${item.product.name} tidak valid';
      }
    }

    final customerModel = currentCustomer.customer;

    if (customerModel.name.trim().isEmpty) {
      return 'Nama customer wajib diisi';
    }

    final currentDeliveryModel = currentDelivery.delivery;
    final currentShipping = currentDeliveryModel.deliveryType == 'delivery'
        ? currentDeliveryModel.shippingCost
        : 0.0;
    if (currentShipping < 0) {
      return 'Biaya pengiriman tidak valid';
    }

    final currentPaymentModel = currentPayment.payment;
    final currentSubtotal = currentCart.subtotal;
    final currentNego = currentPaymentModel.nego;
    final currentTotal =
        currentSubtotal +
        currentShipping -
        currentCustomer.pointsUsed -
        currentNego;
    if (currentTotal < 0) {
      return 'Total transaksi tidak boleh kurang dari 0';
    }

    if (currentNego < 0) {
      return 'Nominal nego tidak boleh kurang dari 0';
    }
    final maximumNego =
        currentSubtotal + currentShipping - currentCustomer.pointsUsed;
    if (currentNego > maximumNego) {
      return 'Nominal nego melebihi total transaksi';
    }

    if (currentPaymentModel.paymentStatus == 'partial') {
      if (currentPaymentModel.paymentAmount <= 0) {
        return 'Nominal pembayaran harus lebih dari 0';
      }

      if (currentPaymentModel.paymentAmount > currentTotal) {
        return 'Nominal pembayaran melebihi total transaksi';
      }
    }

    if (currentPaymentModel.paymentStatus == 'paid') {
      if (currentTotal <= 0) {
        return 'Total transaksi tidak valid';
      }
    }

    if (currentPaymentModel.paymentStatus != 'unpaid' &&
        currentPaymentModel.paymentMethod.trim().isEmpty) {
      return 'Metode pembayaran wajib dipilih';
    }

    if (currentCart.isBackorder) {
      for (final item in currentCart.items) {
        if (item.subtotal <= 0) {
          return 'Harga produk ${item.product.name} tidak valid';
        }
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

      return const CheckoutResult(success: true, message: 'Transaksi berhasil');
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
