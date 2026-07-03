class CustomerModel {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final int currentPoint;

  const CustomerModel({
    this.id,
    this.name = '',
    this.phone = '',
    this.address = '',
    this.currentPoint = 0,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      currentPoint: json['current_point'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "address": address,
      "current_point": currentPoint,
    };
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    int? currentPoint,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      currentPoint: currentPoint ?? this.currentPoint,
    );
  }
}