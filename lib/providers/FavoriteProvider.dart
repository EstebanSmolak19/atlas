import 'package:atlas/models/ProductModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<String> _favoriteIds = [];
  List<String> get favoriteIds => _favoriteIds;

  List<ProductModel> _favoriteProducts = [];
  List<ProductModel> get favoriteProducts => _favoriteProducts;

  Future<void> fetchFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      _favoriteIds = [];
      _favoriteProducts = [];
      notifyListeners();
      return;
    }

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();

      _favoriteProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return ProductModel.fromMap(data);
      }).toList();

      notifyListeners();
    } catch (e) {
      print("Erreur favoris: $e");
    }
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String prodId = product.id;
    final docRef = _db.collection('users').doc(user.uid).collection('favorites').doc(prodId);

    if (_favoriteIds.contains(prodId)) {
      try {
        await docRef.delete();
        _favoriteIds.remove(prodId);
        _favoriteProducts.removeWhere((p) => p.id == prodId);
        notifyListeners();
      } catch (e) {
        print("Erreur suppression: $e");
      }
    } else {
      try {
        await docRef.set(product.toMap());
        
        _favoriteIds.add(prodId);
        _favoriteProducts.add(product);
        notifyListeners();
      } catch (e) {
        print("Erreur ajout: $e");
      }
    }
  }
}