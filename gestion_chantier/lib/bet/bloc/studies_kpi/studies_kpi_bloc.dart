import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/repository/studies_kpi_repository.dart';
import 'package:gestion_chantier/bet/bloc/studies_kpi/studies_kpi_event.dart';
import 'package:gestion_chantier/bet/bloc/studies_kpi/studies_kpi_state.dart';

class BetStudiesKpiBloc extends Bloc<BetStudiesKpiEvent, BetStudiesKpiState> {
  final BetStudiesKpiRepository _kpiRepository = BetStudiesKpiRepository();

  BetStudiesKpiBloc() : super(BetStudiesKpiInitial()) {
    on<LoadBetStudiesKpi>(_onLoadBetStudiesKpi);
  }

  Future<void> _onLoadBetStudiesKpi(
    LoadBetStudiesKpi event,
    Emitter<BetStudiesKpiState> emit,
  ) async {
    emit(BetStudiesKpiLoading());

    try {
      print(
        '🔄 [BetStudiesKpiBloc] Chargement des KPIs pour BET ID: ${event.betId}',
      );

      final kpiModel = await _kpiRepository.getBetStudyKpis(event.betId);

      print('✅ [BetStudiesKpiBloc] KPIs chargés avec succès');
      print('📊 [BetStudiesKpiBloc] Total: ${kpiModel.total}');
      print('📊 [BetStudiesKpiBloc] Pourcentages: ${kpiModel.percentages}');
      print('📊 [BetStudiesKpiBloc] Compteurs: ${kpiModel.counts}');

      emit(BetStudiesKpiLoaded(kpiData: kpiModel));
    } catch (e) {
      print('❌ [BetStudiesKpiBloc] Erreur lors du chargement des KPIs: $e');
      emit(BetStudiesKpiError(message: e.toString()));
    }
  }
}
