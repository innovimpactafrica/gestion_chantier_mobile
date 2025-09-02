class MaterialTopUsedModel {
  final String materialLabel;
  final double totalUsedQuantity;

  MaterialTopUsedModel({
    required this.materialLabel,
    required this.totalUsedQuantity,
  });

  factory MaterialTopUsedModel.fromJson(Map<String, dynamic> json) {
    return MaterialTopUsedModel(
      materialLabel: json['materialLabel'] ?? '',
      totalUsedQuantity: (json['totalUsedQuantity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
