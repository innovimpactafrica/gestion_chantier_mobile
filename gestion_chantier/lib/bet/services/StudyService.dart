import 'package:dio/dio.dart';
import 'package:gestion_chantier/services/api_service.dart';

class BetStudyService {
  static const String _baseUrl = 'https://wakana.online/api';

  // Récupérer la liste des études pour un BET
  static Future<Map<String, dynamic>> fetchBetStudies({
    required int betId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print(
        '🔄 [BetStudyService] Récupération des études pour BET ID: $betId (page: $page, size: $size)',
      );

      final response = await ApiService().dio.get(
        '$_baseUrl/study-requests/bet/$betId',
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: {'accept': '*/*'}),
      );

      print('✅ [BetStudyService] Réponse reçue: ${response.statusCode}');
      print(
        '📊 [BetStudyService] Nombre d\'études: ${(response.data['content'] as List?)?.length ?? 0}',
      );

      return response.data;
    } catch (e) {
      print('❌ [BetStudyService] Erreur: $e');
      rethrow;
    }
  }
}


