import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/BudgetModel.dart';
import 'package:gestion_chantier/moa/models/ExpensesModel.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';
import 'package:gestion_chantier/moa/services/api_service.dart';
import 'package:gestion_chantier/moa/services/ProjetService.dart';

import 'package:intl/intl.dart';

class BudgetService {
  static final BudgetService _instance = BudgetService._internal();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final RealEstateService _realEstateService = RealEstateService();

  factory BudgetService() {
    return _instance;
  }

  BudgetService._internal();

  Future<Map<String, dynamic>?> getBudgetDashboardKpi() async {
    try {
      final currentUser = await _authService.connectedUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final promoterId = currentUser['id'] ?? currentUser['promoterId'];
      if (promoterId == null) {
        throw Exception('ID utilisateur non trouvé');
      }

      final response = await _apiService.dio.get(
        '/budgets/dashboard/kpi',
        queryParameters: {'promoterId': promoterId},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé. Vérifiez vos permissions.');
      }

      return null;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Agrège le pourcentage de budget consommé pour tous les promoteurs (profil MOA)
  /// en itérant sur la pagination des promoteurs et en moyennant les pourcentages.
  /// NOTE: Idéalement, utiliser une agrégation backend (pondérée par budget total)
  /// car la moyenne simple peut biaiser le résultat si les budgets diffèrent.
  Future<double> getAggregatedConsumedPercentageAllPromoters({
    int pageSize = 100,
  }) async {
    try {
      final promoterIds = await _realEstateService.getAllPromoterIdsPaginated(
        pageSize: pageSize,
      );
      if (promoterIds.isEmpty) return 0.0;

      double sumPercentages = 0.0;
      int count = 0;

      for (final id in promoterIds) {
        final response = await _apiService.dio.get(
          '/budgets/dashboard/kpi',
          queryParameters: {'promoterId': id},
          options: Options(validateStatus: (status) => status! < 500),
        );
        if (response.statusCode == 200) {
          final data = response.data;
          final dynamic p =
              data is Map<String, dynamic> ? data['consumedPercentage'] : null;
          double value;
          if (p is double) {
            value = p;
          } else if (p is int) {
            value = p.toDouble();
          } else if (p is String) {
            value = double.tryParse(p) ?? 0.0;
          } else {
            value = 0.0;
          }
          sumPercentages += value;
          count += 1;
        } else if (response.statusCode == 403) {
          // Continue but log if needed
          continue;
        }
      }

      if (count == 0) return 0.0;
      return sumPercentages / count;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<BudgetModel?> getBudgetByPropertyId(int propertyId) async {
    try {
      if (propertyId <= 0) throw Exception('ID propriété invalide');

      final response = await _apiService.dio.get(
        '/budgets/property/$propertyId',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return BudgetModel.fromJson(response.data);
      } else if (response.statusCode == 403) {
        throw Exception('Permission refusée pour accéder à ce budget');
      }

      return null;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<BudgetModel?> getBudgetById(int budgetId) async {
    try {
      if (budgetId <= 0) throw Exception('ID budget invalide');

      final response = await _apiService.dio.get(
        '/budgets/$budgetId',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return BudgetModel.fromJson(response.data);
      } else if (response.statusCode == 403) {
        throw Exception('Permission refusée pour accéder à ce budget');
      } else if (response.statusCode == 404) {
        throw Exception('Budget non trouvé');
      }

      return null;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<BudgetModel?> updatePlannedBudget(int id, double newAmount) async {
    try {
      if (id <= 0) throw Exception('ID budget invalide');
      if (newAmount < 0) throw Exception('Montant négatif non autorisé');

      final currentUser = await _authService.connectedUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Utiliser le query parameter 'amont' selon l'endpoint Swagger
      final updateResponse = await _apiService.dio.put(
        '/budgets/$id',
        queryParameters: {
          'amont': newAmount, // Query parameter selon Swagger
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': '*/*', // Selon Swagger
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (updateResponse.data != null) {}

      if (updateResponse.statusCode == 200) {
        return BudgetModel.fromJson(updateResponse.data);
      } else if (updateResponse.statusCode == 403) {
        // Essayer avec PATCH si PUT échoue
        final patchResponse = await _apiService.dio.patch(
          '/budgets/$id',
          queryParameters: {'amont': newAmount},
          options: Options(
            headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
            validateStatus: (status) => status! < 500,
          ),
        );

        if (patchResponse.statusCode == 200) {
          return BudgetModel.fromJson(patchResponse.data);
        } else if (patchResponse.statusCode == 403) {
          String errorMessage =
              'Vous n\'avez pas les droits pour modifier ce budget';
          if (patchResponse.data != null &&
              patchResponse.data is Map<String, dynamic>) {
            errorMessage =
                patchResponse.data['message'] ??
                patchResponse.data['error'] ??
                errorMessage;
          }
          throw Exception(errorMessage);
        }
      } else if (updateResponse.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (updateResponse.statusCode == 404) {
        throw Exception('Budget non trouvé');
      } else if (updateResponse.statusCode == 400) {
        String errorMessage = 'Données invalides';
        if (updateResponse.data != null &&
            updateResponse.data is Map<String, dynamic>) {
          errorMessage =
              updateResponse.data['message'] ??
              updateResponse.data['error'] ??
              errorMessage;
        }
        throw Exception(errorMessage);
      }

      throw Exception(
        'Erreur lors de la mise à jour: ${updateResponse.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<BudgetModel?> addExpense(
    int budgetId,
    double amount,
    String description,
  ) async {
    try {
      if (budgetId <= 0) throw Exception('ID budget invalide');
      if (amount <= 0) throw Exception('Montant doit être positif');
      if (description.isEmpty) throw Exception('Description requise');

      // Format de date MM-dd-yyyy selon l'endpoint Swagger
      final formattedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());

      final response = await _apiService.dio.post(
        '/expenses',
        data: {
          'description': description,
          'date': formattedDate,
          'amount': amount,
          'budgetId': budgetId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': '*/*', // Selon Swagger
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // La réponse contient les données de la dépense créée
        if (response.data != null && response.data is Map<String, dynamic>) {
          final expenseData = response.data as Map<String, dynamic>;

          // Si la réponse contient les données du budget mis à jour, on peut les extraire
          if (expenseData.containsKey('budget') &&
              expenseData['budget'] is Map<String, dynamic>) {
            final budgetData = expenseData['budget'] as Map<String, dynamic>;
            return BudgetModel.fromJson(budgetData);
          } else {
            // Si pas de données de budget dans la réponse, on peut retourner null
            // ou recharger le budget séparément
            return null;
          }
        }
        return null;
      } else if (response.statusCode == 403) {
        String errorMessage =
            'Vous n\'avez pas les droits pour ajouter une dépense à ce budget';
        if (response.data != null && response.data is Map<String, dynamic>) {
          errorMessage =
              response.data['message'] ??
              response.data['error'] ??
              errorMessage;
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        String errorMessage = 'Données invalides';
        if (response.data != null && response.data is Map<String, dynamic>) {
          errorMessage =
              response.data['message'] ??
              response.data['error'] ??
              errorMessage;
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 404) {
        throw Exception('Budget non trouvé');
      }

      throw Exception(
        'Erreur lors de l\'ajout de la dépense: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Ajoute une dépense et retourne les données de la dépense créée
  Future<ExpenseModel?> createExpense(
    int budgetId,
    double amount,
    String description,
  ) async {
    try {
      if (budgetId <= 0) throw Exception('ID budget invalide');
      if (amount <= 0) throw Exception('Montant doit être positif');
      if (description.isEmpty) throw Exception('Description requise');

      // Format de date MM-dd-yyyy selon l'endpoint Swagger
      final formattedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());

      final response = await _apiService.dio.post(
        '/expenses',
        data: {
          'description': description,
          'date': formattedDate,
          'amount': amount,
          'budgetId': budgetId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': '*/*', // Selon Swagger
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // La réponse contient les données de la dépense créée
        if (response.data != null && response.data is Map<String, dynamic>) {
          final expenseData = response.data as Map<String, dynamic>;

          // Créer un ExpenseModel à partir des données reçues
          return ExpenseModel.fromJson(expenseData);
        }
        return null;
      } else if (response.statusCode == 403) {
        String errorMessage =
            'Vous n\'avez pas les droits pour ajouter une dépense à ce budget';
        if (response.data != null && response.data is Map<String, dynamic>) {
          errorMessage =
              response.data['message'] ??
              response.data['error'] ??
              errorMessage;
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        String errorMessage = 'Données invalides';
        if (response.data != null && response.data is Map<String, dynamic>) {
          errorMessage =
              response.data['message'] ??
              response.data['error'] ??
              errorMessage;
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 404) {
        throw Exception('Budget non trouvé');
      }

      throw Exception(
        'Erreur lors de l\'ajout de la dépense: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExpenseModel>> getExpenseHistory(int budgetId) async {
    try {
      if (budgetId <= 0) throw Exception('ID budget invalide');

      final response = await _apiService.dio.get(
        '/expenses/budget/$budgetId',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('content')) {
          return (data['content'] as List)
              .map((e) => ExpenseModel.fromJson(e))
              .toList();
        }
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé à l\'historique des dépenses');
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Timeout de connexion');
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            return Exception('Requête invalide');
          case 401:
            return Exception('Authentification requise');
          case 403:
            final data = e.response?.data;
            if (data is Map && data['message'] != null) {
              return Exception(data['message']);
            }
            return Exception('Accès refusé. Permissions insuffisantes.');
          case 404:
            return Exception('Ressource non trouvée');
          case 500:
            return Exception('Erreur serveur');
          default:
            return Exception('Erreur HTTP ${e.response?.statusCode}');
        }
      case DioExceptionType.cancel:
        return Exception('Requête annulée');
      default:
        return Exception('Erreur réseau');
    }
  }
}
