import 'package:gestion_chantier/services/api_service.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';
import 'package:dio/dio.dart';

class StudyStatusService {
  static const String _baseUrl = '';

  /// Accepter une demande d'étude
  static Future<BetStudyModel> acceptStudy(int studyRequestId) async {
    try {
      print(
        '🔄 [StudyStatusService] Acceptation de l\'étude ID: $studyRequestId',
      );

      final response = await ApiService().dio.put(
        '$_baseUrl/study-requests/$studyRequestId/validate',
        options: Options(headers: {'accept': '*/*'}),
      );

      print(
        '🔍 [StudyStatusService] URL appelée: ${response.requestOptions.uri}',
      );
      print('🔍 [StudyStatusService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final studyData = response.data;
        print('✅ [StudyStatusService] Étude acceptée avec succès');
        return BetStudyModel.fromJson(studyData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to accept study: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ [StudyStatusService] Erreur lors de l\'acceptation de l\'étude: $e',
      );
      rethrow;
    }
  }

  /// Refuser une demande d'étude
  static Future<BetStudyModel> rejectStudy(
    int studyRequestId, {
    String? reason,
  }) async {
    try {
      print(
        '🔄 [StudyStatusService] Refus de l\'étude ID: $studyRequestId avec motif: $reason',
      );

      // Préparer les données à envoyer
      Map<String, dynamic> data = {};
      if (reason != null && reason.isNotEmpty) {
        data['reason'] = reason;
      }

      final response = await ApiService().dio.put(
        '$_baseUrl/study-requests/$studyRequestId/reject',
        data: data.isNotEmpty ? data : null,
        options: Options(headers: {'accept': '*/*'}),
      );

      print(
        '🔍 [StudyStatusService] URL appelée: ${response.requestOptions.uri}',
      );
      print('🔍 [StudyStatusService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final studyData = response.data;
        print('✅ [StudyStatusService] Étude refusée avec succès');
        return BetStudyModel.fromJson(studyData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to reject study: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [StudyStatusService] Erreur lors du refus de l\'étude: $e');
      rethrow;
    }
  }

  /// Marquer une étude comme livrée
  static Future<BetStudyModel> markAsDelivered(int studyRequestId) async {
    try {
      print(
        '🔄 [StudyStatusService] Marquage comme livrée de l\'étude ID: $studyRequestId',
      );

      final response = await ApiService().dio.put(
        '$_baseUrl/study-requests/$studyRequestId/deliver',
        options: Options(headers: {'accept': '*/*'}),
      );

      print(
        '🔍 [StudyStatusService] URL appelée: ${response.requestOptions.uri}',
      );
      print('🔍 [StudyStatusService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [StudyStatusService] Étude marquée comme livrée avec succès');
        return BetStudyModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to mark study as delivered: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [StudyStatusService] Erreur lors du marquage comme livrée: $e');
      rethrow;
    }
  }
}
