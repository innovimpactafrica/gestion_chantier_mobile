// bloc/task/task_state.dart
import 'package:gestion_chantier/manager/models/TaskModel.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final TaskModel taskModel;

  TaskLoaded(this.taskModel);
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}
