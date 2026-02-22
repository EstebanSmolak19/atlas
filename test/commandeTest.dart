import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tests Complets Panier (CommandeProvider)', () {
    final product10 = ProductModel(
      id: 'p1',
      description: 'Test',
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

    final product40 = ProductModel(
      id: 'p2',
      description: 'Luxe',
      name: 'Pizza XL',
      price: 40.0,
      average: 5.0,
      calorie: 1000,
      time: 20,
      type: 'pizza',
      rating_count: 0,
      nationality: 'IT',
      img_url: 'img.png',
    );

    test('STANDARD : Pas de réduction, Livraison 2.55, Points x1', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'a@a.com',
        pseudo: 'A',
        points: 0,
        premium: false,
        addresses: [],
        planId: 'None',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1);

      expect(provider.subTotal, 10.0);
      expect(provider.deliveryFee, 2.55);
      expect(provider.total, 12.55);
      expect(provider.points, 10);
    });

    test('NOMAD : -5% réduction, Livraison 0 si >= 30€ sinon 2.55', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'b@b.com',
        pseudo: 'B',
        points: 0,
        premium: true,
        addresses: [],
        planId: 'nomad',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1);

      expect(provider.deliveryFee, 2.55);
      expect(provider.total, closeTo(12.05, 0.01));

      provider.clearCart();
      provider.addItem(product40, 1);

      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 38.0);
      expect(provider.points, 40);
    });

    test('EXPLORER : -10% réduction, Livraison OFFERTE toujours, Points x1', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'c@c.com',
        pseudo: 'C',
        points: 0,
        premium: true,
        addresses: [],
        planId: 'explorer',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1);

      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 9.0);
      expect(provider.points, 10);
    });

    test('ELITE : -20% réduction, Livraison OFFERTE toujours, Points x2', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'd@d.com',
        pseudo: 'D',
        points: 0,
        premium: true,
        addresses: [],
        planId: 'elite',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1);

      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 8.0);
      expect(provider.points, 20);
    });

    test('MENU : Supplément 3.99€ et calcul des points sur le total', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'a@a.com',
        pseudo: 'A',
        points: 0,
        premium: false,
        addresses: [],
        planId: 'None',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1, isMenu: true);

      expect(provider.subTotal, 13.99);
      expect(provider.points, 13);
      expect(provider.total, 13.99 + 2.55);
    });

    test('RECOMPENSE : Prix 0€ et déduction correcte des points', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'e@e.com',
        pseudo: 'E',
        points: 100,
        premium: false,
        addresses: [],
        planId: 'None',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1, isReward: true, rewardCost: 50);

      expect(provider.subTotal, 0.0);
      expect(provider.usedRewardPoints, 50);
      expect(provider.availablePoints, 50);
      expect(provider.total, 2.55);
    });

    test('MIXTE : Article payant + Récompense gratuite', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'f@f.com',
        pseudo: 'F',
        points: 500,
        premium: true,
        addresses: [],
        planId: 'elite',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 1);
      provider.addItem(product40, 1, isReward: true, rewardCost: 300);

      expect(provider.subTotal, 10.0);
      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 8.0);
      expect(provider.points, 20);
      expect(provider.availablePoints, 200);
    });

    test('QUANTITE : Calcul correct avec plusieurs articles', () {
      final provider = Commandeprovider();
      final user = UserModel(
        email: 'a@a.com',
        pseudo: 'A',
        points: 0,
        premium: false,
        addresses: [],
        planId: 'None',
        isAdmin: false
      );

      provider.updateUser(user);
      provider.addItem(product10, 3);

      expect(provider.subTotal, 30.0);
      expect(provider.points, 30);
      expect(provider.total, 32.55);
    });
  });
}