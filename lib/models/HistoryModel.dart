import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final DateTime date;
  final List<Map<String, dynamic>> items;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.date,
    required this.items,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return HistoryModel(
      id: docId,
      userId: map['userId'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'En cours',
      date: (map['date'] as Timestamp).toDate(),
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'total': total,
      'status': status,
      'date': Timestamp.fromDate(date),
      'items': items,
    };
  }
}