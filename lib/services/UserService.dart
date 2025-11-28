import 'package:atlas/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUserDetails() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        return null; 
      }

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return(UserModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    }
    
    return null;
  }
}