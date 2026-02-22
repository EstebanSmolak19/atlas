import 'package:atlas/models/ProductModel.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  final bool isReward;
  final int? rewardCost;
  final int? rewardTier;
  final bool isMenu;

  CartItem({
    required this.product,
    required this.quantity,
    this.isReward = false,
    this.rewardCost,
    this.rewardTier,
    this.isMenu = false,
  });

  double get unitPrice {
    if (isReward) return 0.0;
    double price = product.price;
    if (isMenu) price += 3.99; // Supplément menu fixe (simulation)
    return price;
  }

  double get totalPrice {
    return unitPrice * quantity;
  }
}

class Commandeprovider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _discount = 0.0;
  String? _userPlanId;
  bool _isUserPremium = false;
  int _userCurrentPoints = 0;

  List<CartItem> get items => _items;

  double get subTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get usedRewardPoints {
    return _items.where((item) => item.isReward).fold(0, (sum, item) => sum + (item.rewardCost ?? 0));
  }

  int get availablePoints => _userCurrentPoints - usedRewardPoints;

  double get deliveryFee {
    if (!_isUserPremium) return 2.55;

    // Explorer et Elite : Livraison toujours offerte
    if (_userPlanId == 'explorer' || _userPlanId == 'elite') {
      return 0.0;
    }

    // Nomad : Offerte dès 30€
    if (_userPlanId == 'nomad' && subTotal >= 30.00) {
      return 0.0;
    }

    return 2.55;
  }

  double get total {
    if (_items.isEmpty) return 0;
    double discountedAmount = subTotal * (1 - _discount);
    return discountedAmount + deliveryFee;
  }

  // Détecte si une réduction (prix ou livraison) est active
  bool get hasEffectiveDiscount {
    if (_items.isEmpty) return false;
    double originalTotal = subTotal + 2.55;
    return total < originalTotal;
  }

  int get points {
    int basePoints = subTotal.toInt();
    // Elite : Points doublés
    if (_userPlanId == 'elite') {
      return basePoints * 2;
    }
    return basePoints;
  }

  // Avantage spécifique Elite
  bool get hasFreeDessert => _userPlanId == 'elite';

  void updateUser(dynamic user) {
    _discount = 0.0;
    _isUserPremium = false;
    _userPlanId = null;
    _userCurrentPoints = 0;

    if (user != null) {
      _userCurrentPoints = user.points;
      if (user.premium) {
        _isUserPremium = true;
        _userPlanId = user.planId?.toLowerCase();

        if (_userPlanId == 'nomad') {
          _discount = 0.05;
        } else if (_userPlanId == 'explorer') {
          _discount = 0.10;
        } else if (_userPlanId == 'elite') {
          _discount = 0.20;
        }
      }
    }

    Future.microtask(() => notifyListeners());
  }

  bool hasAnyReward() {
    return _items.any((item) => item.isReward);
  }

  bool canAffordReward(int cost) {
    return availablePoints >= cost;
  }

  void addItem(ProductModel product, int quantity, {
    bool isReward = false,
    int? rewardCost,
    int? rewardTier,
    bool isMenu = false
  }) {
    if (isReward) {
      if (hasAnyReward()) {
        throw Exception("Vous ne pouvez avoir qu'une seule récompense dans votre panier");
      }
      if (rewardCost != null && !canAffordReward(rewardCost)) {
        throw Exception("Points insuffisants");
      }
    }

    int index = _items.indexWhere((item) =>
      item.product.id == product.id &&
      item.isReward == isReward &&
      item.isMenu == isMenu
    );

    if (index != -1) {
      if (isReward) {
        throw Exception("Récompense déjà ajoutée");
      }
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        isReward: isReward,
        rewardCost: rewardCost,
        rewardTier: rewardTier,
        isMenu: isMenu,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int change) {
    int index = _items.indexOf(item);
    if (index == -1) return;
    if (item.isReward && change != -1) return;
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

  int getPointsToDeduct() {
    return usedRewardPoints;
  }
}