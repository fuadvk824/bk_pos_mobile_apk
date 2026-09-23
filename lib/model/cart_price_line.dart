class CartPriceLine {
  final int quantity;
  final double price;
  final String label;
  final int unitSize;

  const CartPriceLine({
    required this.quantity,
    required this.price,
    this.label = 'Eceran',
    this.unitSize = 1,
  });

  /// Jumlah pcs sebenarnya yang terjual.
  int get pcsQuantity => quantity * unitSize;

  /// Nominal berdasarkan jumlah pcs.
  // double get subtotal => pcsQuantity * price;
  double get subtotal => quantity * price;

  CartPriceLine copyWith({
    int? quantity,
    double? price,
    String? label,
    int? unitSize,
  }) {
    return CartPriceLine(
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      label: label ?? this.label,
      unitSize: unitSize ?? this.unitSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qty': quantity,
      'price': price,
      'label': label,
      'unit_size': unitSize,
      'pcs_qty': pcsQuantity,
    };
  }
}
