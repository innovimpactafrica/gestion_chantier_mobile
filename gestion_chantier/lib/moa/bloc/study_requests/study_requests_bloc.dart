import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_event.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_state.dart';
import 'package:gestion_chantier/moa/repository/study_requests_repository.dart';

class StudyRequestsBloc extends Bloc<StudyRequestsEvent, StudyRequestsState> {
  final StudyRequestsRepository _studyRequestsRepository = StudyRequestsRepository();

  StudyRequestsBloc() : super(StudyRequestsInitial()) {
    on<LoadStudyRequests>((event, emit) async {
      emit(StudyRequestsLoading());
      try {
        final studyRequests = await _studyRequestsRepository.getStudyRequests(
          propertyId: event.propertyId,
        );
        emit(StudyRequestsLoaded(studyRequests: studyRequests));
      } catch (e) {
        emit(StudyRequestsError(message: e.toString()));
      }
    });

    on<LoadStudyComments>((event, emit) async {
      emit(StudyCommentsLoading());
      try {
        final comments = await _studyRequestsRepository.getStudyComments(
          studyRequestId: event.studyRequestId,
        );
        emit(StudyCommentsLoaded(comments: comments));
      } catch (e) {
        emit(StudyRequestsError(message: e.toString()));
      }
    });
  }
}
