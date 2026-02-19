import 'package:atlas/models/CategoryModel.dart';
import 'package:atlas/services/DatabaseService.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Categorymodel> _categories = [];
  bool _isLoading = false;

  List<Categorymodel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    if(_categories.isNotEmpty) return;

    print("[LOG] Récupération des catégories depuis la base de données...");
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _dbService.getCategories();
      print("[LOG] ${_categories.length} catégories chargées avec succès");
    } catch(e) {
      print('[LOG] Erreur lors de la récupération des catégories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCategories() async {
    print("[LOG] Rafraîchissement manuel des catégories");
    _categories.clear();
    await fetchCategories();
  }
}