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
    print("[LOG] Chargement des données utilisateur...");
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _userService.getCurrentUserDetails();
      print("[LOG] Données utilisateur chargées pour: ${_user?.email}");
    } catch (e) {
      print("[LOG] Erreur lors du chargement utilisateur: $e");
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
    print("[LOG] Tentative de connexion: $email");
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      print("[LOG] Connexion réussie pour: $email");

      await loadUser();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }

    } catch (e) {
      print("[LOG] Échec de la connexion: $e");
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
    print("[LOG] Tentative d'inscription: $email");
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        pseudo: pseudo
      );
      print("[LOG] Inscription réussie pour: $email");

      await loadUser();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }

    } catch (e) {
      print("[LOG] Échec de l'inscription: $e");
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
    print("[LOG] Déconnexion de l'utilisateur");
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    print("[LOG] Tentative de suppression définitive du compte");
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _user = null;
      print("[LOG] Compte supprimé avec succès");
    } catch (e) {
      print("[LOG] Erreur lors de la suppression du compte: $e");
      rethrow; // On propage l'erreur pour l'afficher dans l'UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String address) async {
    print("[LOG] Ajout de l'adresse: $address");
    try {
      await _userService.addAddress(address);
      await loadUser();
      print("[LOG] Adresse ajoutée avec succès");
    } catch (e) {
      print("[LOG] Erreur UserProvider addAddress: $e");
    }
  }

  Future<void> removeAddress(String address) async {
    print("[LOG] Suppression de l'adresse: $address");
    try {
      await _userService.removeAddress(address);
      await loadUser();
      print("[LOG] Adresse supprimée avec succès");
    } catch (e) {
      print("[LOG] Erreur UserProvider removeAddress: $e");
    }
  }

  Future<void> AddPoints(int points) async {
    print("[LOG] Ajout de $points points");
    try {
      await _userService.addPoints(points);
      await loadUser();
      print("[LOG] Points ajoutés avec succès");
    } catch(e) {
      print("[LOG] Erreur UserProvider AddPoints: $e");
    }
  }

  Future<void> deductPoints(int points) async {
    print("[LOG] Déduction de $points points");
    await _userService.deductPoints(points);
    await loadUser();
    print("[LOG] Points déduits avec succès");
  }
}