import 'dart:convert';

class UserModel {
  final String email;
  final String pseudo;
  final int points;
  final bool premium;

   UserModel({
    required this.email,
    required this.pseudo,
    required this.points,
    required this.premium,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'pseudo': pseudo,
      'points': points,
      'premium': premium,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      pseudo: map['pseudo'] as String,
      points: map['points'] as int,
      premium: map['premium'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
