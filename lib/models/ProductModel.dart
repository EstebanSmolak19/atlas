import 'dart:convert';

class ProductModel {
  final double average;
  final String description;
  final String name;
  final double prize;
  final int calorie;
  final int time;
  final int rating_count;

  ProductModel({
    required this.average,
    required this.description,
    required this.name,
    required this.prize,
    required this.calorie,
    required this.time,
    required this.rating_count
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'average': average,
      'decription': description,
      'name': name,
      'rating_count': rating_count,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      average: (map['average'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String,
      name: map['name'] as String,
      prize: (map['prize'] as num?)?.toDouble() ?? 0.0,
      calorie: map['calorie'] as int,
      time: map['time'] as int,
      rating_count: map['rating_count'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
