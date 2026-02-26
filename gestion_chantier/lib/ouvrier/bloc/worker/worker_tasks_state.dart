import 'package:equatable/equatable.dart';
import '../../models/TaskModel.dart';

abstract class WorkerTasksState extends Equatable {
  const WorkerTasksState();
  @override
  List<Object?> get props => [];
}

class WorkerTasksLoading extends WorkerTasksState {}

class WorkerTasksLoaded extends WorkerTasksState {
  final List<TaskModel> tasks;
  final bool hasReachedMax;
  final int currentPage;

  const WorkerTasksLoaded({
    required this.tasks,
    this.hasReachedMax = false,
    this.currentPage = 0,
  });

  WorkerTasksLoaded copyWith({
    List<TaskModel>? tasks,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return WorkerTasksLoaded(
      tasks: tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [tasks, hasReachedMax, currentPage];
}

class WorkerTasksError extends WorkerTasksState {
  final String message;
  const WorkerTasksError(this.message);
  @override
  List<Object?> get props => [message];
}