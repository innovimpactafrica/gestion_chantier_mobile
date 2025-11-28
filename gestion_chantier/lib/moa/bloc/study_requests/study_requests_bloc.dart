import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_event.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_state.dart';
import 'package:gestion_chantier/moa/models/study_request.dart';
import 'package:gestion_chantier/moa/repository/study_requests_repository.dart';

class StudyRequestsBloc extends Bloc<StudyRequestsEvent, StudyRequestsState> {
  final StudyRequestsRepository _studyRequestsRepository = StudyRequestsRepository();

  StudyRequestsBloc() : super(StudyRequestsInitial()) {
    print('🔧 StudyRequestsBloc: Registering handlers...');
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
      // Préserver l'état des études si disponible
      List<StudyRequest>? preservedStudyRequests;
      if (state is StudyRequestsLoaded) {
        preservedStudyRequests = (state as StudyRequestsLoaded).studyRequests;
      } else if (state is StudyCommentsLoaded) {
        preservedStudyRequests = (state as StudyCommentsLoaded).studyRequests;
      }
      
      emit(StudyCommentsLoading(studyRequests: preservedStudyRequests));
      try {
        final comments = await _studyRequestsRepository.getStudyComments(
          studyRequestId: event.studyRequestId,
        );
        emit(StudyCommentsLoaded(
          comments: comments,
          studyRequests: preservedStudyRequests,
        ));
      } catch (e) {
        // En cas d'erreur, restaurer l'état précédent si possible
        if (preservedStudyRequests != null) {
          emit(StudyRequestsLoaded(studyRequests: preservedStudyRequests));
        } else {
          emit(StudyRequestsError(message: e.toString()));
        }
      }
    });

    on<AddStudyComment>((event, emit) async {
      print('✅ AddStudyComment handler called');
      try {
        // Ajouter le commentaire
        await _studyRequestsRepository.addStudyComment(
          studyRequestId: event.studyRequestId,
          content: event.content,
        );
        
        // Préserver l'état des études si disponible
        List<StudyRequest>? preservedStudyRequests;
        if (state is StudyRequestsLoaded) {
          preservedStudyRequests = (state as StudyRequestsLoaded).studyRequests;
        } else if (state is StudyCommentsLoaded) {
          preservedStudyRequests = (state as StudyCommentsLoaded).studyRequests;
        }
        
        // Recharger les commentaires pour afficher le nouveau
        final comments = await _studyRequestsRepository.getStudyComments(
          studyRequestId: event.studyRequestId,
        );
        emit(StudyCommentsLoaded(
          comments: comments,
          studyRequests: preservedStudyRequests,
        ));
      } catch (e) {
        // En cas d'erreur, préserver l'état actuel
        if (state is StudyCommentsLoaded) {
          emit(StudyRequestsError(message: e.toString()));
        } else {
          emit(StudyRequestsError(message: e.toString()));
        }
      }
    });
  }
}
