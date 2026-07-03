class DeliveryModel {
  final String deliveryType;
  final double shippingCost;
  final String notes;

  const DeliveryModel({
    this.deliveryType = 'pickup',
    this.shippingCost = 0,
    this.notes = '',
  });

  DeliveryModel copyWith({
    String? deliveryType,
    double? shippingCost,
    String? notes,
  }) {
    return DeliveryModel(
      deliveryType: deliveryType ?? this.deliveryType,
      shippingCost: shippingCost ?? this.shippingCost,
      notes: notes ?? this.notes,
    );
  }
}