import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/widgets/CardItemCommande.dart';
import 'package:flutter/foundation.dart';

class Commandeprovider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get subTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => 2.55; // Frais fixes 
  double get total => subTotal > 0 ? subTotal + deliveryFee : 0;

  //Le nombre de point est identique au prix avant réduction.
  int get points => subTotal.toInt();

  //Ajouter un item au panier.
  void addItem(ProductModel product, int quantity) {
    int index = _items.indexWhere((item) => item.product.name == product.name);

    if(index != -1) {
      _items[index].quantity += quantity;
    }
    else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  //Changer la quantité d'un item.
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

  //Mert à jour le nombre de points gagné en fonction de la commande.
  void pointsEarn(ProductModel product, int quantity) {
    int index = _items.indexWhere((item) => item.product.name == product.name);
    if(index != -1) {
    }
  }

  // Vider le panier (après paiement)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}