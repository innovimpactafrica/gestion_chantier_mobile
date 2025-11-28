import 'package:gestion_chantier/bet/models/CommentModel.dart';

abstract class CommentsState {}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;

  CommentsLoaded({required this.comments});
}

class CommentsSending extends CommentsState {
  final List<CommentModel> comments;

  CommentsSending({required this.comments});
}

class CommentsError extends CommentsState {
  final String message;

  CommentsError({required this.message});
}


