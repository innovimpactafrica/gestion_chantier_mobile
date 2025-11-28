import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_event.dart';
import 'package:gestion_chantier/bet/bloc/home/home_state.dart';
import 'package:gestion_chantier/bet/repository/auth_repository.dart';
import 'package:gestion_chantier/bet/repository/studies_kpi_repository.dart';
import 'package:gestion_chantier/bet/repository/volumetry_repository.dart';

class BetHomeBloc extends Bloc<BetHomeEvent, BetHomeState> {
  final BetAuthRepository _authRepository = BetAuthRepository();
  final BetStudiesKpiRepository _kpiRepository = BetStudiesKpiRepository();
  final BetVolumetryRepository _volumetryRepository = BetVolumetryRepository();

  BetHomeBloc() : super(BetHomeInitial()) {
    on<LoadCurrentUserEvent>((event, emit) async {
      emit(BetHomeLoading());
      try {
        final user = await _authRepository.getCurrentUser();
        emit(BetHomeLoaded(currentUser: user));
      } catch (e) {
        emit(BetHomeError(message: e.toString()));
      }
    });

    on<SetCurrentUserEvent>((event, emit) {
      print('🎯 SetCurrentUserEvent reçu: ${event.user.fullName}');
      emit(BetHomeLoaded(currentUser: event.user));

      // Charger automatiquement les KPIs et la volumétrie après avoir défini l'utilisateur
      add(LoadBetKpisEvent(betId: event.user.id));
      add(LoadBetVolumetryEvent(betId: event.user.id));
    });

    on<LoadBetKpisEvent>((event, emit) async {
      try {
        print(
          '🔄 [BetHomeBloc] Chargement des KPIs pour BET ID: ${event.betId}',
        );

        final kpiModel = await _kpiRepository.getBetStudyKpis(event.betId);

        print('✅ [BetHomeBloc] KPIs chargés avec succès');

        // Mettre à jour l'état avec les KPIs
        if (state is BetHomeLoaded) {
          final currentState = state as BetHomeLoaded;
          emit(
            BetHomeLoaded(
              currentUser: currentState.currentUser,
              kpiData: kpiModel,
            ),
          );
        }
      } catch (e) {
        print('❌ [BetHomeBloc] Erreur lors du chargement des KPIs: $e');
        // En cas d'erreur, on garde l'état actuel sans les KPIs
      }
    });

    on<LoadBetVolumetryEvent>((event, emit) async {
      try {
        print(
          '🔄 [BetHomeBloc] Chargement de la volumétrie pour BET ID: ${event.betId}',
        );

        final volumetryModel = await _volumetryRepository.getBetVolumetry(
          event.betId,
        );

        print('✅ [BetHomeBloc] Volumétrie chargée avec succès');

        // Mettre à jour l'état avec la volumétrie
        if (state is BetHomeLoaded) {
          final currentState = state as BetHomeLoaded;
          emit(
            BetHomeLoaded(
              currentUser: currentState.currentUser,
              kpiData: currentState.kpiData,
              volumetryData: volumetryModel,
            ),
          );
        }
      } catch (e) {
        print('❌ [BetHomeBloc] Erreur lors du chargement de la volumétrie: $e');
        // En cas d'erreur, on garde l'état actuel sans la volumétrie
      }
    });
  }
}
