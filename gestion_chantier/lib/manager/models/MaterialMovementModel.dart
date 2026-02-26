import 'package:flutter/foundation.dart';

import '../../moa/models/MaterialModel.dart' show MaterialModel;

enum MovementType { ENTRY, EXIT }

class MaterialMovementModel {
  final int id;
  final MaterialModel material;
  final double quantity;
  final MovementType type;
  final DateTime movementDate;
  final String? comment;

  MaterialMovementModel({
    required this.id,
    required this.material,
    required this.quantity,
    required this.type,
    required this.movementDate,
    this.comment,
  });

  factory MaterialMovementModel.fromJson(Map<String, dynamic> json) {
    return MaterialMovementModel(
      id: json['id'] as int,
      material: MaterialModel.fromJson(json['material']),
      quantity: (json['quantity'] as num).toDouble(),
      type: json['type'] == 'ENTRY' ? MovementType.ENTRY : MovementType.EXIT,
      movementDate: DateTime.fromMillisecondsSinceEpoch(
          (json['movementDate'] as List<dynamic>)
              .sublist(0, 6)
              .fold<int>(0, (prev, val) => prev + val as int) *
              1000), // simplification si tu veux
      comment: json['comment'] as String?,
    );
  }
}
