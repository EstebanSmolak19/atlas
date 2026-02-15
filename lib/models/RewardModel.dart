class RewardModel {
  final String id;
  final String title;
  final String description;
  final int cost;
  final List<String> productIds;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.productIds,
  });

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      cost: map['cost'] ?? 0,
      productIds: List<String>.from(map['productIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
      'productIds': productIds,
    };
  }
}