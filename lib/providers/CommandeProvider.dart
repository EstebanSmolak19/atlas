import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  final bool isReward; // Indique si c'est un article de récompense
  final int? rewardCost; // Coût en points si c'est une récompense
  final int? rewardTier; // Palier de la récompense (pour limiter à 1 par palier)

  CartItem({
    required this.product,
    required this.quantity,
    this.isReward = false,
    this.rewardCost,
    this.rewardTier,
  });

  double get totalPrice {
    // Les articles de récompense sont gratuits
    if (isReward) return 0.0;
    return product.price * quantity;
  }
}

class Commandeprovider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _discount = 0.0;
  String? _userPlanId;
  bool _isUserPremium = false;
  int _userCurrentPoints = 0; // Points actuels de l'utilisateur

  List<CartItem> get items => _items;

  double get subTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  // Points utilisés par les récompenses dans le panier
  int get usedRewardPoints {
    return _items.where((item) => item.isReward).fold(0, (sum, item) => sum + (item.rewardCost ?? 0));
  }

  // Points disponibles après déduction des récompenses
  int get availablePoints => _userCurrentPoints - usedRewardPoints;

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

  // Points gagnés par la commande (ne compte que les articles payants)
  int get points => subTotal.toInt();

  void updateUser(UserModel? user) {
    _discount = 0.0;
    _isUserPremium = false;
    _userPlanId = null;
    _userCurrentPoints = 0;

    if (user != null) {
      _userCurrentPoints = user.points;

      if (user.premium) {
        _isUserPremium = true;
        _userPlanId = user.planId;

        if (user.planId == 'basic') _discount = 0.05;
        else if (user.planId == 'standard') _discount = 0.10;
        else if (user.planId == 'premium') _discount = 0.20;
      }
    }
    notifyListeners();
  }

  // Vérifie si l'utilisateur a déjà UNE récompense (peu importe le palier) dans le panier
  bool hasAnyReward() {
    return _items.any((item) => item.isReward);
  }

  // Vérifie si l'utilisateur a assez de points pour une récompense
  bool canAffordReward(int cost) {
    return availablePoints >= cost;
  }

  void addItem(ProductModel product, int quantity, {bool isReward = false, int? rewardCost, int? rewardTier}) {
    // Si c'est une récompense, on vérifie les contraintes
    if (isReward) {
      // NOUVEAU: Vérifier si déjà UNE récompense (peu importe le palier)
      if (hasAnyReward()) {
        throw Exception("Vous ne pouvez avoir qu'une seule récompense dans votre panier");
      }

      // Vérifier si assez de points
      if (rewardCost != null && !canAffordReward(rewardCost)) {
        throw Exception("Points insuffisants");
      }
    }

    int index = _items.indexWhere((item) =>
      item.product.id == product.id &&
      item.isReward == isReward
    );

    if (index != -1) {
      // Pour les récompenses, on ne peut pas augmenter la quantité
      if (isReward) {
        throw Exception("Vous ne pouvez ajouter qu'une seule fois cet article de récompense");
      }
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        isReward: isReward,
        rewardCost: rewardCost,
        rewardTier: rewardTier,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int change) {
    int index = _items.indexOf(item);
    if (index == -1) return;

    // Les récompenses ne peuvent pas avoir leur quantité modifiée
    if (item.isReward && change != -1) {
      return;
    }

    int newQuantity = _items[index].quantity + change;

    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = newQuantity;
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Méthode pour calculer les points à débiter lors du paiement
  // (points utilisés pour les récompenses)
  int getPointsToDeduct() {
    return usedRewardPoints;
  }
}