class TransactionModel {
  final int id;
  final String invoiceNumber;
  final String paymentStatus;
  final String? createdAt;
  final String? deliveryType;
  final String? driverName;

  final String? customerName;

  final double total;
  final double paidAmount;
  final double remainingAmount;

  TransactionModel({
    required this.id,
    required this.invoiceNumber,
    required this.paymentStatus,
    required this.createdAt,

    required this.deliveryType,
    required this.driverName,
    required this.customerName,

    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['created_at'],
      
      deliveryType: json['delivery_type'],
      driverName: json['driver_name'],
      customerName: json['customer_name'],

      total: double.tryParse(json['total'].toString()) ?? 0,
      paidAmount: double.tryParse(json['paid_amount'].toString()) ?? 0,
      remainingAmount:
          double.tryParse(json['remaining_amount'].toString()) ?? 0,
    );
  }
}
