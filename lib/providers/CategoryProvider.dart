import 'package:atlas/models/CategoryModel.dart';
import 'package:atlas/services/DatabaseService.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Categorymodel> _categories = [];
  bool _isLoading = false;

  // Getters pour accéder aux données depuis l'UI
  List<Categorymodel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    if(_categories.isNotEmpty) return;
    _isLoading = true;

    try {
      _categories = await _dbService.getCategories();
    } catch(e) {
      print('Erreur Provider ${e}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCategories() async {
    _categories.clear();
    fetchCategories(); //On recharge les catégories.
  }
}