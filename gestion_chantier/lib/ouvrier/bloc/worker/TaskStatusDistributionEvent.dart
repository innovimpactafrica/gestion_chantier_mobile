abstract class TaskStatusDistributionEvent {}

class LoadTaskStatusDistribution extends TaskStatusDistributionEvent {
  final int executorId;

  LoadTaskStatusDistribution(this.executorId);
}
