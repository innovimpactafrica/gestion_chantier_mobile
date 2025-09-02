// services/materials_service.dart
import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/material_kpi.dart';
import 'package:gestion_chantier/manager/models/material_monthly_stat.dart';
import 'package:gestion_chantier/manager/services/AuthService.dart';
import 'api_service.dart';
import 'package:gestion_chantier/manager/models/MaterialTopUsedModel.dart';

class MaterialsService {
  static final MaterialsService _instance = MaterialsService._internal();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  factory MaterialsService() {
    return _instance;
  }

  MaterialsService._internal();

  /// Récupère les matériaux critiques pour les alertes de stock
  Future<List<StockItem>> getCriticalMaterials() async {
    try {
      print('🔍 MaterialsService: Starting getCriticalMaterials...');
      print('🔍 MaterialsService: Checking user authentication...');

      // Récupérer l'utilisateur courant
      final currentUser = await _authService.connectedUser();

      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Extract promoterId from the user data (which is a Map)
      final promoterId = currentUser['id'] ?? currentUser['promoterId'];

      if (promoterId == null) {
        throw Exception('ID utilisateur non trouvé');
      }

      print('🔍 MaterialsService: User ID found: $promoterId');

      final response = await _apiService.dio.get(
        '/materials/critical',
        queryParameters: {'promoterId': promoterId},
      );

      print('🔍 MaterialsService: API Response status: ${response.statusCode}');
      print(
        '🔍 MaterialsService: API Response data type: ${response.data.runtimeType}',
      );
      print('🔍 MaterialsService: API Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ MaterialsService: Critical materials loaded successfully');

        // Handle different response structures
        List<dynamic> materialsData;

        if (response.data is List) {
          // Direct list response
          materialsData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          // Response wrapped in an object
          final Map<String, dynamic> responseMap =
              response.data as Map<String, dynamic>;

          // Common API response patterns
          if (responseMap.containsKey('content')) {
            // Paginated response (Spring Boot style)
            materialsData = responseMap['content'] as List<dynamic>? ?? [];
          } else if (responseMap.containsKey('data')) {
            materialsData = responseMap['data'] as List<dynamic>? ?? [];
          } else if (responseMap.containsKey('materials')) {
            materialsData = responseMap['materials'] as List<dynamic>? ?? [];
          } else if (responseMap.containsKey('items')) {
            materialsData = responseMap['items'] as List<dynamic>? ?? [];
          } else if (responseMap.containsKey('results')) {
            materialsData = responseMap['results'] as List<dynamic>? ?? [];
          } else {
            // If none of the common keys are found, log the keys and return empty list
            print(
              '⚠️ MaterialsService: Unexpected response structure. Keys: ${responseMap.keys}',
            );
            materialsData = [];
          }
        } else {
          print(
            '⚠️ MaterialsService: Unexpected response type: ${response.data.runtimeType}',
          );
          materialsData = [];
        }

        print('🔍 MaterialsService: Found ${materialsData.length} materials');

        return materialsData
            .map((json) {
              try {
                return StockItem.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print(
                  '❌ MaterialsService: Error parsing material: $json, Error: $e',
                );
                return null;
              }
            })
            .where((item) => item != null)
            .cast<StockItem>()
            .toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des matériaux critiques',
        );
      }
    } on DioException catch (e) {
      print('❌ MaterialsService: DioException: ${e.message}');
      print('❌ MaterialsService: Response: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ MaterialsService: Unexpected error: $e');
      print('❌ MaterialsService: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Gestion des exceptions Dio
  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Endpoint non trouvé');
    } else if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Timeout de connexion');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return Exception('Timeout de réception');
    } else {
      return Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère la distribution des matériaux par unité pour une propriété
  Future<Map<String, double>> getUnitDistributionByProperty(
    int propertyId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/materials/kpis/unit-distribution/property/$propertyId',
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return (response.data as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
      } else {
        throw Exception(
          'Erreur lors de la récupération de la distribution des matériaux',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère les stats mensuelles d'entrées/sorties de matériaux pour une propriété
  Future<List<MaterialMonthlyStat>> getMonthlyStats(int propertyId) async {
    try {
      final response = await _apiService.dio.get(
        '/materials/monthly-stats',
        queryParameters: {'propertyId': propertyId},
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (json) =>
                  MaterialMonthlyStat.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des stats mensuelles');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<List<MaterialTopUsedModel>> fetchTopUsedMaterials(
    int propertyId,
  ) async {
    final response = await _apiService.dio.get(
      '/materials/kpi/top-used',
      queryParameters: {'propertyId': propertyId},
    );
    final data = response.data as List;
    return data.map((e) => MaterialTopUsedModel.fromJson(e)).toList();
  }
}
