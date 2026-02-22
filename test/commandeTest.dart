import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tests Complets Panier (CommandeProvider)', () {

    // Produit de base (10€)
    final product10 = ProductModel(
      id: 'p1',
      description: 'Miam',
      name: 'Burger',
      price: 10.0,
      average: 5.0,
      calorie: 500,
      time: 10,
      type: 'burger',
      rating_count: 0,
      nationality: 'US',
      img_url: 'img.png',
    );

    // Produit cher (40€) pour tester le seuil de livraison
    final product40 = ProductModel(
      id: 'p2',
      description: 'Luxe',
      name: 'Caviar',
      price: 40.0,
      average: 5.0,
      calorie: 100,
      time: 10,
      type: 'other',
      rating_count: 0,
      nationality: 'FR',
      img_url: 'img.png',
    );

    test('Standard : Prix normal + Frais de livraison', () {
      final provider = Commandeprovider();
      final user = UserModel(email: 'a@a.com', pseudo: 'A', points: 0, premium: false, addresses: [], planId: 'None', isAdmin: false);

      provider.updateUser(user);
      provider.addItem(product10, 1);

      // 10€ + 2.55€ de frais
      expect(provider.subTotal, 10.0);
      expect(provider.deliveryFee, 2.55);
      expect(provider.total, 12.55);
    });

    test('Nomad (< 30€) : -5% + Frais de livraison', () {
      final provider = Commandeprovider();
      final user = UserModel(email: 'b@b.com', pseudo: 'B', points: 0, premium: true, addresses: [], planId: 'nomad', isAdmin: false);

      provider.updateUser(user);
      provider.addItem(product10, 1);

      // (10€ * 0.95) + 2.55€ = 9.50 + 2.55 = 12.05€
      expect(provider.deliveryFee, 2.55);
      expect(provider.total, closeTo(12.05, 0.01));
    });

    test('Nomad (> 30€) : -5% + Livraison OFFERTE', () {
      final provider = Commandeprovider();
      final user = UserModel(email: 'b@b.com', pseudo: 'B', points: 0, premium: true, addresses: [], planId: 'nomad', isAdmin: false);

      provider.updateUser(user);
      provider.addItem(product40, 1); // 40€

      // (40€ * 0.95) + 0€ = 38.0€
      expect(provider.subTotal, 40.0);
      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 38.0);
    });

    test('Explorer : -10% + Livraison OFFERTE (toujours)', () {
      final provider = Commandeprovider();
      final user = UserModel(email: 'c@c.com', pseudo: 'C', points: 0, premium: true, addresses: [], planId: 'explorer', isAdmin: false);

      provider.updateUser(user);
      provider.addItem(product10, 1); // Seulement 10€

      // (10€ * 0.90) + 0€ = 9.0€
      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 9.0);
    });

    test('Elite : -20% + Livraison OFFERTE (toujours)', () {
      final provider = Commandeprovider();
      final user = UserModel(email: 'd@d.com', pseudo: 'D', points: 0, premium: true, addresses: [], planId: 'elite', isAdmin: false);

      provider.updateUser(user);
      provider.addItem(product10, 1);

      // (10€ * 0.80) + 0€ = 8.0€
      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 8.0);
    });

    test('Récompense : Ajout réussi si assez de points', () {
      final provider = Commandeprovider();
      // User avec 100 points
      final user = UserModel(email: 'e@e.com', pseudo: 'E', points: 100, premium: false, addresses: [], planId: 'None', isAdmin: false);

      provider.updateUser(user);

      // Ajout récompense coûtant 50 pts
      provider.addItem(product10, 1, isReward: true, rewardCost: 50);

      // Le prix de la récompense doit être 0
      expect(provider.subTotal, 0.0);

      // Points utilisés
      expect(provider.usedRewardPoints, 50);

      // Points restants virtuels
      expect(provider.availablePoints, 50);
    });

    test('Récompense : Erreur si pas assez de points', () {
      final provider = Commandeprovider();

      // User avec seulement 10 points
      final user = UserModel(email: 'f@f.com', pseudo: 'F', points: 10, premium: false, addresses: [], planId: 'None', isAdmin: false);

      provider.updateUser(user);

      // Doit lever une exception car 50 > 10
      expect(
        () => provider.addItem(product10, 1, isReward: true, rewardCost: 50),
        throwsException
      );
    });

    test('Récompense : Erreur si déjà une récompense dans le panier', () {
      final provider = Commandeprovider();
      final user = UserModel(email: 'g@g.com', pseudo: 'G', points: 200, premium: false, addresses: [], planId: 'None', isAdmin: false);

      provider.updateUser(user);

      // 1ère récompense OK
      provider.addItem(product10, 1, isReward: true, rewardCost: 50);

      // 2ème récompense doit échouer (limite de 1)
      expect(
        () => provider.addItem(product40, 1, isReward: true, rewardCost: 50),
        throwsException
      );
    });

  });
}