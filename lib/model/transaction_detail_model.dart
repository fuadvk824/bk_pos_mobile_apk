import 'package:bk_pos/model/payment_model.dart';
import 'package:bk_pos/model/transaction_item_model.dart';

class TransactionDetailModel {
  final int id;
  final String invoiceNumber;
  final String paymentStatus;
  final String? createdAt;
  final String? deliveryType;
  final String? driverName;
  final String? notes;
  final String? cashier;
  final String? printedBy;

  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  
  final String? storeName;
  final String? storeView;
  final String? storeAddress;
  final String? storeEmail;
  final String? storePhone;

  final String? companyName;
  final String? companyAddress;

  final List<TransactionItemModel> items;
  final List<PaymentModel> payments;

  final double subtotal;
  final double shippingCost;
  final double pointsUsed;
  final double nego;
  final double total;
  final double remainingAmount;

  TransactionDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.paymentStatus,
    required this.createdAt,
    required this.deliveryType,
    required this.driverName,
    required this.notes,
    required this.cashier,
    required this.printedBy,

    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
   
    required this.storeName,
    required this.storeView,
    required this.storeAddress,
    required this.storeEmail,
    required this.storePhone,

    required this.companyName,
    required this.companyAddress,

    required this.items,
    required this.payments,

    required this.subtotal,
    required this.shippingCost,
    required this.pointsUsed,
    required this.nego,
    required this.total,
    required this.remainingAmount,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['created_at'],
      deliveryType: json['delivery_type'],
      driverName: json['driver_name'],
      notes: json['notes'],
      cashier: json['cashier'],
      printedBy: json['printed_by'],

      customerName: json['customer']?['name'],
      customerPhone: json['customer']?['phone'],
      customerAddress: json['customer']?['address'],
      
      storeName: json['store']?['name'],
      storeView: json['store']?['name_view'],
      storeAddress: json['store']?['address'],
      storeEmail: json['store']?['email'],
      storePhone: json['store']?['phone'],


      companyName: json['company']?['name'],
      companyAddress: json['company']?['address'],

      items: (json['items'] as List? ?? [])
          .map((e) => TransactionItemModel.fromJson(e))
          .toList(),

      payments: (json['payments'] as List? ?? [])
          .map((e) => PaymentModel.fromJson(e))
          .toList(),

      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      shippingCost: double.tryParse(json['shipping_cost'].toString()) ?? 0,
      pointsUsed: double.tryParse(json['points_used'].toString()) ?? 0,
      nego: double.tryParse(json['nego'].toString()) ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
      remainingAmount:
          double.tryParse(json['remaining_amount'].toString()) ?? 0,
    );
  }
}
