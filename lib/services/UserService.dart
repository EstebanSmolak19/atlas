import 'package:atlas/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUserDetails() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null; 

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    }
    return null;
  }

  Future<void> submitReview(String productId, int rating, String comment) async {
    final user = _auth.currentUser;
    
    if (user == null) {
      throw Exception("Vous devez être connecté pour donner votre avis.");
    }

    //Récupération du Pseudo de l'utilisateur
    String userName = "Voyageur Atlas";
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        userName = userDoc.get('pseudo') ?? "Voyageur Atlas";
      }
    } catch (e) {
      print("Erreur récup pseudo: $e");
    }

    final productRef = _firestore.collection('products').doc(productId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);
      if (!snapshot.exists) throw Exception("Produit introuvable !");

      final double currentAverage = (snapshot.data()?['average'] ?? 0.0).toDouble();
      final int currentCount = (snapshot.data()?['rating_count'] ?? 0).toInt();

      final newCount = currentCount + 1;
      final newAverage = ((currentAverage * currentCount) + rating) / newCount;

      final reviewRef = productRef.collection('reviews').doc();
      transaction.set(reviewRef, {
        'userId': user.uid,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(productRef, {
        'average': newAverage,
        'rating_count': newCount,
      });
    });
  }
}