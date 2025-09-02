import '../models/TaskModel.dart';
import '../services/task_service.dart';

class TaskRepository {
  final TaskService taskService;
  TaskRepository({required this.taskService});

  Future<List<TaskModel>> getTasksByExecutor(int executorId) {
    return taskService.fetchTasksByExecutor(executorId);
  }
}
