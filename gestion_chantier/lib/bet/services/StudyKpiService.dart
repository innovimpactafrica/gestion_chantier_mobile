import 'package:dio/dio.dart';
import 'package:gestion_chantier/services/api_service.dart';

class BetStudyKpiService {
  static const String _baseUrl = 'https://wakana.online/api';

  // Récupérer les KPIs des études pour un BET
  static Future<Map<String, dynamic>> fetchBetStudyKpis(int betId) async {
    try {
      print(
        '🔄 [BetStudyKpiService] Récupération des KPIs pour BET ID: $betId',
      );

      final response = await ApiService().dio.get(
        '$_baseUrl/study-requests/kpi/bet/$betId',
        options: Options(headers: {'accept': '*/*'}),
      );

      print('✅ [BetStudyKpiService] Réponse reçue: ${response.statusCode}');
      print('📊 [BetStudyKpiService] Données KPIs: ${response.data}');

      return response.data;
    } catch (e) {
      print('❌ [BetStudyKpiService] Erreur: $e');
      rethrow;
    }
  }
}
