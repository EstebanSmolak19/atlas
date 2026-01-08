import 'package:atlas/models/CategoryModel.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //récupère toutes les catégories
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

  //récupère la liste de tous les produits avec une note >= 4.5
  Future<List<ProductModel>> getAllPopularItem() async {
    try {
      QuerySnapshot snapshot = await _db
        .collection("products")
        .where('average', isGreaterThanOrEqualTo: 4.5) 
        .orderBy('average', descending: true) // Tri du meilleur au moins bon
        .get();

      print("📦 PopularItems trouvés: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch(e) {
        rethrow;
    }
  }

}
