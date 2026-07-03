

import 'package:bk_pos/model/payment_model.dart';
import 'package:bk_pos/model/transaction_item_model.dart';

class TransactionDetailModel {
  final int id;

  final String invoiceNumber;

  final double subtotal;
  final double shippingCost;
  final double total;

  final String paymentStatus;

  final String? deliveryType;
  final String? driverName;
  final String? notes;
  final String? createdAt;

  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;

  final String? storeName;
  final String? storeAddress;

  final String? cashierName;

  final List<TransactionItemModel> items;
  final List<PaymentModel> payments;
  TransactionDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.paymentStatus,
    required this.deliveryType,
    required this.driverName,
    required this.notes,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.storeName,
    required this.storeAddress,
    required this.cashierName,
    required this.items,
    required this.payments,
  });

  factory TransactionDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionDetailModel(
      id: json['id'] ?? 0,

      invoiceNumber:
          json['invoice_number'] ?? '',

      subtotal:
          double.tryParse(
            json['subtotal'].toString(),
          ) ??
          0,

      shippingCost:
          double.tryParse(
            json['shipping_cost'].toString(),
          ) ??
          0,

      total:
          double.tryParse(
            json['total'].toString(),
          ) ??
          0,

      paymentStatus:
          json['payment_status'] ?? '',

      deliveryType: json['delivery_type'],
      driverName: json['driver_name'],
      notes: json['notes'],
      createdAt: json['created_at'],

      customerName:
          json['customer']?['name'],

      customerPhone:
          json['customer']?['phone'],

      customerAddress:
          json['customer']?['address'],

      storeName:
          json['store']?['name'],

      storeAddress:
          json['store']?['address'],

      cashierName:
          json['cashier']?['name'],

      items:
          (json['items'] as List? ?? [])
              .map(
                (e) =>
                    TransactionItemModel.fromJson(e),
              )
              .toList(),

      payments:
          (json['payments'] as List? ?? [])
              .map(
                (e) => PaymentModel.fromJson(e),
              )
              .toList(),
    );
  }
}