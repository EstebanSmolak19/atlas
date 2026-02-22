import 'package:atlas/models/RewardModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RewardModel> _rewards = [];
  bool _isLoading = false;

  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;

  Future<void> fetchRewards() async {
    print("[LOG] Récupération de la liste des récompenses...");
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('rewards')
          .orderBy('cost', descending: false)
          .get();

      _rewards = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RewardModel.fromMap(data);
      }).toList();

    } catch (e) {
      print("[LOG] Erreur fetch rewards: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> redeemReward(RewardModel reward) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    print("[LOG] Tentative d'échange de points pour: ${reward.title} (${reward.cost} pts)");

    final userRef = _db.collection('users').doc(user.uid);

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) throw Exception("Profil introuvable");

      final int currentPoints = (userSnapshot.data()?['points'] ?? 0) as int;

      if (currentPoints < reward.cost) {
        print("[LOG] Échec échange: Points insuffisants");
        throw Exception("Points insuffisants !");
      }

      transaction.update(userRef, {'points': currentPoints - reward.cost});

      final historyRef = userRef.collection('redeemed_rewards').doc();
      transaction.set(historyRef, {
        'rewardId': reward.id,
        'title': reward.title,
        'description': reward.description,
        'cost': reward.cost,
        'redeemedAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'code': "REW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      });
    });

    print("[LOG] Récompense échangée avec succès !");
    notifyListeners();
  }
}