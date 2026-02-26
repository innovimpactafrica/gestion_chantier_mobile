import 'package:dio/dio.dart';
import 'package:gestion_chantier/ouvrier/models/TaskModel.dart';
import '../models/TaskStatusDistribution.dart';
import 'api_service.dart';

class TaskService {
  final Dio _dio = ApiService().dio;

  Future<List<TaskModel>> fetchTasksByExecutor(int executorId) async {
    final Map<String, dynamic> queryParams = {'page': 0, 'size': 100};
    final response = await _dio.get(
      '/tasks/by-executor/$executorId',
      queryParameters: queryParams,
    );
    final data = response.data['content'] as List? ?? [];
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<List<TaskModel>> fetchTasksByExecutorPaginated({
    required int executorId,
    required String status,
    required int page,
    required int size,
  }) async {
    final Map<String, dynamic> queryParams = {
      'status': status,
      'page': page,
      'size': size,
    };

    // 👉 Ajouter status seulement s’il n’est pas vide
    if (status.isNotEmpty) {
      final Map<String, dynamic> queryParams1 = {'page': page, 'size': size};

      final response = await _dio.get(
        '/tasks/by-executor/$executorId',
        queryParameters: queryParams1,
      );

      final List data = response.data['content'] ?? [];
      return data.map((e) => TaskModel.fromJson(e)).toList();
    } else {
      final response = await _dio.get(
        '/tasks/by-executor/$executorId',
        queryParameters: queryParams,
      );

      final List data = response.data['content'] ?? [];
      return data.map((e) => TaskModel.fromJson(e)).toList();
    }
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    await _dio.put(
      '/tasks/$taskId/status',
      queryParameters: {'status': status},
    );
  }

  Future<TaskModel> fetchTaskDetail(int taskId) async {
    final response = await _dio.get('/tasks/$taskId');
    return TaskModel.fromJson(response.data);
  }

  Future<List<TaskStatusDistribution>> fetchTaskStatusDistribution(
    int executorId,
  ) async {
    final response = await _dio.get('/tasks/status-distribution/$executorId');

    final List data = response.data ?? [];
    return data.map((e) => TaskStatusDistribution.fromJson(e)).toList();
  }
}
