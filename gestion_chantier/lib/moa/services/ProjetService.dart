// services/real_estate_service.dart
import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/services/api_service.dart';

class RealEstateService {
  static final RealEstateService _instance = RealEstateService._internal();
  final ApiService _apiService = ApiService();

  factory RealEstateService() {
    return _instance;
  }

  RealEstateService._internal();

  Future<List<RealEstateModel>> getPromoterProjects(int promoterId) async {
    try {
      final response = await _apiService.dio.post(
        '/realestate/search-by-promoter',
        data: {'promoterId': promoterId},
        options: Options(
          headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['content'] ?? response.data;
        return RealEstateModel.fromJsonList(data);
      } else {
        throw Exception(
          'Erreur lors de la récupération des projets: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Agrège les projets de plusieurs promoteurs quand il n'existe pas
  /// d'endpoint qui retourne tous les projets.
  ///
  /// Utilisation:
  ///   final ids = await promoterService.getAllPromoterIds();
  ///   final all = await RealEstateService().getAllProjectsByPromoterIds(ids);
  Future<List<RealEstateModel>> getAllProjectsByPromoterIds(
    List<int> promoterIds,
  ) async {
    if (promoterIds.isEmpty) return [];

    try {
      final results = await Future.wait(
        promoterIds.map((id) => getPromoterProjects(id)),
      );

      // Aplatit la liste de listes
      final List<RealEstateModel> merged = [
        for (final list in results) ...list,
      ];

      // Optionnel: dédoublonnage si nécessaire en fonction d'un champ id
      // final Map<int, RealEstateModel> byId = {
      //   for (final p in merged) p.id: p,
      // };
      // return byId.values.toList();

      return merged;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'agrégation des projets: $e');
    }
  }

  /// Récupère tous les IDs des promoteurs via l'endpoint paginé /user/by-profil
  /// en itérant sur toutes les pages.
  Future<List<int>> getAllPromoterIdsPaginated({
    int pageSize = 100,
    String sort = 'nom',
  }) async {
    final List<int> promoterIds = [];
    int currentPage = 0;
    bool last = false;

    try {
      while (!last) {
        final response = await _apiService.dio.get(
          '/v1/user/by-profil',
          queryParameters: {
            'profil': 'PROMOTEUR',
            'page': currentPage,
            'size': pageSize,
            'sort': sort,
          },
          options: Options(headers: {'accept': '*/*'}),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> content = data['content'] ?? [];
          for (final item in content) {
            if (item is Map<String, dynamic>) {
              final id = item['id'];
              if (id is int) promoterIds.add(id);
            }
          }
          // Fallback to 'last' boolean at root if available
          last = (data['last'] == true);
          // Safety: if structure changes, stop if no content returned
          if (content.isEmpty) last = true;
          currentPage += 1;
        } else {
          throw Exception(
            'Erreur pagination promoteurs: ${response.statusCode}',
          );
        }
      }
      return promoterIds;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des promoteurs: $e');
    }
  }

  /// Raccourci: récupère tous les projets de tous les promoteurs en utilisant
  /// la pagination des utilisateurs par profil PROMOTEUR.
  Future<List<RealEstateModel>> getAllProjectsForAllPromoters({
    int pageSize = 100,
  }) async {
    final ids = await getAllPromoterIdsPaginated(pageSize: pageSize);
    return getAllProjectsByPromoterIds(ids);
  }

  /// KPI statut des chantiers pour un promoteur donné
  Future<Map<String, int>> getStatusKpiByPromoter(int promoterId) async {
    try {
      final response = await _apiService.dio.get(
        '/realestate/kpi/status',
        queryParameters: {'promoterId': promoterId},
        options: Options(headers: {'accept': '*/*'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Normalise en Map<String, int>
        final Map<String, int> result = {};
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            if (value is int) {
              result[key] = value;
            } else if (value is String) {
              result[key] = int.tryParse(value) ?? 0;
            } else {
              result[key] = 0;
            }
          });
        }
        return result;
      }
      throw Exception('Erreur KPI statut: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue KPI: $e');
    }
  }

  /// Agrège les KPI statut pour tous les promoteurs (via pagination des promoteurs)
  Future<Map<String, int>> getAggregatedStatusKpiAllPromoters({
    int pageSize = 100,
  }) async {
    final ids = await getAllPromoterIdsPaginated(pageSize: pageSize);
    final Map<String, int> aggregated = {};
    for (final id in ids) {
      final kpi = await getStatusKpiByPromoter(id);
      kpi.forEach((key, value) {
        aggregated.update(key, (prev) => prev + value, ifAbsent: () => value);
      });
    }
    return aggregated;
  }

  /// Récupère les projets filtrés par statut
  Future<List<RealEstateModel>> getProjectsByStatus(
    String status,
    int promoterId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/realestate/search-by-promoter',
        queryParameters: {'status': status},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return RealEstateModel.fromJsonList(data);
      } else {
        throw Exception(
          'Erreur lors de la récupération des projets par statut',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Recherche des projets par nom ou adresse
  Future<List<RealEstateModel>> searchProjects(String query) async {
    try {
      final response = await _apiService.dio.get(
        '/realestate/search-by-promoter',
        queryParameters: {'search': query},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return RealEstateModel.fromJsonList(data);
      } else {
        throw Exception('Erreur lors de la recherche de projets');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour un projet existant
  Future<RealEstateModel> updateProject(
    int projectId,
    Map<String, dynamic> projectData,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/realestate/$projectId',
        data: projectData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return RealEstateModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour du projet');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Gère les exceptions Dio de manière centralisée
  Exception _handleDioException(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 401:
          return Exception('Session expirée, veuillez vous reconnecter');
        case 403:
          return Exception('Accès refusé');
        case 404:
          return Exception('Ressource non trouvée');
        case 422:
          return Exception('Données invalides');
        case 500:
          return Exception('Erreur serveur, veuillez réessayer plus tard');
        default:
          return Exception(
            'Erreur: ${e.response!.statusCode} - ${e.response!.statusMessage}',
          );
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception(
        'Timeout de connexion, vérifiez votre connexion internet',
      );
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return Exception('Timeout de réception, veuillez réessayer');
    } else if (e.type == DioExceptionType.unknown) {
      return Exception('Pas de connexion internet');
    } else {
      return Exception('Erreur de réseau: ${e.message}');
    }
  }
}
