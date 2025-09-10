import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/study_comment.dart';
import 'package:gestion_chantier/moa/models/study_kpi.dart';
import 'package:gestion_chantier/moa/models/study_request.dart';
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

  Future<List<StudyRequest>> fetchStudyRequests({
    required int propertyId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final Dio dio = _apiService.dio;
      final response = await dio.get(
        '/study-requests/property/$propertyId?page=$page&size=$size',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final content = response.data['content'] as List;
        return content.map((json) => StudyRequest.fromJson(json)).toList();
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

  Future<List<StudyComment>> fetchStudyComments({
    required int studyRequestId,
  }) async {
    try {
      final Dio dio = _apiService.dio;
      final response = await dio.get(
        '/study-requests/comments/$studyRequestId',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final content = response.data as List;
        return content.map((json) => StudyComment.fromJson(json)).toList();
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

  Future<StudyComment> addStudyComment({
    required int studyRequestId,
    required String content,
  }) async {
    try {
      final currentUser = await _authService.connectedUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final userId = currentUser['id'];
      if (userId == null) {
        throw Exception('ID utilisateur non trouvé');
      }

      final Dio dio = _apiService.dio;
      final response = await dio.post(
        '/study-requests/comment/study/$studyRequestId/users/$userId',
        data: {'content': content},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudyComment.fromJson(response.data);
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
