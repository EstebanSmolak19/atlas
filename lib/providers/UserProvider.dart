import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:atlas/models/UserModel.dart';
import 'package:atlas/services/UserService.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
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
      debugPrint("Erreur lors du chargement de l'utilisateur: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}