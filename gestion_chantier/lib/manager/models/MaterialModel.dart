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
    try {
      print('Parsing MaterialModel from JSON: $json');

      return MaterialModel(
        id: _parseIntSafely(json['id']),
        label: _parseStringSafely(json['label']),
        quantity: _parseIntSafely(json['quantity']),
        criticalThreshold: _parseIntSafely(json['criticalThreshold']),
        createdAt: _parseIntListSafely(json['createdAt']),
        unit: Unit.fromJson(_parseMapSafely(json['unit'])),
        property: PropertyType.fromJson(_parseMapSafely(json['property'])),
      );
    } catch (e, stackTrace) {
      print('Erreur lors du parsing de MaterialModel: $e');
      print('StackTrace: $stackTrace');
      print('JSON reçu: $json');

      // Log des valeurs nulles spécifiques
      json.forEach((key, value) {
        if (value == null) {
          print('Valeur null trouvée pour la clé: $key');
        }
      });

      rethrow;
    }
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
    if (value == null) {
      print('Warning: Parsing null value as int, returning 0');
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        print('Warning: Could not parse string "$value" as int, returning 0');
        return 0;
      }
      return parsed;
    }
    if (value is double) return value.toInt();
    print(
      'Warning: Unexpected type ${value.runtimeType} for int parsing, returning 0',
    );
    return 0;
  }

  static String _parseStringSafely(dynamic value) {
    if (value == null) {
      print('Warning: Parsing null value as string, returning empty string');
      return '';
    }
    return value.toString();
  }

  static List<int> _parseIntListSafely(dynamic value) {
    if (value == null) {
      print('Warning: Parsing null value as int list, returning empty list');
      return [];
    }
    if (value is List) {
      return value.map((e) => _parseIntSafely(e)).toList();
    }
    print(
      'Warning: Expected List but got ${value.runtimeType}, returning empty list',
    );
    return [];
  }

  static Map<String, dynamic> _parseMapSafely(dynamic value) {
    if (value == null) {
      print('Warning: Parsing null value as map, returning empty map');
      return {};
    }
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        print('Warning: Could not convert Map to Map<String, dynamic>: $e');
        return {};
      }
    }
    print(
      'Warning: Expected Map but got ${value.runtimeType}, returning empty map',
    );
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
    return Materiau(
      id: id,
      nom: label.isEmpty ? 'Matériau sans nom' : label,
      quantiteActuelle: quantity,
      seuil: criticalThreshold,
      unite: unit.code.isEmpty ? 'unité' : unit.code,
      icone: _getIconForMaterial(label),
      statut: statut,
    );
  }

  // Méthode pour obtenir l'icône appropriée selon le type de matériau
  IconData _getIconForMaterial(String materialName) {
    final name = materialName.toLowerCase();
    if (name.contains('ciment') || name.contains('cement')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('fer') ||
        name.contains('iron') ||
        name.contains('acier')) {
      return Icons.bar_chart;
    } else if (name.contains('beton') || name.contains('concrete')) {
      return Icons.foundation;
    } else if (name.contains('carrelage') || name.contains('tile')) {
      return Icons.grid_view;
    } else if (name.contains('bois') || name.contains('wood')) {
      return Icons.nature;
    } else if (name.contains('peinture') || name.contains('paint')) {
      return Icons.brush;
    } else if (name.contains('tuyau') || name.contains('pipe')) {
      return Icons.plumbing;
    } else {
      return Icons.inventory_2_outlined;
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
