import 'package:atlas/services/SocialService.dart';
import 'package:flutter/material.dart';

class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  Map<String, dynamic>? _searchedUser; // État pour la prévisualisation
  bool _isLoading = false;

  List<Map<String, dynamic>> get friends => _friends;
  List<Map<String, dynamic>> get requests => _requests;
  Map<String, dynamic>? get searchedUser => _searchedUser;
  bool get isLoading => _isLoading;

  // Initialise l'écoute en temps réel de la liste d'amis
  void initFriendsListener() {
    _socialService.getFriendsStream().listen((data) {
      _friends = data;
      notifyListeners();
    });
  }

  // Initialise l'écoute en temps réel des demandes d'amis reçues
  void initRequestsListener() {
    _socialService.getRequestsStream().listen((data) {
      _requests = data;
      notifyListeners();
    });
  }

  // Recherche un utilisateur et stocke le résultat pour la prévisualisation
  Future<void> searchUser(String query) async {
    _isLoading = true;
    _searchedUser = null;
    notifyListeners();

    try {
      final user = await _socialService.searchUser(query);
      _searchedUser = user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Réinitialise la recherche
  void clearSearch() {
    _searchedUser = null;
    notifyListeners();
  }

  // Envoie une demande d'ami
  Future<void> sendFriendRequest(Map<String, dynamic> targetUser) async {
    await _socialService.sendFriendRequest(targetUser);
    _searchedUser = null;
    notifyListeners();
  }

  Future<void> acceptFriendRequest(Map<String, dynamic> requestData) async {
    await _socialService.acceptFriendRequest(requestData);
  }

  Future<void> sendPoints(String toId, int amount, String toPseudo) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _socialService.transferPoints(toId, amount, toPseudo);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}