import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/repository/material_monthly_stats_repository.dart';
import 'material_monthly_stats_event.dart';
import 'material_monthly_stats_state.dart';

class MaterialMonthlyStatsBloc
    extends Bloc<MaterialMonthlyStatsEvent, MaterialMonthlyStatsState> {
  final MaterialMonthlyStatsRepository repository;

  MaterialMonthlyStatsBloc(this.repository)
    : super(MaterialMonthlyStatsInitial()) {
    on<FetchMaterialMonthlyStats>((event, emit) async {
      emit(MaterialMonthlyStatsLoading());
      try {
        final stats = await repository.fetchMonthlyStats(event.propertyId);
        emit(MaterialMonthlyStatsLoaded(stats));
      } catch (e) {
        emit(MaterialMonthlyStatsError(e.toString()));
      }
    });
  }
}
