import 'package:gestion_chantier/services/api_service.dart';
import 'package:dio/dio.dart';

class CommentService {
  static const String _baseUrl = '';

  // Récupérer les commentaires d'une étude
  static Future<List<Map<String, dynamic>>> fetchComments(
    int studyRequestId,
  ) async {
    try {
      print(
        '🔄 [CommentService] Récupération des commentaires pour étude ID: $studyRequestId',
      );
      final response = await ApiService().dio.get(
        '$_baseUrl/study-requests/comments/$studyRequestId',
        options: Options(headers: {'accept': '*/*'}),
      );

      print('🔍 [CommentService] URL appelée: ${response.requestOptions.uri}');
      print('🔍 [CommentService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> commentsData = response.data;
        print(
          '✅ [CommentService] ${commentsData.length} commentaires récupérés',
        );
        return commentsData.cast<Map<String, dynamic>>();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to load comments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [CommentService] Erreur: $e');
      rethrow;
    }
  }

  // Envoyer un nouveau commentaire
  static Future<Map<String, dynamic>> sendComment({
    required int studyRequestId,
    required int userId,
    required String content,
  }) async {
    try {
      print(
        '🔄 [CommentService] Envoi du commentaire pour étude ID: $studyRequestId, utilisateur ID: $userId',
      );
      final response = await ApiService().dio.post(
        '$_baseUrl/study-requests/comment/study/$studyRequestId/users/$userId',
        data: {'content': content},
        options: Options(
          headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [CommentService] Commentaire envoyé avec succès');
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to send comment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [CommentService] Erreur lors de l\'envoi: $e');
      rethrow;
    }
  }
}
