class TransactionItemModel {
  final int id;

  final String productName;
  final String productCode;
  final String unit;

  final int quantity;

  final double basePrice;
  final double price;
  final double discount;
  final double subtotal;

  TransactionItemModel({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.unit,
    required this.quantity,
    required this.basePrice,
    required this.price,
    required this.discount,
    required this.subtotal,
  });

  factory TransactionItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionItemModel(
      id: json['id'] ?? 0,

      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      unit: json['unit'] ?? '',

      quantity:
          int.tryParse(
            json['quantity'].toString(),
          ) ??
          0,

      basePrice:
          double.tryParse(
            json['base_price'].toString(),
          ) ??
          0,

      price:
          double.tryParse(
            json['price'].toString(),
          ) ??
          0,

      discount:
          double.tryParse(
            json['discount'].toString(),
          ) ??
          0,

      subtotal:
          double.tryParse(
            json['subtotal'].toString(),
          ) ??
          0,
    );
  }
}
