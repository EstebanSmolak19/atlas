import 'package:atlas/enum/ProductType.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/services/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

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

  Future<void> fetchPopularItems() async {
    if (_popularItems.isNotEmpty) return;

    _isLoadingPopular = true;
    notifyListeners();

    try {
      _popularItems = await _dbService.getAllPopularItem();
    } catch (e) {
      print('Erreur fetchPopularItems: $e');
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(ProductType type) async {
    _isLoadingCategory = true;
    _categoryProducts = []; 
    notifyListeners(); 

    try {
      _categoryProducts = await _dbService.getProductsByCategory(type.name.toLowerCase());
    } catch (e) {
      print('Erreur fetchProductsByCategory: $e');
    } finally {
      _isLoadingCategory = false;
      notifyListeners();
    }
  }

  Future<void> refreshPopularItems() async {
    _popularItems.clear();
    await fetchPopularItems();
  }

  // Permet de mettre à jour un seul produit dans les listes sans tout recharger
  Future<void> updateSingleProduct(String productId) async {
    try {
      //On récupère la version fraîche du produit depuis Firestore
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final updatedProduct = ProductModel.fromMap(data);

        //On met à jour la liste des Populaires si le produit y est
        final popIndex = _popularItems.indexWhere((p) => p.id == productId);
        if (popIndex != -1) {
          _popularItems[popIndex] = updatedProduct;
        }

        //On met à jour la liste Catégorie si le produit y est
        final catIndex = _categoryProducts.indexWhere((p) => p.id == productId);
        if (catIndex != -1) {
          _categoryProducts[catIndex] = updatedProduct;
        }

        notifyListeners();
      }
    } catch (e) {
      print("Erreur updateSingleProduct: $e");
    }
  }
}