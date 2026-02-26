import 'package:equatable/equatable.dart';

abstract class WorkerTasksEvent extends Equatable {
  const WorkerTasksEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkerTasksEvent extends WorkerTasksEvent {
  final int executorId;
  const LoadWorkerTasksEvent(this.executorId);
  @override
  List<Object?> get props => [executorId];
}

class LoadMoreWorkerTasksEvent extends WorkerTasksEvent {
  final int executorId;
  final String status;
  const LoadMoreWorkerTasksEvent({
    required this.executorId,
    required this.status,
  });

  @override
  List<Object?> get props => [executorId, status];
}

class RefreshWorkerTasksEvent extends WorkerTasksEvent {
  final int executorId;
  const RefreshWorkerTasksEvent(this.executorId);
  @override
  List<Object?> get props => [executorId];
}