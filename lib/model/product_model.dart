class ProductModel {
  final int id;
  final String productCode;
  final String name;
  final String unit;
  final String? image;
  final String? barcode;

  final int stock;
  final int sold;

  final double price;
  final double priceAll;
  final double discount;

  final String? category;

  ProductModel({
    required this.id,
    required this.productCode,
    required this.name,
    required this.unit,
    required this.image,
    required this.barcode,
    required this.stock,
    required this.sold,
    required this.price,
    required this.priceAll,
    required this.discount,
    required this.category,
  });

  double get finalPrice => price - discount;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productCode: json['product_code'],
      name: json['name'],
      unit: json['unit'],
      image: json['image'],
      barcode: json['barcode'],
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      sold: int.tryParse(json['sold'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      priceAll: double.tryParse(json['price_all'].toString()) ?? 0.0,
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      category: json['category'],
    );
  }
}
