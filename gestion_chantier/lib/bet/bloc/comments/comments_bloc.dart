import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/repository/comment_repository.dart';
import 'package:gestion_chantier/bet/bloc/comments/comments_event.dart';
import 'package:gestion_chantier/bet/bloc/comments/comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentRepository _commentRepository = CommentRepository();

  CommentsBloc() : super(CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<SendComment>(_onSendComment);
    on<RefreshComments>(_onRefreshComments);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CommentsLoading());
    try {
      print(
        '🔄 [CommentsBloc] Chargement des commentaires pour étude ID: ${event.studyRequestId}',
      );
      final comments = await _commentRepository.getComments(
        event.studyRequestId,
      );
      print('✅ [CommentsBloc] ${comments.length} commentaires chargés');
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      print('❌ [CommentsBloc] Erreur lors du chargement des commentaires: $e');
      emit(CommentsError(message: e.toString()));
    }
  }

  Future<void> _onSendComment(
    SendComment event,
    Emitter<CommentsState> emit,
  ) async {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      emit(CommentsSending(comments: currentState.comments));

      try {
        print(
          '🔄 [CommentsBloc] Envoi du commentaire pour étude ID: ${event.studyRequestId}',
        );
        final newComment = await _commentRepository.sendComment(
          studyRequestId: event.studyRequestId,
          userId: event.userId,
          content: event.content,
        );

        // Ajouter le nouveau commentaire à la liste
        final updatedComments = [...currentState.comments, newComment];
        print('✅ [CommentsBloc] Commentaire envoyé avec succès');
        emit(CommentsLoaded(comments: updatedComments));
      } catch (e) {
        print('❌ [CommentsBloc] Erreur lors de l\'envoi du commentaire: $e');
        emit(CommentsError(message: e.toString()));
      }
    }
  }

  Future<void> _onRefreshComments(
    RefreshComments event,
    Emitter<CommentsState> emit,
  ) async {
    try {
      print(
        '🔄 [CommentsBloc] Actualisation des commentaires pour étude ID: ${event.studyRequestId}',
      );
      final comments = await _commentRepository.getComments(
        event.studyRequestId,
      );
      print('✅ [CommentsBloc] ${comments.length} commentaires actualisés');
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      print(
        '❌ [CommentsBloc] Erreur lors de l\'actualisation des commentaires: $e',
      );
      emit(CommentsError(message: e.toString()));
    }
  }
}
