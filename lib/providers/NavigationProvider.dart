import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    print("[LOG] Navigation: Changement d'onglet vers l'index $index");
    _currentIndex = index;
    notifyListeners();
  }
}