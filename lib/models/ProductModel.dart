import 'dart:convert';

class ProductModel {
  final double average;
  final String decription;
  final String name;
  final int rating_count;

  ProductModel({
    required this.average,
    required this.decription,
    required this.name,
    required this.rating_count
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'average': average,
      'decription': decription,
      'name': name,
      'rating_count': rating_count,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      average: (map['average'] as num?)?.toDouble() ?? 0.0,
      decription: map['description'] as String,
      name: map['name'] as String,
      rating_count: map['rating_count'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
