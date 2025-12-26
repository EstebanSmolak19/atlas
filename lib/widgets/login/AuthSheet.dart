import 'package:atlas/enum/InputType.dart';
import 'package:atlas/pages/HomePage.dart';
import 'package:atlas/services/AuthService.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:atlas/widgets/login/inputField.dart';
import 'package:flutter/material.dart';

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
  final AuthService _authService = AuthService();
  
  // Contrôleurs
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  bool _isLoading = false;

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

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Toast.show(context, 'Veuillez remplir tous les champs obligatoires.');
      return;
    }
    
    if (!_isLogin && _pseudoController.text.isEmpty) {
      Toast.show(context, 'Le nom complet est obligatoire pour l\'inscription.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
      } else {
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          pseudo: _pseudoController.text.trim(),
        );
      }

      if (mounted) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        // );
      }

    } catch (e) {
      if (mounted) {
        Toast.show(context, _isLogin ? 'Email ou mot de passe incorrect.' : 'Erreur lors de l\'inscription.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellowColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
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
          ],
        ),
      ),
    );
  }
}