import 'dart:async';
import 'package:atlas/models/AppRoutes.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _slides = [
    {
      "title": "Comblez vos envies\nEt déballez\nDu délice.",
      "subtitle": "Des moments savoureux, livrés chez vous - Votre expérience culinaire redéfinie.",
    },
    {
      "title": "Livraison Rapide\nDirectement\nChez vous.",
      "subtitle": "Suivez votre commande en temps réel et dégustez vos plats préférés sans attendre.",
    },
    {
      "title": "Le Meilleur\nDe la Cuisine\nLocale.",
      "subtitle": "Soutenez vos restaurants préférés et découvrez de nouvelles saveurs authentiques.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color.fromARGB(255, 242, 202, 80);
    final Color darkColor = const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(8, 15),
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Image.asset(
                            'assets/burgerLogin.png',
                            fit: BoxFit.contain,
                            color: Colors.black.withOpacity(0.3),
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/burgerLogin.png',
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _slides[index]["title"]!,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                            height: 1.2,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _slides[index]["subtitle"]!,
                          style: TextStyle(
                            fontSize: 14,
                            color: darkColor.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildDot(
                    isActive: index == _currentPage, 
                    color: darkColor
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(color: darkColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Se connecter",
                        style: TextStyle(
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: darkColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), 
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}