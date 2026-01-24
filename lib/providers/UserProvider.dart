import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:atlas/services/AuthService.dart';
import 'package:atlas/services/UserService.dart';
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
      await loadUser();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect.")),
        );
      }
    } finally {
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
      await _authService.signUp(
        email: email, 
        password: password, 
        pseudo: pseudo
      );
      await loadUser();
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

  // --- GESTION DES ADRESSES ---

  Future<void> addAddress(String address) async {
    try {
      await _userService.addAddress(address);
      await loadUser(); // Recharger pour mettre à jour la liste locale
    } catch (e) {
      print("Erreur UserProvider addAddress: $e");
    }
  }

  Future<void> removeAddress(String address) async {
    try {
      await _userService.removeAddress(address);
      await loadUser(); // Recharger pour mettre à jour la liste locale
    } catch (e) {
      print("Erreur UserProvider removeAddress: $e");
    }
  }
}