import 'product_store_model.dart';

class ProductModel {
  final int id;
  final String productCode;
  final String name;
  final String unit;
  final String? unit2;
  final String? image;
  final String? barcode;
  final String? description;
  final int stock;
  final int? conv2;
  final int sold;
  final double price;
  final double discount;
  final String? category;

  final List<ProductStoreModel> stores;

  ProductModel({
    required this.id,
    required this.productCode,
    required this.name,
    required this.unit,
    required this.unit2,
    required this.image,
    required this.barcode,
    required this.description,
    required this.stock,
    required this.conv2,
    required this.sold,
    required this.price,
    required this.discount,
    required this.category,
    required this.stores,
  });

  double get finalPrice => price - discount;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final storesJson = json['stores'] as List? ?? [];

    return ProductModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      productCode: json['product_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      unit2: json['unit2']?.toString() ?? '',
      image: json['image']?.toString(),
      barcode: json['barcode']?.toString(),
      description: json['description']?.toString(),

      stock: int.tryParse(json['stock'].toString()) ?? 0,
      conv2: int.tryParse(json['conv2'].toString()) ?? 0,
      sold: int.tryParse(json['sold'].toString()) ?? 0,

      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,

      category: json['category']?.toString(),

      stores: storesJson
          .map((e) => ProductStoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
