// models/material_kpi.dart - Updated StockItem
enum StockStatus { critique, faible, normal }

class StockItem {
  final int id;
  final String label;
  final double quantity;
  final double criticalThreshold;
  final String unitName;
  final String propertyName;
  final StockStatus status;
  final String? color;

  StockItem({
    required this.id,
    required this.label,
    required this.quantity,
    required this.criticalThreshold,
    required this.unitName,
    required this.propertyName,
    required this.status,
    this.color,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as int,
      label: json['label'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      criticalThreshold: (json['criticalThreshold'] as num).toDouble(),
      unitName: json['unitName'] as String,
      propertyName: json['propertyName'] as String,
      status: _parseStatusFromLabel(json['statusLabel'] as String?),
      color: json['color'] as String?,
    );
  }

  static StockStatus _parseStatusFromLabel(String? statusLabel) {
    if (statusLabel == null) return StockStatus.normal;

    switch (statusLabel.toLowerCase()) {
      case 'critique':
        return StockStatus.critique;
      case 'faible':
        return StockStatus.faible;
      case 'normal':
        return StockStatus.normal;
      default:
        return StockStatus.normal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'quantity': quantity,
      'criticalThreshold': criticalThreshold,
      'unitName': unitName,
      'propertyName': propertyName,
      'statusLabel': _statusToLabel(status),
      'color': color,
    };
  }

  static String _statusToLabel(StockStatus status) {
    switch (status) {
      case StockStatus.critique:
        return 'Critique';
      case StockStatus.faible:
        return 'Faible';
      case StockStatus.normal:
        return 'Normal';
    }
  }
}
