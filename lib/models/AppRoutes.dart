import 'package:atlas/pages/FirstPage.dart';
import 'package:atlas/pages/HomePage.dart';
import 'package:atlas/pages/LoginPage.dart';
import 'package:atlas/pages/RegiterPage.dart';
import 'package:flutter/cupertino.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String first = '/first';
  static const String register = '/register';


  static final Map<String, WidgetBuilder> routes = {
    login    : (context) => const LoginPage(),
    home     : (context) => const HomePage(),
    first    : (context) => const FirstPage(),
    register : (context) => const RegisterPage()
  };
}