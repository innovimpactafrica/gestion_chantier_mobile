import 'package:gestion_chantier/moa/models/study_comment.dart';
import 'package:gestion_chantier/moa/models/study_request.dart';
import 'package:gestion_chantier/moa/services/StudyRequestsService.dart';

class StudyRequestsRepository {
  final StudyRequestsService _studyRequestsService = StudyRequestsService();

  Future<List<StudyRequest>> getStudyRequests({
    required int propertyId,
    int page = 0,
    int size = 10,
  }) {
    return _studyRequestsService.fetchStudyRequests(
      propertyId: propertyId,
      page: page,
      size: size,
    );
  }

  Future<List<StudyComment>> getStudyComments({
    required int studyRequestId,
  }) {
    return _studyRequestsService.fetchStudyComments(
      studyRequestId: studyRequestId,
    );
  }

  Future<StudyComment> addStudyComment({
    required int studyRequestId,
    required String content,
  }) {
    return _studyRequestsService.addStudyComment(
      studyRequestId: studyRequestId,
      content: content,
    );
  }
}
