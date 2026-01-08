import 'package:atlas/widgets/appbar/customAppbar.dart';
import 'package:atlas/widgets/appbar/ProductAppbar.dart';
import 'package:flutter/material.dart';

class BurgerPage extends StatefulWidget {
  const BurgerPage({super.key});

  @override
  State<BurgerPage> createState() => _BurgerPageState();
}

class _BurgerPageState extends State<BurgerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProductAppbar(),
      body: Center(child: Text("Burger Page"))
    );
  }
}