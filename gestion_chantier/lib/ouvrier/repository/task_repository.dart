import '../models/TaskModel.dart';
import '../models/TaskStatusDistribution.dart';
import '../services/task_service.dart';

class TaskRepository {
  final TaskService taskService;

  TaskRepository({required this.taskService});

  Future<List<TaskModel>> fetchTasksByExecutorPaginated({
    required int executorId,
    required String status,
    required int page,
    required int size,
  }) {
    return taskService.fetchTasksByExecutorPaginated(
      executorId: executorId,
      status: status,
      page: page,
      size: size,
    );
  }

  Future<List<TaskModel>> getTasksByExecutor(int executorId) {
    return taskService.fetchTasksByExecutor(executorId);
  }


  Future<List<TaskStatusDistribution>> fetchTaskStatusDistribution(
      int executorId,
      ) {
    return taskService.fetchTaskStatusDistribution(executorId);
  }

}
