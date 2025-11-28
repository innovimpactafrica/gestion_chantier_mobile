import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/CommandeModel.dart';
import 'package:gestion_chantier/moa/models/MaterialModel.dart';

import 'package:gestion_chantier/moa/models/DeliveryModel.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';
import 'package:gestion_chantier/moa/services/api_service.dart';

class CommandeService {
  final ApiService _apiService = ApiService();

  /// Récupère les commandes en attente pour une propriété donnée
  Future<List<CommandeModel>> getPendingOrders(int propertyId) async {
    try {
      print('Fetching pending orders for property: $propertyId');

      final response = await _apiService.dio.get(
        '/orders/property/$propertyId/pending',
      );

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<CommandeModel> commandes = _parseCommandesResponse(
          response.data,
        );
        print('Successfully parsed ${commandes.length} commandes');
        return commandes;
      } else {
        throw Exception(
          'Erreur HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('DioException in getPendingOrders: $e');
      print('DioException type: ${e.type}');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');

      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      print('General Exception in getPendingOrders: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur inattendue lors du chargement des commandes: $e');
    }
  }

  /// Parse la réponse pour extraire les commandes
  List<CommandeModel> _parseCommandesResponse(dynamic responseData) {
    if (responseData == null) {
      print('Response data is null, returning empty list');
      return [];
    }

    List<dynamic> dataList = [];

    try {
      if (responseData is Map<String, dynamic>) {
        print('Response is a Map with keys: ${responseData.keys.toList()}');

        // Vérifier les différents formats de réponse possibles
        if (responseData.containsKey('content')) {
          final content = responseData['content'];
          dataList = _extractListFromField(content, 'content');
        } else if (responseData.containsKey('data')) {
          final data = responseData['data'];
          dataList = _extractListFromField(data, 'data');
        } else if (responseData.containsKey('orders')) {
          final orders = responseData['orders'];
          dataList = _extractListFromField(orders, 'orders');
        } else if (responseData.containsKey('results')) {
          final results = responseData['results'];
          dataList = _extractListFromField(results, 'results');
        } else {
          // Si c'est un objet unique, l'envelopper dans une liste
          dataList = [responseData];
          print('Treating response as single object');
        }
      } else if (responseData is List<dynamic>) {
        dataList = responseData;
        print('Response is a direct list with ${dataList.length} items');
      } else {
        throw Exception(
          'Format de réponse non supporté: ${responseData.runtimeType}',
        );
      }

      print('Processing ${dataList.length} items from dataList');

      // Convertir chaque élément en CommandeModel
      final List<CommandeModel> commandes = [];
      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        print('Processing item $i: ${item.runtimeType}');

        if (item is Map<String, dynamic>) {
          try {
            final commande = CommandeModel.fromJson(item);
            commandes.add(commande);
            print(
              'Successfully created CommandeModel $i: ${commande.toString()}',
            );
          } catch (e, stackTrace) {
            print('Error creating CommandeModel from item $i: $e');
            print('Item data: $item');
            print('Stack trace: $stackTrace');
            // Continue avec les autres éléments au lieu de faire échouer toute l'opération
            continue;
          }
        } else if (item != null) {
          print('Skipping item $i: invalid type ${item.runtimeType}');
        }
      }

      return commandes;
    } catch (e, stackTrace) {
      print('Error in _parseCommandesResponse: $e');
      print('Stack trace: $stackTrace');
      print('Response data: $responseData');
      rethrow;
    }
  }

  /// Extrait une liste à partir d'un champ de réponse
  List<dynamic> _extractListFromField(dynamic field, String fieldName) {
    print(
      'Extracting list from field "$fieldName", type: ${field.runtimeType}',
    );

    if (field == null) {
      print('Field "$fieldName" is null, returning empty list');
      return [];
    } else if (field is List<dynamic>) {
      print('Field "$fieldName" is a list with ${field.length} items');
      return field;
    } else {
      print('Field "$fieldName" is not a list, wrapping single object');
      return [field];
    }
  }

