import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/repository/study_repository.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';
import 'package:gestion_chantier/bet/bloc/studies/studies_event.dart';
import 'package:gestion_chantier/bet/bloc/studies/studies_state.dart';

class BetStudiesBloc extends Bloc<BetStudiesEvent, BetStudiesState> {
  final BetStudyRepository _studyRepository = BetStudyRepository();

  BetStudiesBloc() : super(BetStudiesInitial()) {
    on<LoadBetStudies>(_onLoadBetStudies);
    on<RefreshBetStudies>(_onRefreshBetStudies);
    on<LoadMoreBetStudies>(_onLoadMoreBetStudies);
  }

  Future<void> _onLoadBetStudies(
    LoadBetStudies event,
    Emitter<BetStudiesState> emit,
  ) async {
    emit(BetStudiesLoading());

    try {
      print(
        '🔄 [BetStudiesBloc] Chargement des études pour BET ID: ${event.betId}',
      );

      final response = await _studyRepository.getBetStudies(
        betId: event.betId,
        page: event.page,
        size: event.size,
      );

      print('✅ [BetStudiesBloc] Études chargées avec succès');
      print('📊 [BetStudiesBloc] Total: ${response.totalElements}');

      emit(
        BetStudiesLoaded(
          studies: response.content,
          currentPage: response.number,
          totalPages: response.totalPages,
          totalElements: response.totalElements,
          hasMore: !response.last,
        ),
      );
    } catch (e) {
      print('❌ [BetStudiesBloc] Erreur lors du chargement des études: $e');
      emit(BetStudiesError(message: e.toString()));
    }
  }

  Future<void> _onRefreshBetStudies(
    RefreshBetStudies event,
    Emitter<BetStudiesState> emit,
  ) async {
    // Si on est déjà en train de charger, on ne fait rien
    if (state is BetStudiesLoading) return;

    add(LoadBetStudies(betId: event.betId));
  }

  Future<void> _onLoadMoreBetStudies(
    LoadMoreBetStudies event,
    Emitter<BetStudiesState> emit,
  ) async {
    if (state is! BetStudiesLoaded) return;

    final currentState = state as BetStudiesLoaded;

    // Si on n'a pas plus de données à charger
    if (!currentState.hasMore) return;

    emit(
      BetStudiesLoadingMore(
        studies: currentState.studies,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        totalElements: currentState.totalElements,
        hasMore: currentState.hasMore,
      ),
    );

    try {
      print(
        '🔄 [BetStudiesBloc] Chargement de plus d\'études pour BET ID: ${event.betId} (page: ${event.nextPage})',
      );

      final response = await _studyRepository.getBetStudies(
        betId: event.betId,
        page: event.nextPage,
        size: 10,
      );

      print('✅ [BetStudiesBloc] Études supplémentaires chargées');

      final updatedStudies = List<BetStudyModel>.from(currentState.studies)
        ..addAll(response.content);

      emit(
        BetStudiesLoaded(
          studies: updatedStudies,
          currentPage: response.number,
          totalPages: response.totalPages,
          totalElements: response.totalElements,
          hasMore: !response.last,
        ),
      );
    } catch (e) {
      print(
        '❌ [BetStudiesBloc] Erreur lors du chargement de plus d\'études: $e',
      );
      // En cas d'erreur, on revient à l'état précédent
      emit(currentState);
    }
  }
}
