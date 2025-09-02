// services/critical_tasks_service.dart
import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/Taskcritical.dart';
import 'package:gestion_chantier/manager/services/AuthService.dart';
import 'api_service.dart';

class CriticalTasksService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Récupère toutes les tâches critiques pour le promoteur connecté
  Future<List<Task>> getCriticalTasks() async {
    try {
      final currentUser = await _authService.connectedUser();

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID utilisateur manquant');
      }

      final response = await _apiService.dio.get(
        '/tasks/critical',
        queryParameters: {'promoterId': currentUser['id']},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksData = response.data;
        print('Données reçues de l\'API: $tasksData'); // Debug

        List<Task> tasks =
            tasksData.map((taskJson) {
              try {
                return Task.fromJson(taskJson);
              } catch (e) {
                print(
                  'Erreur lors du parsing de la tâche: $taskJson, erreur: $e',
                );
                // Retourner une tâche par défaut ou ignorer
                rethrow;
              }
            }).toList();

        print('Tâches parsées: ${tasks.length}'); // Debug
        return tasks;
      } else {
        throw Exception(
          'Erreur lors de la récupération des tâches critiques: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Erreur Dio: $e'); // Debug
      _handleDioError(e);
    } catch (e) {
      print('Erreur générale: $e'); // Debug
      throw Exception(
        'Erreur inattendue lors de la récupération des tâches critiques: $e',
      );
    }
  }

  /// Version sécurisée qui retourne null en cas d'erreur mais log les erreurs
  Future<List<Task>?> getCriticalTasksSafely() async {
    try {
      final tasks = await getCriticalTasks();
      print('Tâches récupérées avec succès: ${tasks.length}'); // Debug
      return tasks;
    } catch (e) {
      print('Erreur lors de la récupération des tâches critiques: $e');
      // Au lieu de retourner null, essayons de retourner une liste vide
      // pour éviter le message "Aucune tâche critique"
      return [];
    }
  }

  /// Récupère une tâche critique spécifique par son ID
  Future<Task> getCriticalTaskById(int taskId) async {
    try {
      final currentUser = await _authService.connectedUser();

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID utilisateur manquant');
      }

      final response = await _apiService.dio.get(
        '/tasks/$taskId',
        queryParameters: {'promoterId': currentUser['id']},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final taskData = response.data;
        return Task.fromJson(taskData);
      } else {
        throw Exception(
          'Erreur lors de la récupération de la tâche critique: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération de la tâche critique: $e',
      );
    }
  }

  /// Récupère les tâches critiques filtrées par statut
  Future<List<Task>> getCriticalTasksByStatus(String status) async {
    try {
      final currentUser = await _authService.connectedUser();

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID utilisateur manquant');
      }

      final response = await _apiService.dio.get(
        '/tasks/critical',
        queryParameters: {'promoterId': currentUser['id'], 'status': status},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksData = response.data;
        return tasksData.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des tâches critiques par statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération des tâches critiques par statut: $e',
      );
    }
  }

  /// Récupère les tâches critiques en retard
  Future<List<Task>> getOverdueCriticalTasks() async {
    try {
      final currentUser = await _authService.connectedUser();

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID utilisateur manquant');
      }

      final response = await _apiService.dio.get(
        '/tasks/critical/overdue',
        queryParameters: {'promoterId': currentUser['id']},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksData = response.data;
        return tasksData.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des tâches critiques en retard: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération des tâches critiques en retard: $e',
      );
    }
  }

  /// Récupère le nombre de tâches critiques
  Future<int> getCriticalTasksCount() async {
    try {
      final currentUser = await _authService.connectedUser();

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID utilisateur manquant');
      }

      final response = await _apiService.dio.get(
        '/tasks/critical/count',
        queryParameters: {'promoterId': currentUser['id']},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int;
      } else {
        throw Exception(
          'Erreur lors de la récupération du nombre de tâches critiques: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération du nombre de tâches critiques: $e',
      );
    }
  }

  /// Gestion centralisée des erreurs Dio
  Never _handleDioError(DioException e) {
    String errorMessage;

    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          errorMessage = 'Requête invalide (400)';
          break;
        case 401:
          errorMessage = 'Non autorisé - Erreur d\'authentification (401)';
          break;
        case 403:
          errorMessage =
              'Accès interdit - Vérifiez la configuration du serveur (403)';
          break;
        case 404:
          errorMessage =
              'Endpoint non trouvé - Vérifiez l\'URL de l\'API (404)';
          break;
        case 422:
          errorMessage = 'Données invalides (422)';
          break;
        case 429:
          errorMessage = 'Trop de requêtes - Veuillez patienter (429)';
          break;
        case 500:
          errorMessage = 'Erreur serveur interne (500)';
          break;
        case 502:
          errorMessage = 'Passerelle incorrecte (502)';
          break;
        case 503:
          errorMessage = 'Service indisponible (503)';
          break;
        default:
          errorMessage =
              'Erreur API: ${e.response!.statusCode} - ${e.response!.statusMessage}';
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              'Délai de connexion dépassé - Vérifiez votre connexion internet';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Délai de réception dépassé - Le serveur met trop de temps à répondre';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Délai d\'envoi dépassé';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Requête annulée';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Erreur de connexion - Vérifiez votre connexion internet';
          break;
        case DioExceptionType.unknown:
        default:
          errorMessage = 'Erreur de connexion inconnue';
          if (e.message?.contains('SocketException') == true) {
            errorMessage =
                'Impossible de se connecter au serveur - Vérifiez votre connexion internet';
          }
      }
    }

    throw Exception(errorMessage);
  }
}