  /// Ajoute une nouvelle commande
  Future<CommandeModel> addOrder({
    required int supplierId,
    required List<MaterialModel> materials,
    required int propertyId,
    DateTime? deliveryDate,
  }) async {
    try {
      print('Adding new order for supplier: $supplierId');

      // Import AuthService to get current user
      final AuthService authService = AuthService();
      final currentUser = await authService.connectedUser();
      print('Current user: $currentUser');

      final requestData = {
        'supplierId': supplierId,
        'materials':
            materials.map((material) => material.toOrderJson()).toList(),
      };

      print('Request data: $requestData');

      final response = await _apiService.dio.post(
        '/orders',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': '*/*',
            'User-Agent': 'curl/7.64.1',
          },
        ),
      );

      print('Add order response status: ${response.statusCode}');
      print('Add order response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final CommandeModel newCommande = _parseCommandeResponse(response.data);
        print(
          'Successfully created new commande: [32m${newCommande.toString()}[0m',
        );
        return newCommande;
      } else {
        throw Exception(
          'Erreur HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('DioException in addOrder: $e');
      print('Response data: \\n${e.response?.data}');
      print('Response headers: ${e.response?.headers}');
      print('Response status message: ${e.response?.statusMessage}');
      // Ajout debug message serveur
      if (e.response?.data is Map<String, dynamic> &&
          e.response?.data['message'] != null) {
        print('[DEBUG][SERVER MESSAGE] ${e.response?.data['message']}');
      }
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      print('General Exception in addOrder: $e');
      print('Stack trace: $stackTrace');
      throw Exception(
        'Erreur inattendue lors de la création de la commande: $e',
      );
    }
  }

  /// Parse la réponse pour une commande unique
  CommandeModel _parseCommandeResponse(dynamic responseData) {
    if (responseData == null) {
      throw Exception('Réponse vide du serveur');
    }

    Map<String, dynamic> commandeData;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          commandeData = data;
        } else {
          throw Exception('Format de données invalide dans la réponse');
        }
      } else if (responseData.containsKey('order')) {
        final order = responseData['order'];
        if (order is Map<String, dynamic>) {
          commandeData = order;
        } else {
          throw Exception('Format de commande invalide dans la réponse');
        }
      } else {
        commandeData = responseData;
      }
    } else {
      throw Exception('Format de réponse inattendu pour la création');
    }

    return CommandeModel.fromJson(commandeData);
  }

  /// Gère les erreurs Dio
  String _handleDioError(DioException e) {
    print('Handling DioException: ${e.type}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
      case DioExceptionType.sendTimeout:
        return 'Délai d\'envoi dépassé. Veuillez réessayer.';
      case DioExceptionType.receiveTimeout:
        return 'Délai de réception dépassé. Le serveur met trop de temps à répondre.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        String message = 'Erreur serveur';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'].toString();
        } else if (responseData is String) {
          message = responseData;
        }

        return 'Erreur $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.connectionError:
        return 'Problème de connexion réseau. Vérifiez votre connexion internet.';
      case DioExceptionType.badCertificate:
        return 'Problème de certificat SSL';
      case DioExceptionType.unknown:
        return 'Erreur réseau inconnue: ${e.message ?? 'Aucun détail disponible'}';
    }
  }

  /// Méthode pour tester la connexion API
  Future<bool> testConnection() async {
    try {
      print('Testing API connection...');
      final response = await _apiService.dio.get('/health');
      final isConnected = response.statusCode == 200;
      print('Connection test result: $isConnected');
      return isConnected;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  Future<List<DeliveryModel>> fetchDeliveries(
    int propertyId, {
    int page = 0,
    int size = 10,
  }) async {
    final response = await _apiService.dio.get(
      '/orders/property/$propertyId/delivery',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data['content'] as List;
    return data.map((e) => DeliveryModel.fromJson(e)).toList();
  }
}
