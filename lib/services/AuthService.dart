import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion de l'utilisateur
  Future<auth.UserCredential> signIn({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Inscription et création du profil dans Firestore
  Future<void> signUp({required String email, required String password, required String pseudo}) async {
    auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    auth.User? user = result.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'pseudo': pseudo,
        'points': 0,
        'premium': false,
        'addresses': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print("[LOG] Erreur sendPasswordResetEmail: $e");
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Suppression définitive
  Future<void> deleteAccount() async {
    auth.User? user = _auth.currentUser;
    if (user == null) throw Exception("Aucun utilisateur connecté.");

    try {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception("requires-recent-login");
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}