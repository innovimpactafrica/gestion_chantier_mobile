import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/models/PropertyType.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/stock/Tab2/inventaires/inventaires.dart';

enum Type { ENTRY, EXIT }

class MaterialModel {
  final int id;
  final String label;
  final int quantity;
  final int criticalThreshold;
  final List<int> createdAt;
  final Unit unit;
  final PropertyType property;

  MaterialModel({
    required this.id,
    required this.label,
    required this.quantity,
    required this.criticalThreshold,
    required this.createdAt,
    required this.unit,
    required this.property,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: _parseIntSafely(json['id']),
      label: _parseStringSafely(json['label']),
      quantity: _parseIntSafely(json['quantity']),
      criticalThreshold: _parseIntSafely(json['criticalThreshold']),
      createdAt: _parseIntListSafely(json['createdAt']),
      unit: Unit.fromJson(_parseMapSafely(json['unit'])),
      property: PropertyType.fromJson(_parseMapSafely(json['property'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'quantity': quantity,
      'criticalThreshold': criticalThreshold,
      'createdAt': createdAt,
      'unit': unit.toJson(),
      'property': property.toJson(),
    };
  }

  // Méthodes utilitaires pour parser en sécurité avec gestion améliorée des null
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseStringSafely(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static List<int> _parseIntListSafely(dynamic value) {
    if (value is List) return value.map((e) => _parseIntSafely(e)).toList();
    return [];
  }

  static Map<String, dynamic> _parseMapSafely(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  // Méthode pour déterminer le statut du matériau
  StatutMateriau get statut {
    if (quantity <= criticalThreshold) {
      return StatutMateriau.critique;
    } else if (quantity <= (criticalThreshold * 1.5)) {
      return StatutMateriau.avertissement;
    } else {
      return StatutMateriau.normal;
    }
  }

  // Conversion vers le modèle Materiau utilisé dans l'interface
  Materiau toMateriau() {
    final iconData = _getIconForMaterial(label);
    return Materiau(
      id: id,
      nom: label.isEmpty ? 'Matériau sans nom' : label,
      quantiteActuelle: quantity,
      seuil: criticalThreshold,
      unite: unit.code.isEmpty ? 'unité' : unit.code,
      icon: iconData.icon,
      iconColor: iconData.color,
      statut: statut,
    );
  }

  static ({IconData icon, Color color}) _getIconForMaterial(String name) {
    final n = name.toLowerCase();
    if (n.contains('b\u00e9ton') || n.contains('beton') || n.contains('concrete')) {
      return (icon: Icons.foundation, color: const Color(0xFF6B7280));
    } else if (n.contains('ciment') || n.contains('cement')) {
      return (icon: Icons.science, color: const Color(0xFF8B5CF6));
    } else if (n.contains('carrelage') || n.contains('carreau') || n.contains('tile')) {
      return (icon: Icons.grid_4x4, color: const Color(0xFF0EA5E9));
    } else if (n.contains('sable') || n.contains('sand')) {
      return (icon: Icons.terrain, color: const Color(0xFFF59E0B));
    } else if (n.contains('pl\u00e2tre') || n.contains('platre') || n.contains('plaster')) {
      return (icon: Icons.format_paint, color: const Color(0xFFEC4899));
    } else if (n.contains('fil') || n.contains('wire') || n.contains('c\u00e2ble') || n.contains('cable')) {
      return (icon: Icons.cable, color: const Color(0xFFEF4444));
    } else if (n.contains('planche') || n.contains('bois') || n.contains('wood') || n.contains('board')) {
      return (icon: Icons.carpenter, color: const Color(0xFF92400E));
    } else if (n.contains('fer') || n.contains('acier') || n.contains('steel') || n.contains('iron')) {
      return (icon: Icons.hardware, color: const Color(0xFF475569));
    } else if (n.contains('peinture') || n.contains('paint')) {
      return (icon: Icons.brush, color: const Color(0xFF10B981));
    } else if (n.contains('brique') || n.contains('brick')) {
      return (icon: Icons.view_module, color: const Color(0xFFDC2626));
    } else if (n.contains('verre') || n.contains('glass')) {
      return (icon: Icons.window, color: const Color(0xFF06B6D4));
    } else if (n.contains('tuyau') || n.contains('pipe') || n.contains('tube')) {
      return (icon: Icons.plumbing, color: const Color(0xFF3B82F6));
    } else if (n.contains('colle') || n.contains('glue')) {
      return (icon: Icons.water_drop, color: const Color(0xFFF97316));
    } else {
      return (icon: Icons.inventory_2, color: const Color(0xFF6B7280));
    }
  }

  @override
  String toString() {
    return 'MaterialModel(id: $id, label: $label, quantity: $quantity, criticalThreshold: $criticalThreshold)';
  }

  // Pour l'API d'ajout de commande
  Map<String, dynamic> toOrderJson() {
    return {'materialId': id, 'quantity': quantity};
  }
}

class Unit {
  final int id;
  final String label;
  final String code;
  final bool hasStartDate;
  final bool hasEndDate;
  final String type;

  Unit({
    required this.id,
    required this.label,
    required this.code,
    required this.hasStartDate,
    required this.hasEndDate,
    required this.type,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    try {
      return Unit(
        id: MaterialModel._parseIntSafely(json['id']),
        label: MaterialModel._parseStringSafely(json['label']),
        code: MaterialModel._parseStringSafely(json['code']),
        hasStartDate: json['hasStartDate'] == true,
        hasEndDate: json['hasEndDate'] == true,
        type: MaterialModel._parseStringSafely(json['type']),
      );
    } catch (e, stackTrace) {
      print('Erreur lors du parsing de Unit: $e');
      print('StackTrace: $stackTrace');
      print('JSON reçu: $json');

      // Créer une unité par défaut en cas d'erreur
      print('Création d\'une unité par défaut due à l\'erreur de parsing');
      return Unit(
        id: 0,
        label: 'Unité par défaut',
        code: 'unit',
        hasStartDate: false,
        hasEndDate: false,
        type: 'default',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'code': code,
      'hasStartDate': hasStartDate,
      'hasEndDate': hasEndDate,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'Unit(id: $id, label: $label, code: $code)';
  }
}
