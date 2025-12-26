import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        "email": email,
        "pseudo": pseudo,
        "points": 0,
        "premium": false,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
      });
    } catch(e) {
      rethrow; // On renvoie l'erreur au Provider
    }
  }

  // Juste la logique Firebase.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch(e) {
      rethrow; // On renvoie l'erreur au Provider
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}