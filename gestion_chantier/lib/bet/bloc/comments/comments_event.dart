abstract class CommentsEvent {}

class LoadComments extends CommentsEvent {
  final int studyRequestId;

  LoadComments({required this.studyRequestId});
}

class SendComment extends CommentsEvent {
  final int studyRequestId;
  final int userId;
  final String content;

  SendComment({
    required this.studyRequestId,
    required this.userId,
    required this.content,
  });
}

class RefreshComments extends CommentsEvent {
  final int studyRequestId;

  RefreshComments({required this.studyRequestId});
}


