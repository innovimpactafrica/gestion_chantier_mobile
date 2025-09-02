// services/task_service.dart
import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/TaskModel.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<TaskModel> getTaskKpis({int? promoterId}) async {
    try {
      // Si promoterId n'est pas fourni, récupérer l'utilisateur courant
      int? currentPromoterId = promoterId;

      if (currentPromoterId == null) {
        final currentUser = await _authService.connectedUser();

        if (currentUser == null) {
          throw Exception('Utilisateur non authentifié');
        }

        currentPromoterId = currentUser['id'] ?? currentUser['promoterId'];

        if (currentPromoterId == null) {
          throw Exception('ID utilisateur non trouvé');
        }
      }

      // Construire l'URL avec le paramètre promoterId
      String endpoint = '/tasks/kpis';
      Map<String, dynamic> queryParameters = {'promoterId': currentPromoterId};

      final response = await _apiService.dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw Exception(
          'Erreur lors de la récupération des KPIs des tâches: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Gestion des erreurs Dio
      if (e.response != null) {
        throw Exception(
          'Erreur API: ${e.response!.statusCode} - ${e.response!.statusMessage}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de connexion');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout de réception');
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération des KPIs des tâches: $e',
      );
    }
  }

  Future<TaskModel?> getTaskKpisSafely({int? promoterId}) async {
    try {
      return await getTaskKpis(promoterId: promoterId);
    } catch (e) {
      return null;
    }
  }
}
