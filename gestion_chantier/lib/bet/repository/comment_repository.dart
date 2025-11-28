import 'package:gestion_chantier/bet/models/CommentModel.dart';
import 'package:gestion_chantier/bet/services/CommentService.dart';

class CommentRepository {
  // Récupérer les commentaires d'une étude
  Future<List<CommentModel>> getComments(int studyRequestId) async {
    try {
      print(
        '🔄 [CommentRepository] Récupération des commentaires pour étude ID: $studyRequestId',
      );
      final commentsData = await CommentService.fetchComments(studyRequestId);
      final comments =
          commentsData.map((data) => CommentModel.fromJson(data)).toList();
      print(
        '✅ [CommentRepository] ${comments.length} commentaires récupérés avec succès',
      );
      return comments;
    } catch (e) {
      print(
        '❌ [CommentRepository] Erreur lors de la récupération des commentaires: $e',
      );
      rethrow;
    }
  }

  // Envoyer un nouveau commentaire
  Future<CommentModel> sendComment({
    required int studyRequestId,
    required int userId,
    required String content,
  }) async {
    try {
      print(
        '🔄 [CommentRepository] Envoi du commentaire pour étude ID: $studyRequestId, utilisateur ID: $userId',
      );
      final commentData = await CommentService.sendComment(
        studyRequestId: studyRequestId,
        userId: userId,
        content: content,
      );
      final comment = CommentModel.fromJson(commentData);
      print('✅ [CommentRepository] Commentaire envoyé avec succès');
      return comment;
    } catch (e) {
      print('❌ [CommentRepository] Erreur lors de l\'envoi du commentaire: $e');
      rethrow;
    }
  }
}


