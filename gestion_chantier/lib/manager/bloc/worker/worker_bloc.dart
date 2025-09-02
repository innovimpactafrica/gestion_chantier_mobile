// bloc/worker_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/services/worker_service.dart';
import 'worker_event.dart';
import 'worker_state.dart';

class WorkerBloc extends Bloc<WorkerEvent, WorkerState> {
  final WorkerService workerService;

  WorkerBloc({required this.workerService}) : super(WorkerInitial()) {
    on<LoadWorkers>(_onLoadWorkers);
    on<RefreshWorkers>(_onRefreshWorkers);
  }

  Future<void> _onLoadWorkers(
    LoadWorkers event,
    Emitter<WorkerState> emit,
  ) async {
    emit(WorkerLoading());
    try {
      final workers = await workerService.getWorkersByProperty(
        event.propertyId,
      );
      emit(WorkerLoaded(workers: workers));
    } catch (e) {
      emit(WorkerError(message: e.toString()));
    }
  }

  Future<void> _onRefreshWorkers(
    RefreshWorkers event,
    Emitter<WorkerState> emit,
  ) async {
    try {
      final workers = await workerService.getWorkersByProperty(
        event.propertyId,
      );
      emit(WorkerLoaded(workers: workers));
    } catch (e) {
      emit(WorkerError(message: e.toString()));
    }
  }
}
