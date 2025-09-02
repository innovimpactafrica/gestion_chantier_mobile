import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/MaterialModel.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';

class MaterialsApiService {
  final ApiService _apiService = ApiService();

  /// Récupère tous les matériaux pour une propriété donnée
  Future<List<MaterialModel>> getMaterialsByProperty(int propertyId) async {
    try {
      final response = await _apiService.dio.get(
        '/materials/property/$propertyId',
      );

      if (response.statusCode == 200) {
        return _parseMaterialsFromResponse(response.data);
      } else {
        throw Exception(
          'Erreur lors du chargement des matériaux: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'chargement des matériaux');
    } catch (e, stackTrace) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Parse les matériaux depuis la réponse API
  List<MaterialModel> _parseMaterialsFromResponse(dynamic data) {
    if (data == null) {
      return [];
    }

    try {
      // Cas 1: La réponse est directement une liste
      if (data is List) {
        return _parseMateriausList(data);
      }

      // Cas 2: La réponse est un objet qui contient une liste
      if (data is Map<String, dynamic>) {
        // Essayer différentes clés possibles
        final possibleKeys = [
          'materials',
          'data',
          'items',
          'content',
          'results',
        ];

        for (String key in possibleKeys) {
          if (data.containsKey(key) && data[key] is List) {
            final materialsData = data[key] as List;
            return _parseMateriausList(materialsData);
          }
        }

        // Si aucune clé standard n'est trouvée, chercher la première liste
        for (var entry in data.entries) {
          if (entry.value is List) {
            final materialsData = entry.value as List;
            return _parseMateriausList(materialsData);
          }
        }

        return [];
      }

      // Cas 3: Type de données inattendu
      return [];
    } catch (e, stackTrace) {
      return [];
    }
  }

  /// Parse une liste de matériaux avec gestion d'erreur individuelle
  List<MaterialModel> _parseMateriausList(List<dynamic> materialsData) {
    final List<MaterialModel> materials = [];

    for (int i = 0; i < materialsData.length; i++) {
      try {
        final item = materialsData[i];
        if (item is Map<String, dynamic>) {
          final material = MaterialModel.fromJson(item);
          materials.add(material);
        }
      } catch (e, stackTrace) {
        print('Erreur lors du parsing du matériau $i: $e');
        print('StackTrace: $stackTrace');
        print('Données du matériau $i: ${materialsData[i]}');
        // Continue avec les autres matériaux au lieu de tout arrêter
      }
    }

    return materials;
  }

  /// Gère les exceptions Dio de manière centralisée
  List<MaterialModel> _handleDioException(DioException e, String operation) {
    if (e.response != null) {
      if (e.response?.statusCode == 404) {
        return [];
      }
    }

    throw Exception('Erreur réseau lors de $operation: ${e.message}');
  }

  /// Ajoute un nouveau matériau
  Future<MaterialModel> addMaterial(MaterialModel material) async {
    try {
      // Ne pas inclure l'ID dans la requête POST
      final materialData = material.toJson();
      materialData.remove('id'); // Supprimer l'ID pour la création

      final response = await _apiService.dio.post(
        '/materials',
        data: materialData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdMaterial = MaterialModel.fromJson(response.data);
        return createdMaterial;
      } else {
        throw Exception(
          'Erreur lors de l\'ajout du matériau: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      throw Exception('Erreur réseau lors de l\'ajout: ${e.message}');
    } catch (e, stackTrace) {
      throw Exception('Erreur inattendue lors de l\'ajout: $e');
    }
  }

  /// Met à jour un matériau existant
  Future<MaterialModel> updateMaterial(
    int materialId,
    MaterialModel material,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/materials/$materialId',
        data: material.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedMaterial = MaterialModel.fromJson(response.data);
        return updatedMaterial;
      } else {
        throw Exception(
          'Erreur lors de la mise à jour du matériau: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      throw Exception('Erreur réseau lors de la mise à jour: ${e.message}');
    } catch (e, stackTrace) {
      throw Exception('Erreur inattendue lors de la mise à jour: $e');
    }
  }

  /// Supprime un matériau par son ID
  Future<void> deleteMaterial(int materialId) async {
    try {
      final response = await _apiService.dio.delete('/materials/$materialId');
      if (response.statusCode == 200 || response.statusCode == 204) {
      } else {
        throw Exception(
          'Erreur lors de la suppression du matériau: \\${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du matériau: $e');
    }
  }

  /// Méthode utilitaire pour déboguer la structure de la réponse
  Future<void> debugApiResponse(int propertyId) async {
    try {
      final response = await _apiService.dio.get(
        '/materials/property/$propertyId',
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;

        map.forEach((key, value) {
          if (value != null) {
            final valueStr = value.toString();
            final truncatedValue =
                valueStr.length > 100
                    ? '${valueStr.substring(0, 100)}...'
                    : valueStr;
          } else {}
        });
      } else if (response.data is List) {
        final list = response.data as List;

        if (list.isNotEmpty) {}
      }
    } catch (e, stackTrace) {}
  }

  /// Ajoute un nouveau matériau à l'inventaire
  Future<MaterialModel> addMaterialToInventory({
    required String label,
    required int quantity,
    required int criticalThreshold,
    required int unitId,
    required int propertyId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/materials',
        data: {
          'label': label,
          'quantity': quantity,
          'criticalThreshold': criticalThreshold,
          'unitId': unitId,
          'propertyId': propertyId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final material = MaterialModel.fromJson(response.data);
        return material;
      } else {
        throw Exception(
          'Erreur lors de l\'ajout du matériau: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('❌ MaterialsApiService: Status Code: ${e.response?.statusCode}');
        print('❌ MaterialsApiService: Response Data: ${e.response?.data}');
      }
      throw Exception(
        'Erreur réseau lors de l\'ajout du matériau: ${e.message}',
      );
    } catch (e) {
      throw Exception('Erreur inattendue lors de l\'ajout du matériau: $e');
    }
  }

  /// Récupère toutes les unités disponibles
  Future<List<Unit>> getUnits() async {
    try {
      // Retourner les unités en dur avec les IDs spécifiés
      return [
        Unit(
          id: 5,
          label: 'Litre',
          code: 'L',
          hasStartDate: true,
          hasEndDate: true,
          type: 'UNIT',
        ),
        Unit(
          id: 6,
          label: 'Mètre cube',
          code: 'm3',
          hasStartDate: true,
          hasEndDate: true,
          type: 'UNIT',
        ),
        Unit(
          id: 7,
          label: 'Kilogramme',
          code: 'KG',
          hasStartDate: true,
          hasEndDate: true,
          type: 'UNIT',
        ),
        Unit(
          id: 9,
          label: 'Mètre',
          code: 'm',
          hasStartDate: true,
          hasEndDate: true,
          type: 'UNIT',
        ),
        Unit(
          id: 10,
          label: 'Pièce',
          code: 'pcs',
          hasStartDate: true,
          hasEndDate: true,
          type: 'UNIT',
        ),
      ];
    } catch (e) {
      throw Exception('Erreur réseau lors de la récupération des unités: $e');
    }
  }
}
