import 'dart:ui' as ui;
import 'package:atlas/enum/InputType.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/login/AuthSheet.dart';
import 'package:atlas/widgets/login/inputField.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetController = TextEditingController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Réinitialisation",
          style: GoogleFonts.lilitaOne(color: isDark ? Colors.white : Colors.black)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saisissez votre email pour recevoir un lien de réinitialisation.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            InputField(
              label: "Votre Email",
              controller: resetController,
              type: InputType.email,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resetController.text.isNotEmpty) {
                await Provider.of<UserProvider>(context, listen: false)
                    .forgotPassword(resetController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  Toast.show(context, "Email envoyé ! Vérifiez votre boîte de réception 📧");
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? yellowColor : Colors.black,
              foregroundColor: isDark ? Colors.black : yellowColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("ENVOYER", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

                  // --- AJOUT : LIEN MOT DE PASSE OUBLIÉ ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showForgotPasswordDialog(context),
                      child: Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(
                          color: isDark ? yellowColor : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

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
                        backgroundColor: isDark ? yellowColor : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: userProvider.isLoading
                          ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white)
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
                      Text("Pas encore de compte ? ", style: TextStyle(fontSize: 14, color: textColor)),
                      GestureDetector(
                        onTap: () => AuthSheet.showRegister(context),
                        child: Text(
                          "Créer un compte",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? yellowColor : Colors.black, decoration: TextDecoration.underline),
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