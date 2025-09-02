// bloc/task/task_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/Task/task_event.dart';
import 'package:gestion_chantier/manager/bloc/Task/task_state.dart';
import 'package:gestion_chantier/manager/services/TaskService.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;

  TaskBloc(this._taskService) : super(TaskInitial()) {
    on<LoadTaskKpis>(_onLoadTaskKpis);
  }

  Future<void> _onLoadTaskKpis(
    LoadTaskKpis event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());

    try {
      print('🔄 TaskBloc: Loading task KPIs...');
      final taskModel = await _taskService.getTaskKpis(
        promoterId: event.promoterId,
      );
      print('✅ TaskBloc: Task KPIs loaded successfully');
      emit(TaskLoaded(taskModel));
    } catch (e) {
      print('❌ TaskBloc: Error loading task KPIs: $e');
      emit(TaskError(e.toString()));
    }
  }
}
