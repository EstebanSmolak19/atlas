import 'package:atlas/models/CategoryModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Categorymodel>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _db
        .collection("categories")
        .orderBy('order', descending: false)
        .get();

        return snapshot.docs.map((doc) {
          return Categorymodel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
    } catch(e) {
      rethrow;
    }
  }
}
