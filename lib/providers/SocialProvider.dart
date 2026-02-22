import 'package:atlas/services/SocialService.dart';
import 'package:flutter/material.dart';

class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  Map<String, dynamic>? _searchedUser;
  bool _isLoading = false;

  List<Map<String, dynamic>> get friends => _friends;
  List<Map<String, dynamic>> get requests => _requests;
  Map<String, dynamic>? get searchedUser => _searchedUser;
  bool get isLoading => _isLoading;

  void initFriendsListener() {
    _socialService.getFriendsStream().listen((data) {
      _friends = data;
      notifyListeners();
    });
  }

  void initRequestsListener() {
    _socialService.getRequestsStream().listen((data) {
      _requests = data;
      notifyListeners();
    });
  }

  Future<void> searchUser(String query) async {
    if (query.trim().isEmpty) return;

    _isLoading = true;
    _searchedUser = null;
    notifyListeners();

    try {
      final user = await _socialService.searchUser(query);
      _searchedUser = user;
    } catch (e) {
      print("Erreur recherche: $e");
      _searchedUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchedUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendFriendRequest(Map<String, dynamic> targetUser) async {
    await _socialService.sendFriendRequest(targetUser);
    _searchedUser = null;
    notifyListeners();
  }

  Future<void> acceptFriendRequest(Map<String, dynamic> requestData) async {
    await _socialService.acceptFriendRequest(requestData);
  }

  Future<void> removeFriend(String friendId) async {
    await _socialService.removeFriend(friendId);
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