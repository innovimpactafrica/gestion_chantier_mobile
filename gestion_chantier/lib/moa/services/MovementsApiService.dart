import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/services/api_service.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/inventaires/inventaires.dart';

class MovementsApiService {
  final ApiService _apiService = ApiService();

  /// Récupère tous les mouvements pour une propriété donnée
  Future<List<MovementModel>> getMovementsByProperty(int propertyId) async {
    try {
      print('Récupération des mouvements pour la propriété: $propertyId');

      final response = await _apiService.dio.get(
        '/materials/movements',
        queryParameters: {'propertyId': propertyId},
      );

      print('Movements response status: ${response.statusCode}');
      print('Movements response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        return _parseMovementsFromResponse(response.data);
      } else {
        throw Exception(
          'Erreur lors du chargement des mouvements: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'chargement des mouvements');
    } catch (e, stackTrace) {
      print('Exception générale lors du chargement des mouvements: $e');
      print('StackTrace: $stackTrace');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Parse les mouvements depuis la réponse API
  List<MovementModel> _parseMovementsFromResponse(dynamic data) {
    if (data == null) {
      print('Réponse null reçue pour les mouvements');
      return [];
    }

    try {
      // Cas 1: La réponse est directement une liste
      if (data is List) {
        print('Parsing direct d\'une liste de ${data.length} mouvements');
        return _parseMovementsList(data);
      }

      // Cas 2: La réponse est un objet qui contient une liste
      if (data is Map<String, dynamic>) {
        print('Parsing d\'un objet avec clés: ${data.keys.toList()}');

        // Essayer différentes clés possibles
        final possibleKeys = [
          'movements',
          'data',
          'items',
          'content',
          'results',
        ];

        for (String key in possibleKeys) {
          if (data.containsKey(key) && data[key] is List) {
            final movementsData = data[key] as List;
            print(
              'Mouvements trouvés sous la clé "$key" avec ${movementsData.length} éléments',
            );
            return _parseMovementsList(movementsData);
          }
        }

        // Si aucune clé standard n'est trouvée, chercher la première liste
        for (var entry in data.entries) {
          if (entry.value is List) {
            final movementsData = entry.value as List;
            print(
              'Mouvements trouvés sous la clé "${entry.key}" avec ${movementsData.length} éléments',
            );
            return _parseMovementsList(movementsData);
          }
        }

        print('Aucune liste de mouvements trouvée dans l\'objet');
        return [];
      }

      print(
        'Type de données inattendu pour les mouvements: ${data.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Erreur lors du parsing des mouvements: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }

  /// Parse une liste de mouvements avec gestion d'erreur individuelle
  List<MovementModel> _parseMovementsList(List<dynamic> movementsData) {
    final List<MovementModel> movements = [];

    for (int i = 0; i < movementsData.length; i++) {
      try {
        final item = movementsData[i];
        if (item is Map<String, dynamic>) {
          final movement = MovementModel.fromJson(item);
          movements.add(movement);
          print('Mouvement ${i + 1} parsé avec succès: ${movement.type}');
        } else {
          print(
            'Élément $i n\'est pas un Map<String, dynamic>: ${item.runtimeType}',
          );
        }
      } catch (e, stackTrace) {
        print('Erreur lors du parsing du mouvement $i: $e');
        print('StackTrace: $stackTrace');
        print('Données du mouvement $i: ${movementsData[i]}');
        // Continue avec les autres mouvements
      }
    }

    print(
      '${movements.length} mouvements parsés avec succès sur ${movementsData.length}',
    );
    return movements;
  }

  /// Gère les exceptions Dio
  List<MovementModel> _handleDioException(DioException e, String operation) {
    print('DioException lors de $operation: ${e.message}');
    print('Type d\'erreur: ${e.type}');

    if (e.response != null) {
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        print('Aucun mouvement trouvé (404) - retour d\'une liste vide');
        return [];
      }
    }

    throw Exception('Erreur réseau lors de $operation: ${e.message}');
  }

  /// Méthode utilitaire pour déboguer la réponse des mouvements
  Future<void> debugMovementsApiResponse(int propertyId) async {
    try {
      print('=== DEBUG MOVEMENTS API RESPONSE START ===');
      print('Property ID: $propertyId');

      final response = await _apiService.dio.get(
        '/materials/movements',
        queryParameters: {'propertyId': propertyId},
      );

      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Data Type: ${response.data.runtimeType}');

      if (response.data != null) {
        final dataStr = response.data.toString();
        if (dataStr.length > 1000) {
          print('Data (first 1000 chars): ${dataStr.substring(0, 1000)}...');
        } else {
          print('Data: $dataStr');
        }
      }

      print('=== DEBUG MOVEMENTS API RESPONSE END ===');
    } catch (e, stackTrace) {
      print('Debug movements error: $e');
      print('Debug movements stackTrace: $stackTrace');
    }
  }
}

/// Modèle pour les mouvements de matériaux
class MovementModel {
  final int id;
  final String type; // 'ENTRY' ou 'EXIT'
  final int quantity;
  final DateTime dateTime;
  final String? description;
  final MaterialInfo material;
  final String? chantier;

  MovementModel({
    required this.id,
    required this.type,
    required this.quantity,
    required this.dateTime,
    this.description,
    required this.material,
    this.chantier,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    try {
      return MovementModel(
        id: _parseIntSafely(json['id']),
        type: _parseStringSafely(json['type']),
        quantity: _parseIntSafely(json['quantity']),
        dateTime: _parseDateTimeSafely(json['dateTime'] ?? json['createdAt']),
        description: json['description']?.toString(),
        material: MaterialInfo.fromJson(_parseMapSafely(json['material'])),
        chantier: json['chantier']?.toString() ?? json['site']?.toString(),
      );
    } catch (e, stackTrace) {
      print('Erreur lors du parsing de MovementModel: $e');
      print('StackTrace: $stackTrace');
      print('JSON reçu: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'quantity': quantity,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'material': material.toJson(),
      'chantier': chantier,
    };
  }

  // Conversion vers le modèle Mouvement utilisé dans l'interface
  Mouvement toMouvement() {
    return Mouvement(
      type:
          type.toUpperCase() == 'ENTRY'
              ? TypeMouvement.entree
              : TypeMouvement.sortie,
      quantite: quantity,
      materiau: material.label,
      unite: material.unit,
      chantier: chantier ?? 'Chantier inconnu',
      dateHeure: dateTime,
    );
  }

  // Méthodes utilitaires
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static String _parseStringSafely(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime _parseDateTimeSafely(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is List && value.isNotEmpty) {
        // Format [année, mois, jour, heure, minute, seconde]
        if (value.length >= 3) {
          return DateTime(
            value[0] ?? DateTime.now().year,
            value[1] ?? DateTime.now().month,
            value[2] ?? DateTime.now().day,
            value.length > 3 ? (value[3] ?? 0) : 0,
            value.length > 4 ? (value[4] ?? 0) : 0,
            value.length > 5 ? (value[5] ?? 0) : 0,
          );
        }
      } else if (value is int) {
        // Timestamp en millisecondes
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      print('Erreur lors du parsing de la date: $e, valeur: $value');
    }

    return DateTime.now();
  }

  static Map<String, dynamic> _parseMapSafely(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        return {};
      }
    }
    return {};
  }
}

/// Informations basiques du matériau dans un mouvement
class MaterialInfo {
  final int id;
  final String label;
  final String unit;

  MaterialInfo({required this.id, required this.label, required this.unit});

  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    return MaterialInfo(
      id: MovementModel._parseIntSafely(json['id']),
      label: MovementModel._parseStringSafely(json['label'] ?? json['name']),
      unit: MovementModel._parseStringSafely(json['unit'] ?? json['unite']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'unit': unit};
  }
}
