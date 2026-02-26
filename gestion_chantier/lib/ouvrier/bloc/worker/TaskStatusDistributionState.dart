import '../../models/TaskStatusDistribution.dart';

abstract class TaskStatusDistributionState {}

class TaskStatusDistributionLoading
    extends TaskStatusDistributionState {}

class TaskStatusDistributionLoaded
    extends TaskStatusDistributionState {
  final List<TaskStatusDistribution> data;

  TaskStatusDistributionLoaded(this.data);
}

class TaskStatusDistributionError
    extends TaskStatusDistributionState {
  final String message;

  TaskStatusDistributionError(this.message);
}
