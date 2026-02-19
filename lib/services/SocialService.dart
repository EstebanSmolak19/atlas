import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> searchUser(String query) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    var snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: query.trim())
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await _db
          .collection('users')
          .where('pseudo', isEqualTo: query.trim())
          .get();
    }

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      if (doc.id == currentUser.uid) return null;
      return {
        'uid': doc.id,
        'pseudo': doc.data()['pseudo'],
        'email': doc.data()['email'],
      };
    }
    return null;
  }

  Future<void> sendFriendRequest(Map<String, dynamic> targetUser) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final myDoc = await _db.collection('users').doc(user.uid).get();

    await _db
        .collection('users')
        .doc(targetUser['uid'])
        .collection('friend_requests')
        .doc(user.uid)
        .set({
      'fromId': user.uid,
      'fromPseudo': myDoc.data()?['pseudo'] ?? "Un explorateur",
      'fromEmail': myDoc.data()?['email'] ?? "",
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(Map<String, dynamic> requestData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final myId = user.uid;
    final friendId = requestData['fromId'];

    final myDoc = await _db.collection('users').doc(myId).get();
    final myData = myDoc.data()!;

    final batch = _db.batch();

    batch.set(_db.collection('users').doc(myId).collection('friends').doc(friendId), {
      'uid': friendId,
      'pseudo': requestData['fromPseudo'],
      'email': requestData['fromEmail'],
      'addedAt': FieldValue.serverTimestamp(),
    });

    // Ajouter moi chez l'ami (Lien bidirectionnel)
    batch.set(_db.collection('users').doc(friendId).collection('friends').doc(myId), {
      'uid': myId,
      'pseudo': myData['pseudo'],
      'email': myData['email'],
      'addedAt': FieldValue.serverTimestamp(),
    });

    batch.delete(_db.collection('users').doc(myId).collection('friend_requests').doc(friendId));

    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db.collection('users').doc(user.uid).collection('friends').snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getRequestsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db.collection('users').doc(user.uid).collection('friend_requests').snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Future<void> transferPoints(String toUserId, int amount, String toPseudo) async {
    final fromUser = _auth.currentUser;
    if (fromUser == null) throw Exception("Non connecté");

    final fromRef = _db.collection('users').doc(fromUser.uid);
    final toRef = _db.collection('users').doc(toUserId);

    return _db.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      int currentPoints = (fromSnap.data()?['points'] ?? 0) as int;

      if (currentPoints < amount) throw Exception("Points insuffisants");

      transaction.update(fromRef, {'points': currentPoints - amount});
      transaction.update(toRef, {'points': FieldValue.increment(amount)});

      transaction.set(_db.collection('point_transactions').doc(), {
        'fromId': fromUser.uid,
        'toId': toUserId,
        'toPseudo': toPseudo,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'gift'
      });
    });
  }
}