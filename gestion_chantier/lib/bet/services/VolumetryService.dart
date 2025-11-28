import 'package:dio/dio.dart';
import 'package:gestion_chantier/services/api_service.dart';

class BetVolumetryService {
  static const String _baseUrl = 'https://wakana.online/api';

  // Récupérer la volumétrie pour un BET
  static Future<Map<String, dynamic>> fetchBetVolumetry(int betId) async {
    try {
      print(
        '🔄 [BetVolumetryService] Récupération de la volumétrie pour BET ID: $betId',
      );

      final response = await ApiService().dio.get(
        '$_baseUrl/study-requests/kpi/bet/$betId/volumetry',
        options: Options(headers: {'accept': '*/*'}),
      );

      print('✅ [BetVolumetryService] Réponse reçue: ${response.statusCode}');
      print('📊 [BetVolumetryService] Données volumétrie: ${response.data}');

      return response.data;
    } catch (e) {
      print('❌ [BetVolumetryService] Erreur: $e');
      rethrow;
    }
  }
}


