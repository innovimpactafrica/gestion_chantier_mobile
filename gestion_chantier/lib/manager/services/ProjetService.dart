// services/real_estate_service.dart
import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';

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
