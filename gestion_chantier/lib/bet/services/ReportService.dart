import 'package:gestion_chantier/services/api_service.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';
import 'package:gestion_chantier/moa/utils/constant.dart';
import 'package:gestion_chantier/moa/services/SharedPreferencesService.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ReportService {
  static const String _baseUrl = '';

  static Future<Map<String, dynamic>> addReport({
    required String title,
    required File file,
    required int versionNumber,
    required int studyRequestId,
    required int authorId,
  }) async {
    try {
      print(
        '🔄 [ReportService] Ajout du rapport: $title pour étude ID: $studyRequestId',
      );

      // Créer FormData pour l'upload multipart
      FormData formData = FormData.fromMap({
        'title': title,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'versionNumber': versionNumber,
        'studyRequestId': studyRequestId,
        'authorId': authorId,
      });

      final response = await ApiService().dio.post(
        '$_baseUrl/study-requests/reports',
        data: formData,
        options: Options(
          headers: {'accept': '*/*', 'Content-Type': 'multipart/form-data'},
        ),
      );

      print('🔍 [ReportService] URL appelée: ${response.requestOptions.uri}');
      print('🔍 [ReportService] Status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [ReportService] Rapport ajouté avec succès');
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to add report: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [ReportService] Erreur lors de l\'ajout du rapport: $e');
      rethrow;
    }
  }

  static Future<List<BetReportModel>> getReportsByStudy(
    int studyRequestId,
  ) async {
    try {
      print(
        '🔄 [ReportService] Récupération des rapports pour étude ID: $studyRequestId',
      );
      print(
        '🔍 [ReportService] URL complète: ${ApiService().dio.options.baseUrl}/study-requests/$studyRequestId',
      );

      // Vérifier le token avant l'appel
      final sharedPrefs = SharedPreferencesService();
      final token = await sharedPrefs.getValue(APIConstants.AUTH_TOKEN);
      print(
        '🔑 [ReportService] Token récupéré: ${token != null ? token.substring(0, 20) + "..." : "null"}',
      );

      // Créer une instance d'ApiService avec le token manuellement
      final apiService = ApiService();
      final response = await apiService.dio.get(
        '$_baseUrl/study-requests/$studyRequestId',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'X-Auth-Token': token,
            'X-API-Key': token,
          },
        ),
      );

      print('🔍 [ReportService] URL appelée: ${response.requestOptions.uri}');
      print('🔍 [ReportService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> reports = data['reports'] ?? [];

        final reportModels =
            reports.map((report) => BetReportModel.fromJson(report)).toList();
        print(
          '✅ [ReportService] ${reportModels.length} rapports récupérés pour l\'étude',
        );
        return reportModels;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to load reports: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ [ReportService] Erreur lors de la récupération des rapports: $e',
      );
      rethrow;
    }
  }
}
