import 'package:atlas/pages/CategoriePage.dart';
import 'package:atlas/pages/DetailPage.dart';
import 'package:atlas/pages/FirstPage.dart';
import 'package:atlas/pages/LoginPage.dart';
import 'package:atlas/pages/RegiterPage.dart';
import 'package:atlas/widgets/BottomNavbar.dart';
import 'package:flutter/cupertino.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String first = '/first';
  static const String register = '/register';
  static const String burgerPage = '/categorie-page';
  static const String detailPage = '/details';
  static const String categoryPage = 'categoryPage';

  static Map<String, String> get _dynamicCategoryMap => <String, String> { 
    'Burger': burgerPage,
  };

  // Méthode utilitaire pour récupérer la route dynamiquement
  static String getRouteByName(String categoryName) {
    return _dynamicCategoryMap[categoryName]!;
  }

  static final Map<String, WidgetBuilder> routes = {
    login        : (context) => const LoginPage(),
    home         : (context) => const BottomNavbar(),
    first        : (context) => const FirstPage(),
    register     : (context) => const RegisterPage(),
    categoryPage : (context) => const CategoryPage(),
    detailPage   : (context) => const DetailPage()
  };
}