import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_presence_history_event.dart';
import 'worker_presence_history_state.dart';
import '../../repository/worker_repository.dart';

class WorkerPresenceHistoryBloc
    extends Bloc<WorkerPresenceHistoryEvent, WorkerPresenceHistoryState> {
  final WorkerRepository repository;

  WorkerPresenceHistoryBloc({required this.repository})
      : super(WorkerPresenceHistoryLoading()) {
    on<LoadWorkerPresenceHistoryEvent>(_onLoadHistory);  // Charge l'événement correctement
  }

  Future<void> _onLoadHistory(
      LoadWorkerPresenceHistoryEvent event,
      Emitter<WorkerPresenceHistoryState> emit,
      ) async {
    emit(WorkerPresenceHistoryLoading());
    try {
      // Récupère l'historique de présence avec ou sans la date
      final history = await repository.getPresenceHistory(
        workerId: event.workerId,
        date: event.date, // Si la date est fournie, elle est utilisée
      );
      emit(WorkerPresenceHistoryLoaded(history));
    } catch (e) {
      emit(
        WorkerPresenceHistoryError(
          'Erreur lors du chargement de l\'historique de présence',
        ),
      );
    }
  }
}
