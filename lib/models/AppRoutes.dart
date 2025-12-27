import 'package:atlas/pages/BurgerPage.dart';
import 'package:atlas/pages/FirstPage.dart';
import 'package:atlas/pages/LoginPage.dart';
import 'package:atlas/pages/PizzaPage.dart';
import 'package:atlas/pages/RegiterPage.dart';
import 'package:atlas/widgets/BottomNavbar.dart';
import 'package:flutter/cupertino.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String first = '/first';
  static const String register = '/register';
  static const String burgerPage = '/burger-page';
  static const String pizzaPage = '/pizza-page';

  static Map<String, String> get _dynamicCategoryMap => <String, String> { 
    'Burger': burgerPage,
    'Pizza': pizzaPage,
  };

  // Méthode utilitaire pour récupérer la route dynamiquement
  static String getRouteByName(String categoryName) {
    return _dynamicCategoryMap[categoryName]!;
  }

  static final Map<String, WidgetBuilder> routes = {
    login      : (context) => const LoginPage(),
    home       : (context) => const BottomNavbar(),
    first      : (context) => const FirstPage(),
    register   : (context) => const RegisterPage(),

    burgerPage : (context) => const BurgerPage(),
    pizzaPage  : (context) => const PizzaPage(),
  };
}