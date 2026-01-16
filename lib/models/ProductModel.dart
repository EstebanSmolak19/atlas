import 'dart:convert';

class ProductModel {
  final String id;
  final double average;
  final String description;
  final String name;
  final double price;
  final int calorie;
  final int time;
  final String type;
  final int rating_count;
  final String nationality;
  final String img_url;

  ProductModel({
    required this.id,
    required this.average,
    required this.description,
    required this.name,
    required this.price,
    required this.calorie,
    required this.time,
    required this.type,
    required this.rating_count,
    required this.nationality,
    required this.img_url
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'average': average,
      'description': description, 
      'name': name,
      'price': price,   
      'calorie': calorie,
      'time': time,    
      'type': type,     
      'rating_count': rating_count,
      'nationality' : nationality,
      'img_url': img_url
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      average: (map['average'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String,
      name: map['name'] as String,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      calorie: map['calorie'] as int,
      time: map['time'] as int,
      type: map['type'] as String,
      rating_count: map['rating_count'] as int,
      nationality: map['nationality'] as String,
      img_url: map['img_url'] as String
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
