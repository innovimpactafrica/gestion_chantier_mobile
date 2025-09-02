import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/repository/material_kpi_repository.dart';
import 'material_kpi_event.dart';
import 'material_kpi_state.dart';

class MaterialKpiBloc extends Bloc<MaterialKpiEvent, MaterialKpiState> {
  final MaterialKpiRepository repository;

  MaterialKpiBloc(this.repository) : super(MaterialKpiInitial()) {
    on<FetchMaterialUnitDistribution>((event, emit) async {
      emit(MaterialKpiLoading());
      try {
        final data = await repository.fetchUnitDistribution(event.propertyId);
        emit(MaterialKpiLoaded(data));
      } catch (e) {
        emit(MaterialKpiError(e.toString()));
      }
    });
  }
}
