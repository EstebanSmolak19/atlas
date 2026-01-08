import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/services/DatabaseService.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchPopularItems() async {
    if(_products.isNotEmpty) return;
    _isLoading = true;

    try {
      _products = await _dbService.getAllPopularItem();
    } catch(e) {
      print('Erreur Provider ${e}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPopularItem() async {
    _products.clear();
    fetchPopularItems();
    notifyListeners();
  }
}