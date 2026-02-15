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
      if (_userPlanId == 'explorer' || _userPlanId == 'elite') {
        return 0.0;
      }
      if (_userPlanId == 'nomad' && subTotal > 30.00) {
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
    print("[LOG] Synchronisation du panier avec l'utilisateur: ${user?.pseudo ?? 'Anonyme'}");
    _discount = 0.0;
    _isUserPremium = false;
    _userPlanId = null;
    _userCurrentPoints = 0;

    if (user != null) {
      _userCurrentPoints = user.points;

      if (user.premium) {
        _isUserPremium = true;
        _userPlanId = user.planId;

        if (user.planId == 'nomad') _discount = 0.05;
        else if (user.planId == 'explorer') _discount = 0.10;
        else if (user.planId == 'elite') _discount = 0.20;

        print("[LOG] Avantages Premium appliqués: $_userPlanId (Remise: ${(_discount * 100).toInt()}%)");
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
    if (isReward) {
      print("[LOG] Tentative d'ajout d'une récompense: ${product.name} (Coût: $rewardCost pts)");
      if (hasAnyReward()) {
        print("[LOG] Échec ajout récompense: Une récompense est déjà présente");
        throw Exception("Vous ne pouvez avoir qu'une seule récompense dans votre panier");
      }

      if (rewardCost != null && !canAffordReward(rewardCost)) {
        print("[LOG] Échec ajout récompense: Points insuffisants ($availablePoints disponibles)");
        throw Exception("Points insuffisants");
      }
    } else {
      print("[LOG] Ajout au panier: ${product.name} x$quantity");
    }

    int index = _items.indexWhere((item) =>
      item.product.id == product.id &&
      item.isReward == isReward
    );

    if (index != -1) {
      if (isReward) {
        print("[LOG] Échec ajout récompense: Article déjà présent");
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
    print("[LOG] Panier mis à jour. Sous-total: ${subTotal.toStringAsFixed(2)}€");
    notifyListeners();
  }

  void updateQuantity(CartItem item, int change) {
    int index = _items.indexOf(item);
    if (index == -1) return;

    if (item.isReward && change != -1) {
      print("[LOG] Tentative interdite de modifier la quantité d'une récompense");
      return;
    }

    int newQuantity = _items[index].quantity + change;
    print("[LOG] Modification quantité: ${item.product.name} ($newQuantity)");

    if (newQuantity <= 0) {
      _items.removeAt(index);
      print("[LOG] Produit retiré du panier");
    } else {
      _items[index].quantity = newQuantity;
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    print("[LOG] Suppression manuelle du produit: ${item.product.name}");
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    print("[LOG] Vidage complet du panier");
    _items.clear();
    notifyListeners();
  }

  int getPointsToDeduct() {
    return usedRewardPoints;
  }
}