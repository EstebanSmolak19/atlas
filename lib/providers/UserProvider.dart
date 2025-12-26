import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:atlas/services/AuthService.dart';
import 'package:atlas/services/UserService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _userService.getCurrentUserDetails();
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);

      //On charge les données utilisateur
      await loadUser();

      //Si tout est bon, on navigue
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }

    } catch (e) {
      //Si erreur, on affiche le message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect.")),
        );
      }
    } finally {
      //On arrête le chargement
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String pseudo,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      //Appel au service pour créer le compte Auth + Document Firestore
      await _authService.signUp(
        email: email, 
        password: password, 
        pseudo: pseudo
      );

      //On charge l'utilisateur pour mettre à jour l'état local
      await loadUser();

      //Redirection
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'inscription : $e")),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}