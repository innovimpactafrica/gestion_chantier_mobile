class SubscriptionPlan {
  final int id;
  final String name;
  final int totalCost;
  final int installmentCount;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.totalCost,
    required this.installmentCount,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      totalCost: json['totalCost'] ?? 0,
      installmentCount: json['installmentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "totalCost": totalCost,
      "installmentCount": installmentCount,
    };
  }
}
