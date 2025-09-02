import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/study_kpi.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';
import 'package:gestion_chantier/moa/services/api_service.dart';

class StudyRequestsService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<StudyKpiModel> fetchMoaStudyKpis({int? promoterId}) async {
    try {
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

      final Dio dio = _apiService.dio;
      final response = await dio.get(
        '/study-requests/kpi/moa/$currentPromoterId',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return StudyKpiModel.fromJson(response.data as Map<String, dynamic>);
      }

      if (response.statusCode == 403) {
        throw Exception('Accès refusé. Vérifiez vos permissions.');
      }

      throw Exception('Erreur inconnue (${response.statusCode})');
    } on DioException catch (e) {
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
    }
  }
}
