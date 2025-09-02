import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/Rapport.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';

class RapportService {
  final ApiService _apiService = ApiService();

  /// Récupère tous les rapports pour une propriété donnée
  Future<List<RapportModel>> getAlbumsByProperty(int id) async {
    try {
      final response = await _apiService.dio.get('/rapports/$id');

      if (response.statusCode == 200) {
        // Gérer les différents formats de réponse
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // Si la réponse contient une clé 'content' (comme dans votre exemple)
          if (data.containsKey('content') && data['content'] is List) {
            final List<dynamic> contentList = data['content'];
            return contentList
                .map(
                  (json) => RapportModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
          }
          // Si la réponse contient une clé 'data'
          else if (data.containsKey('data') && data['data'] is List) {
            final List<dynamic> dataList = data['data'];
            return dataList
                .map(
                  (json) => RapportModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
          }
          // Si la réponse est directement un objet avec les données
          else {
            // Essayer de traiter comme un seul rapport
            return [RapportModel.fromJson(data)];
          }
        }
        // Si la réponse est directement une liste
        else if (response.data is List) {
          final List<dynamic> dataList = response.data as List;
          return dataList
              .map(
                (json) => RapportModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
        // Format de réponse inattendu
        else {
          throw Exception(
            'Format de réponse inattendu: ${response.data.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Erreur lors de la récupération des rapports: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Délai de connexion dépassé');
      case DioExceptionType.sendTimeout:
        return Exception('Délai d\'envoi dépassé');
      case DioExceptionType.receiveTimeout:
        return Exception('Délai de réception dépassé');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Erreur serveur';
        return Exception('Erreur $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Requête annulée');
      case DioExceptionType.connectionError:
        return Exception('Erreur de connexion');
      default:
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}
