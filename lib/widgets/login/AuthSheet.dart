import 'package:atlas/enum/InputType.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:atlas/widgets/login/inputField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthSheet extends StatefulWidget {
  final bool isLogin;

  const AuthSheet({super.key, this.isLogin = true});

  static void showLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return const AuthSheet(isLogin: true);
      },
    );
  }

  static void showRegister(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return const AuthSheet(isLogin: false);
      },
    );
  }

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  late bool _isLogin;
  
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Bascule entre le mode Connexion et Inscription
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                _isLogin ? "Connexion" : "Créer un compte",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (!_isLogin)
              InputField(
                label: "Nom complet",
                controller: _pseudoController,
                type: InputType.text,
              ),

            InputField(
              label: "Email",
              controller: _emailController,
              type: InputType.email,
            ),
            
            InputField(
              label: "Mot de passe",
              controller: _passwordController,
              type: InputType.password,
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : () {
                   // Validation locale
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    Toast.show(context, 'Veuillez remplir tous les champs obligatoires.');
                    return;
                  }
                  if (!_isLogin && _pseudoController.text.isEmpty) {
                    Toast.show(context, 'Le nom complet est obligatoire.');
                    return;
                  }

                  if (_isLogin) {
                    userProvider.signIn(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      context: context
                    );
                  } else {
                    userProvider.signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      pseudo: _pseudoController.text.trim(),
                      context: context
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellowColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: userProvider.isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                    )
                  : Text(
                      _isLogin ? "Se connecter" : "S'inscrire",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
              ),
            ),

            const SizedBox(height: 15),

            // Lien pour basculer dynamiquement entre Login et Register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? "Pas encore de compte ? " : "Déjà un compte ? ",
                  style: const TextStyle(fontSize: 14),
                ),
                GestureDetector(
                  onTap: _toggleAuthMode,
                  child: Text(
                    _isLogin ? "Créer un compte" : "Se connecter",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}