// bloc/worker_state.dart
import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/WorkerModel.dart';

abstract class WorkerState extends Equatable {
  const WorkerState();

  @override
  List<Object> get props => [];
}

class WorkerInitial extends WorkerState {}

class WorkerLoading extends WorkerState {}

class WorkerLoaded extends WorkerState {
  final List<WorkerModel> workers;

  const WorkerLoaded({required this.workers});

  @override
  List<Object> get props => [workers];
}

class WorkerError extends WorkerState {
  final String message;

  const WorkerError({required this.message});

  @override
  List<Object> get props => [message];
}
