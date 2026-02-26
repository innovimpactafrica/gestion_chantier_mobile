import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_tasks_event.dart';
import 'worker_tasks_state.dart';
import '../../repository/task_repository.dart';

class WorkerTasksBloc extends Bloc<WorkerTasksEvent, WorkerTasksState> {
  final TaskRepository repository;
  static const int PAGE_SIZE = 100; // Taille de page fixe

  WorkerTasksBloc({required this.repository})
      : super(WorkerTasksLoading()) {
    on<LoadWorkerTasksEvent>(_onLoadTasks);
    on<LoadMoreWorkerTasksEvent>(_onLoadMoreTasks);
    on<RefreshWorkerTasksEvent>(_onRefreshTasks);
  }

  Future<void> _onLoadTasks(
      LoadWorkerTasksEvent event,
      Emitter<WorkerTasksState> emit,
      ) async {
    emit(WorkerTasksLoading());
    try {
      // Utiliser la méthode paginée pour le chargement initial
      final tasks = await repository.fetchTasksByExecutorPaginated(
        executorId: event.executorId,
        status: '', // statut par défaut
        page: 0,
        size: PAGE_SIZE,
      );

      emit(
        WorkerTasksLoaded(
          tasks: tasks,
          hasReachedMax: tasks.length < PAGE_SIZE,
          currentPage: 0,
        ),
      );
    } catch (e) {
      emit(WorkerTasksError('Erreur lors du chargement des tâches'));
    }
  }

  Future<void> _onLoadMoreTasks(
      LoadMoreWorkerTasksEvent event,
      Emitter<WorkerTasksState> emit,
      ) async {
    // Vérifier si on peut charger plus
    if (state is WorkerTasksLoaded) {
      final currentState = state as WorkerTasksLoaded;

      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.currentPage + 1;

        final newTasks = await repository.fetchTasksByExecutorPaginated(
          executorId: event.executorId,
          status: event.status,
          page: nextPage,
          size: PAGE_SIZE,
        );

        // Si on a reçu moins d'éléments que la taille de page, on a atteint la fin
        final hasReachedMax = newTasks.length < PAGE_SIZE;

        emit(
          currentState.copyWith(
            tasks: currentState.tasks + newTasks,
            hasReachedMax: hasReachedMax,
            currentPage: nextPage,
          ),
        );
      } catch (e) {
        emit(
          WorkerTasksError(
            'Erreur lors du chargement des tâches supplémentaires',
          ),
        );
      }
    }
  }

  Future<void> _onRefreshTasks(
      RefreshWorkerTasksEvent event,
      Emitter<WorkerTasksState> emit,
      ) async {
    try {
      // Recharger depuis le début
      final tasks = await repository.fetchTasksByExecutorPaginated(
        executorId: event.executorId,
        status: '',
        page: 0,
        size: PAGE_SIZE,
      );

      emit(
        WorkerTasksLoaded(
          tasks: tasks,
          hasReachedMax: tasks.length < PAGE_SIZE,
          currentPage: 0,
        ),
      );
    } catch (e) {
      emit(WorkerTasksError('Erreur lors du rafraîchissement des tâches'));
    }
  }
}
