import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/ConstructionPhaseIndicatorModel.dart';
import 'package:gestion_chantier/manager/services/AuthService.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';

class ConstructionIndicatorService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Récupère les indicateurs de construction pour une propriété donnée
  Future<List<ConstructionPhaseIndicator>> getIndicatorsByProperty(
    int propertyId,
  ) async {
    try {
      // Vérifier l'authentification
      final currentUser = await _authService.connectedUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _apiService.dio.get(
        '/indicators/property/$propertyId',
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (json) => ConstructionPhaseIndicator.fromJson({
                'id': json['id'],
                'phaseName': json['phaseName'],
                'progressPercentage': json['progressPercentage'],
                'lastUpdated': json['lastUpdated'],
                // Note: realEstateProperty sera null car non fourni par l'API
                // Vous pouvez l'ajouter si nécessaire
                'realEstateProperty': null,
              }),
            )
            .toList();
      } else if (response.statusCode == 403) {
        throw Exception(
          'Accès refusé. Vérifiez vos permissions pour ce projet.',
        );
      } else {
        throw Exception(
          'Erreur lors de la récupération des indicateurs: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 403) {
          throw Exception(
            'Accès refusé. Vérifiez vos permissions pour ce projet.',
          );
        } else if (e.response!.statusCode == 401) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
        throw Exception(
          'Erreur API: ${e.response!.statusCode} - ${e.response!.data}',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Met à jour un indicateur de construction
  Future<ConstructionPhaseIndicator> updateIndicator(
    int id,
    int progressPercentage,
  ) async {
    try {
      // Vérifier l'authentification
      final currentUser = await _authService.connectedUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Utiliser progressPercentage comme query parameter selon l'endpoint Swagger
      final response = await _apiService.dio.put(
        '/indicators/update/$id',
        queryParameters: {'progressPercentage': progressPercentage},
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': '*/*', // Selon Swagger
          },
        ),
      );

      if (response.statusCode == 200) {
        return ConstructionPhaseIndicator.fromJson({
          'id': response.data['id'],
          'phaseName': response.data['phaseName'],
          'progressPercentage': response.data['progressPercentage'],
          'lastUpdated': response.data['lastUpdated'],
          'realEstateProperty': null,
        });
      } else if (response.statusCode == 403) {
        // Essayer avec PATCH si PUT échoue
        final patchResponse = await _apiService.dio.patch(
          '/indicators/update/$id',
          queryParameters: {'progressPercentage': progressPercentage},
          options: Options(
            validateStatus: (status) => status! < 500,
            headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
          ),
        );

        if (patchResponse.statusCode == 200) {
          return ConstructionPhaseIndicator.fromJson({
            'id': patchResponse.data['id'],
            'phaseName': patchResponse.data['phaseName'],
            'progressPercentage': patchResponse.data['progressPercentage'],
            'lastUpdated': patchResponse.data['lastUpdated'],
            'realEstateProperty': null,
          });
        } else if (patchResponse.statusCode == 403) {
          String errorMessage =
              'Vous n\'avez pas les droits pour modifier cet indicateur';
          if (patchResponse.data != null &&
              patchResponse.data is Map<String, dynamic>) {
            errorMessage =
                patchResponse.data['message'] ??
                patchResponse.data['error'] ??
                errorMessage;
          }
          throw Exception(errorMessage);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 404) {
        throw Exception('Indicateur non trouvé');
      }

      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 403) {
          String errorMessage =
              'Vous n\'avez pas les droits pour modifier cet indicateur';
          if (e.response!.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ??
                e.response!.data['error'] ??
                errorMessage;
          }
          throw Exception(errorMessage);
        } else if (e.response!.statusCode == 401) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
        throw Exception(
          'Erreur API: ${e.response!.statusCode} - ${e.response!.data}',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }
}
