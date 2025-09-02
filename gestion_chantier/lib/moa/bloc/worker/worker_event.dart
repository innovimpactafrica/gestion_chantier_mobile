// bloc/worker_event.dart
import 'package:equatable/equatable.dart';

abstract class WorkerEvent extends Equatable {
  const WorkerEvent();

  @override
  List<Object> get props => [];
}

class LoadWorkers extends WorkerEvent {
  final int propertyId;

  const LoadWorkers({required this.propertyId});

  @override
  List<Object> get props => [propertyId];
}

class RefreshWorkers extends WorkerEvent {
  final int propertyId;

  const RefreshWorkers({required this.propertyId});

  @override
  List<Object> get props => [propertyId];
}
