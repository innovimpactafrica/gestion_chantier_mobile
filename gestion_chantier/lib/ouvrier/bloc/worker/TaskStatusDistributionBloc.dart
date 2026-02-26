import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/task_repository.dart';
import 'TaskStatusDistributionEvent.dart';
import 'TaskStatusDistributionState.dart';

class TaskStatusDistributionBloc extends Bloc<
    TaskStatusDistributionEvent,
    TaskStatusDistributionState> {
  final TaskRepository repository;

  TaskStatusDistributionBloc({required this.repository})
      : super(TaskStatusDistributionLoading()) {
    on<LoadTaskStatusDistribution>(_onLoad);
  }

  Future<void> _onLoad(
      LoadTaskStatusDistribution event,
      Emitter<TaskStatusDistributionState> emit,
      ) async {
    emit(TaskStatusDistributionLoading());
    try {
      final data =
      await repository.fetchTaskStatusDistribution(event.executorId);
      emit(TaskStatusDistributionLoaded(data));
    } catch (e) {
      emit(TaskStatusDistributionError(
          'Erreur chargement statistiques'));
    }
  }
}
