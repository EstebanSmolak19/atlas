import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;
}

class Commandeprovider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _discount = 0.0;
  
  String? _userPlanId;
  bool _isUserPremium = false;

  List<CartItem> get items => _items;

  double get subTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  
  // Getter dynamique : Calcule les frais à chaque modification du panier
  double get deliveryFee {
    if (_isUserPremium) {
      if (_userPlanId == 'standard' || _userPlanId == 'premium') {
        return 0.0;
      }
      if (_userPlanId == 'basic' && subTotal > 30.00) {
        return 0.0;
      }
    }
    return 2.55;
  }
  
  double get total {
    if (subTotal == 0) return 0;
    return (subTotal * (1 - _discount)) + deliveryFee;
  }

  int get points => subTotal.toInt();

  void updateUser(UserModel? user) {
    _discount = 0.0;
    _isUserPremium = false;
    _userPlanId = null;

    if (user != null && user.premium) {
      _isUserPremium = true;
      _userPlanId = user.planId;

      if (user.planId == 'basic') _discount = 0.05;
      else if (user.planId == 'standard') _discount = 0.10;
      else if (user.planId == 'premium') _discount = 0.20;
    }
  }

  void addItem(ProductModel product, int quantity) {
    int index = _items.indexWhere((item) => item.product.name == product.name);

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int change) {
    int index = _items.indexOf(item);
    if (index == -1) return;

    int newQuantity = _items[index].quantity + change;

    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = newQuantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}