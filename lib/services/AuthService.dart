import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// Permet la création d'un compte utilisateur (Authentificqtion + Document)
  Future<void> signUp({
    required String email,
    required String password,
    required String pseudo
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        "email": email,
        "pseudo": pseudo,
        "points": 0,
        "premium": false
      });

    } catch(e) {
      rethrow;
    }
  }

  /// Connexion utilisateur.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}