// bloc/task/task_event.dart
abstract class TaskEvent {}

class LoadTaskKpis extends TaskEvent {
  final int? promoterId;

  LoadTaskKpis({this.promoterId});
}
