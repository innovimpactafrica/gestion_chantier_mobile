import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/models/study_kpi.dart';
import 'package:gestion_chantier/moa/services/StudyRequestsService.dart';

part 'studies_kpi_event.dart';
part 'studies_kpi_state.dart';

class StudiesKpiBloc extends Bloc<StudiesKpiEvent, StudiesKpiState> {
  final StudyRequestsService service;

  StudiesKpiBloc({required this.service}) : super(StudiesKpiInitial()) {
    on<LoadStudiesKpi>((event, emit) async {
      emit(StudiesKpiLoading());
      try {
        final model = await service.fetchMoaStudyKpis(
          promoterId: event.promoterId,
        );
        emit(StudiesKpiLoaded(model));
      } catch (e) {
        emit(StudiesKpiError(e.toString()));
      }
    });
  }
}
