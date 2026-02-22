import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atlas/models/ProductModel.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- AUTHENTIFICATION ---

  // Connexion de l'utilisateur
  Future<auth.UserCredential> signIn({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Inscription et initialisation du profil Firestore
  Future<void> signUp({required String email, required String password, required String pseudo}) async {
    auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    auth.User? user = result.user;

    if (user != null) {
      // On crée le document de base pour le nouvel utilisateur
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'pseudo': pseudo,
        'points': 0,
        'premium': false,
        'isAdmin': false,
        'addresses': [],
        'planId': 'None',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Réinitialisation du mot de passe (Mot de passe oublié)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print("[LOG] Email de réinitialisation envoyé à: $email");
    } catch (e) {
      print("[LOG] Erreur lors de l'envoi de l'email de réinitialisation: $e");
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- GESTION DES PRODUITS ---

  // Création d'un nouvel article dans la boutique
  Future<void> createProduct(ProductModel product) async {
    try {
      // Conversion du modèle en Map pour Firestore
      final data = product.toMap();

      // On retire l'ID si celui-ci est vide pour laisser Firestore générer un ID unique automatiquement
      if (product.id.isEmpty) {
        data.remove('id');
      }

      await _firestore.collection('products').add(data);
      print("[LOG] Article '${product.name}' ajouté à la collection globale.");
    } catch (e) {
      print("[LOG] Erreur lors de la création de l'article: $e");
      rethrow;
    }
  }

  // --- SUPPRESSION DE COMPTE ET NETTOYAGE ---

  // Supprime le compte utilisateur et toutes ses données associées
  Future<void> deleteAccount() async {
    auth.User? user = _auth.currentUser;
    if (user == null) throw Exception("Aucun utilisateur connecté.");

    final String uid = user.uid;

    try {
      // 1. Nettoyage des sous-collections (History, Favorites, Friends)
      // On supprime les données AVANT le compte car l'utilisateur possède encore ses droits d'accès
      await _deleteCollection("users/$uid/history");
      await _deleteCollection("users/$uid/favorites");
      await _deleteCollection("users/$uid/friends");
      await _deleteCollection("users/$uid/friend_requests");

      // 2. Suppression du document profil principal
      await _firestore.collection('users').doc(uid).delete();

      // 3. Suppression définitive du compte Firebase Authentication
      await user.delete();

      print("[LOG] Compte utilisateur $uid et données associées supprimés avec succès.");
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Firebase demande une reconnexion si la session est trop ancienne (sécurité)
        throw Exception("requires-recent-login");
      }
      rethrow;
    } catch (e) {
      print("[LOG] Erreur lors de la suppression totale: $e");
      rethrow;
    }
  }

  Future<void> _deleteCollection(String path) async {
    final collection = _firestore.collection(path);
    final snapshots = await collection.get();

    if (snapshots.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}