abstract class StudyRequestsEvent {}

class LoadStudyRequests extends StudyRequestsEvent {
  final int propertyId;

  LoadStudyRequests({required this.propertyId});
}

class LoadStudyComments extends StudyRequestsEvent {
  final int studyRequestId;

  LoadStudyComments({required this.studyRequestId});
}

class AddStudyComment extends StudyRequestsEvent {
  final int studyRequestId;
  final String content;

  AddStudyComment({required this.studyRequestId, required this.content});
}
