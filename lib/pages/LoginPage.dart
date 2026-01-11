import 'dart:ui' as ui;
import 'package:atlas/enum/InputType.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/login/AuthSheet.dart';
import 'package:atlas/widgets/login/inputField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final Color scaffoldColor = const Color(0xFFF9F9F9);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: yellowColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 65, 
                  child: Center(
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                      child: Image.asset('assets/logo.png', width: 310, fit: BoxFit.contain, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.srcIn),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  child: Center(child: Image.asset('assets/logo.png', width: 300, fit: BoxFit.contain)),
                ),
                Positioned(
                  bottom: 50,
                  child: Column(
                    children: [
                      const Text("Bienvenue !", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text("Artisanal Terroir Luxe Authentique \nSignature", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w600, letterSpacing: 1.2, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
                    label: "Email", 
                    controller: _emailController,
                    type: InputType.email
                  ),

                  InputField(
                    label: "Mot de passe", 
                    controller: _passwordController,
                    type: InputType.password
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: userProvider.isLoading ? null : () {
                        userProvider.signIn(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          context: context
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Se connecter",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ? ", style: TextStyle(fontSize: 14, color: Colors.black)),
                      GestureDetector(
                        onTap: () => AuthSheet.showRegister(context),
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}