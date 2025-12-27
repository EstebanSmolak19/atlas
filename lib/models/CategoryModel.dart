import 'dart:convert';

class Categorymodel {
  final String name;
  final String icon;
  final double width;
  final double top;

  Categorymodel({
    required this.name,
    required this.icon,
    required this.width,
    required this.top,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'icon': icon,
      'width': width,
      'top': top,
    };
  }

  factory Categorymodel.fromMap(Map<String, dynamic> map) {
    return Categorymodel(
      name: map['name'] as String,
      icon: map['icon'] as String,
      width: (map['width'] as num?)?.toDouble() ?? 0.0,
      top: (map['top'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Categorymodel.fromJson(String source) => Categorymodel.fromMap(json.decode(source) as Map<String, dynamic>);
}
