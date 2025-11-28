import 'package:gestion_chantier/moa/models/study_comment.dart';
import 'package:gestion_chantier/moa/models/study_request.dart';

abstract class StudyRequestsState {}

class StudyRequestsInitial extends StudyRequestsState {}

class StudyRequestsLoading extends StudyRequestsState {}

class StudyRequestsLoaded extends StudyRequestsState {
  final List<StudyRequest> studyRequests;

  StudyRequestsLoaded({required this.studyRequests});
}

class StudyRequestsError extends StudyRequestsState {
  final String message;

  StudyRequestsError({required this.message});
}

class StudyCommentsLoading extends StudyRequestsState {
  final List<StudyRequest>? studyRequests;

  StudyCommentsLoading({this.studyRequests});
}

class StudyCommentsLoaded extends StudyRequestsState {
  final List<StudyComment> comments;
  final List<StudyRequest>? studyRequests;

  StudyCommentsLoaded({required this.comments, this.studyRequests});
}
