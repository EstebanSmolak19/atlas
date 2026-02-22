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

    print("[LOG] Récupération des favoris pour: ${user.email}");

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      // Récupère les IDs des documents
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();

      // Récupère les objets
      _favoriteProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();

      print("[LOG] ${_favoriteProducts.length} favoris chargés");
      notifyListeners();
    } catch (e) {
      print("[LOG] Erreur lors de la récupération des favoris: $e");
    }
  }

  // Vérifie si l'ID est dans la liste
  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String prodId = product.id;

    if (prodId.isEmpty) {
      print("[LOG] Erreur : ID du produit vide, impossible de modifier les favoris.");
      return;
    }

    final docRef = _db.collection('users').doc(user.uid).collection('favorites').doc(prodId);

    if (_favoriteIds.contains(prodId)) {
      print("[LOG] Suppression du produit des favoris: ${product.name}");
      try {
        await docRef.delete();
        _favoriteIds.remove(prodId);
        _favoriteProducts.removeWhere((p) => p.id == prodId);

        print("[LOG] Produit supprimé des favoris avec succès");
        notifyListeners();
      } catch (e) {
        print("[LOG] Erreur suppression favoris: $e");
      }
    } else {
      print("[LOG] Ajout du produit aux favoris: ${product.name}");
      try {
        await docRef.set(product.toMap());

        _favoriteIds.add(prodId);
        _favoriteProducts.add(product);

        print("[LOG] Produit ajouté aux favoris avec succès");
        notifyListeners();
      } catch (e) {
        print("[LOG] Erreur ajout favoris: $e");
      }
    }
  }
}