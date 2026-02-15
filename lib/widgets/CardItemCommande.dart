import 'package:atlas/models/ProductModel.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product, 
    this.quantity = 1
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductModel.fromMap(map['product'] as Map<String, dynamic>),
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}