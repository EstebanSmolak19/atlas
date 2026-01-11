import 'package:atlas/enum/ProductType.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/services/DatabaseService.dart';
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
}