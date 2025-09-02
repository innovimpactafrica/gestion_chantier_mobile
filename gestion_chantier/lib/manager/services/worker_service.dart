// services/worker_service.dart
import 'package:gestion_chantier/manager/models/WorkerModel.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';

class WorkerService {
  final ApiService _apiService = ApiService();

  Future<List<WorkerModel>> getWorkersByProperty(int propertyId) async {
    try {
      final response = await _apiService.dio.get(
        '/workers/property/$propertyId',
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        List<dynamic> workersJson = [];

        // Gestion des différents formats de réponse
        if (responseData is Map<String, dynamic>) {
          // Vérifier si la réponse contient un champ 'content' (votre cas)
          if (responseData.containsKey('content') &&
              responseData['content'] is List) {
            workersJson = responseData['content'];
          }
          // Vérifier si la réponse contient un champ 'data'
          else if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            workersJson = responseData['data'];
          }
          // Vérifier si la réponse contient un champ 'workers'
          else if (responseData.containsKey('workers') &&
              responseData['workers'] is List) {
            workersJson = responseData['workers'];
          }
          // Si c'est un objet unique, le mettre dans une liste
          else if (responseData.containsKey('id')) {
            workersJson = [responseData];
          } else {
            throw Exception('Structure de réponse non reconnue');
          }
        }
        // Si c'est directement une liste
        else if (responseData is List) {
          workersJson = responseData;
        } else {
          throw Exception(
            'Format de réponse inattendu: ${responseData.runtimeType}',
          );
        }

        // Convertir les données JSON en objets WorkerModel
        final List<WorkerModel> workers = [];
        for (final json in workersJson) {
          try {
            if (json is Map<String, dynamic>) {
              workers.add(WorkerModel.fromJson(json));
            }
          } catch (e) {
            print('Erreur lors de la conversion d\'un worker: $e');
            print('JSON problématique: $json');
            // Continue avec les autres workers même si un échoue
            continue;
          }
        }

        return workers;
      } else {
        throw Exception(
          'Erreur lors de la récupération des workers: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getWorkersByProperty: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère la liste des sous-traitants (fournisseurs) pour un manager donné
  Future<List<WorkerModel>> getSubcontractors(
    int managerId, {
    int page = 0,
    int size = 30,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/workers/$managerId/subcontractors',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['content'] ?? response.data;
        return data.map((json) => WorkerModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des fournisseurs: \\${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur lors de la récupération des fournisseurs: $e');
      throw Exception('Erreur lors de la récupération des fournisseurs: $e');
    }
  }
}
