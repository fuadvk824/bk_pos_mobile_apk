class ProductStoreModel {
  final int id;
  final String name;
  final int stock;
  final int? conv2;

  const ProductStoreModel({
    required this.id,
    required this.name,
    required this.stock,
    required this.conv2,
  });

  factory ProductStoreModel.fromJson(Map<String, dynamic> json) {
    return ProductStoreModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '-',
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      conv2: int.tryParse(json['conv2'].toString()) ?? 0,
    );
  }
}