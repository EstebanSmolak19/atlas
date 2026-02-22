import 'package:atlas/enum/ProductType.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/services/DatabaseService.dart';
import 'package:atlas/services/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  List<ProductModel> _popularItems = [];
  List<ProductModel> _categoryProducts = [];

  bool _isLoading = false;
  bool _isLoadingPopular = false;
  bool _isLoadingCategory = false;

  List<ProductModel> get popularItems => _popularItems;
  List<ProductModel> get categoryProducts => _categoryProducts;

  bool get isLoading => _isLoading;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingCategory => _isLoadingCategory;

  Future<void> addProduct(ProductModel product) async {
    print("[LOG] Tentative d'ajout du produit: ${product.name}");
    _isLoading = true;
    notifyListeners();

    try {
      // Appel du service pour l'enregistrement en base
      await _authService.createProduct(product);

      // On rafraîchit les listes locales pour inclure le nouveau produit
      await refreshPopularItems();

      print("[LOG] Produit ajouté et listes rafraîchies");
    } catch (e) {
      print("[LOG] Erreur addProduct: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopularItems() async {
    if (_popularItems.isNotEmpty) return;

    print("[LOG] Récupération des produits populaires...");
    _isLoadingPopular = true;
    notifyListeners();

    try {
      _popularItems = await _dbService.getAllPopularItem();
      print("[LOG] ${_popularItems.length} produits populaires chargés");
    } catch (e) {
      print('[LOG] Erreur fetchPopularItems: $e');
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(ProductType type) async {
    print("[LOG] Récupération des produits pour la catégorie: ${type.name}");
    _isLoadingCategory = true;
    _categoryProducts = [];
    notifyListeners();

    try {
      _categoryProducts = await _dbService.getProductsByCategory(type.name.toLowerCase());
      print("[LOG] ${_categoryProducts.length} produits chargés pour ${type.name}");
    } catch (e) {
      print('[LOG] Erreur fetchProductsByCategory: $e');
    } finally {
      _isLoadingCategory = false;
      notifyListeners();
    }
  }

  Future<void> refreshPopularItems() async {
    print("[LOG] Rafraîchissement des produits populaires");
    _popularItems.clear();
    await fetchPopularItems();
  }

  Future<void> updateSingleProduct(String productId) async {
    print("[LOG] Mise à jour des données locales pour le produit: $productId");
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final updatedProduct = ProductModel.fromMap(data);

        final popIndex = _popularItems.indexWhere((p) => p.id == productId);
        if (popIndex != -1) {
          _popularItems[popIndex] = updatedProduct;
        }

        final catIndex = _categoryProducts.indexWhere((p) => p.id == productId);
        if (catIndex != -1) {
          _categoryProducts[catIndex] = updatedProduct;
        }

        print("[LOG] Produit $productId mis à jour avec succès");
        notifyListeners();
      }
    } catch (e) {
      print("[LOG] Erreur updateSingleProduct: $e");
    }
  }
}