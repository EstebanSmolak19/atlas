import 'package:atlas/pages/commande/CommandePage.dart';
import 'package:atlas/pages/commande/PaymentPage.dart';
import 'package:atlas/pages/product/FavoritePage.dart';
import 'package:atlas/pages/profile/AddressPage.dart';
import 'package:atlas/pages/product/CategoriePage.dart';
import 'package:atlas/pages/product/DetailPage.dart';
import 'package:atlas/pages/FirstPage.dart';
import 'package:atlas/pages/LoginPage.dart';
import 'package:atlas/pages/RegiterPage.dart';
import 'package:atlas/pages/product/ReviewPage.dart';
import 'package:atlas/pages/profile/SupportPage.dart';
import 'package:atlas/widgets/BottomNavbar.dart';
import 'package:flutter/cupertino.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String first = '/first';
  static const String register = '/register';
  static const String detailPage = '/details';
  static const String categoryPage = 'categoryPage';
  static const String commande = '/commande';
  static const String support = '/support';
  static const String favorite = '/favorite';
  static const String review = '/review';
  static const String payment = '/payment';
  static const String address = '/address';


  static final Map<String, WidgetBuilder> routes = {
    login        : (context) => const LoginPage(),
    home         : (context) => const BottomNavbar(),
    first        : (context) => const FirstPage(),
    register     : (context) => const RegisterPage(),
    categoryPage : (context) => const CategoryPage(),
    detailPage   : (context) => const DetailPage(),
    commande     : (context) => const CommandePage(),
    support      : (context) => const SupportPage(),
    favorite     : (context) => const FavoritePage(),
    review       : (context) => const ReviewsPage(),
    payment      : (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final double amount = (args is double) ? args : 0.0;
      return PaymentPage(totalAmount: amount);
    },
    address      : (context) => const AddressPage()
  };
} 