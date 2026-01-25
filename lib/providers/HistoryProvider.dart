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
          
    } catch (e) {
      print("Erreur fetch history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrderFromCart(Commandeprovider cartProvider, double totalAmount) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    List<Map<String, dynamic>> orderItems = cartProvider.items.map((cartItem) {
      return {
        'productId': cartItem.product.id,
        'name': cartItem.product.name,
        'price': cartItem.product.price,
        'quantity': cartItem.quantity,
        'img_url': cartItem.product.img_url,
      };
    }).toList();

    await _db.collection('users').doc(user.uid).collection('history').add({
      'userId': user.uid,
      'total': totalAmount,
      'status': 'En préparation',
      'date': FieldValue.serverTimestamp(),
      'items': orderItems,
    });

    await fetchUserHistory();
  }
}