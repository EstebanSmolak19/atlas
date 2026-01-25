import 'dart:convert';

class UserModel {
  final String email;
  final String pseudo;
  final int points;
  final bool premium;
  final List<String> addresses;
  final String planId;

   UserModel({
    required this.email,
    required this.pseudo,
    required this.points,
    required this.premium,
    required this.addresses,
    required this.planId
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'pseudo': pseudo,
      'points': points,
      'premium': premium,
      'adresses': addresses,
      'planId': planId
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      pseudo: map['pseudo'] as String,
      points: map['points'] as int,
      premium: map['premium'] as bool,
      addresses: List<String>.from(map['addresses'] ?? []),
      planId: map['planId'] as String
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
