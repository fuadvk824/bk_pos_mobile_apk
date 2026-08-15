import 'package:bk_pos/model/product_model.dart';

class TransactionCartItem {
  final ProductModel product;
  int quantity;

  TransactionCartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.finalPrice * quantity;
}