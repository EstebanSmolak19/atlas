import 'package:atlas/models/HistoryModel.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HistoryModel> _orders = [];
  bool _isLoading = false;

  List<HistoryModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchUserHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    print("[LOG] Récupération de l'historique des commandes pour: ${user.email}");
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('date', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => HistoryModel.fromMap(doc.data(), doc.id))
          .toList();

      print("[LOG] ${_orders.length} commandes chargées dans l'historique");

    } catch (e) {
      print("[LOG] Erreur fetch history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrderFromCart(Commandeprovider cartProvider, double totalAmount) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    print("[LOG] Tentative de création de commande (Montant: ${totalAmount.toStringAsFixed(2)}€)");

    List<Map<String, dynamic>> orderItems = cartProvider.items.map((cartItem) {
      return {
        'productId': cartItem.product.id,
        'name': cartItem.product.name,
        'price': cartItem.product.price,
        'quantity': cartItem.quantity,
        'img_url': cartItem.product.img_url,
        'details': cartItem.product.description,
      };
    }).toList();

    try {
      await _db.collection('users').doc(user.uid).collection('history').add({
        'userId': user.uid,
        'total': totalAmount,
        'status': 'En préparation',
        'date': FieldValue.serverTimestamp(),
        'items': orderItems,
      });

      print("[LOG] Commande enregistrée avec succès dans Firestore");
      await fetchUserHistory();
    } catch (e) {
      print("[LOG] Erreur lors de la création de la commande: $e");
      rethrow;
    }
  }
}