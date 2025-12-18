import 'package:atlas/AuthGate.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

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

              //image burger
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
              Text(
                "Comblez vos envies\nEt déballez\nDu délice.",
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
                "Des moments savoureux, livrés chez vous - Votre expérience culinaire redéfinie.",
                style: TextStyle(
                  fontSize: 14,
                  color: darkColor.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              //Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: true, color: darkColor),
                  const SizedBox(width: 8),
                  _buildDot(isActive: false, color: darkColor),
                  const SizedBox(width: 8),
                  _buildDot(isActive: false, color: darkColor),
                ],
              ),

              const SizedBox(height: 50),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AuthGate()));
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
                  //Boutons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        
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
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}