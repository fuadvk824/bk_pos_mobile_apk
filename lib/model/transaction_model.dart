class TransactionModel {
  final int id;
  final String invoiceNumber;

  final String? customerName;
  final String? customerAddress;
  final String? storeName;

  final double total;
  final double paidAmount;
  final double remainingAmount;

  final String paymentStatus;
  final String? deliveryType;
  final String? driverName;

  final String? createdAt;

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerAddress,
    required this.storeName,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.deliveryType,
    required this.driverName,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',

      customerName: json['customer_name'],
      customerAddress: json['customer_address'],
      storeName: json['store_name'],

      total:
          double.tryParse(json['total'].toString()) ?? 0,

      paidAmount:
          double.tryParse(
            json['paid_amount'].toString(),
          ) ??
          0,

      remainingAmount:
          double.tryParse(
            json['remaining_amount'].toString(),
          ) ??
          0,

      paymentStatus: json['payment_status'] ?? '',

      deliveryType: json['delivery_type'],
      driverName: json['driver_name'],

      createdAt: json['created_at'],
    );
  }
}