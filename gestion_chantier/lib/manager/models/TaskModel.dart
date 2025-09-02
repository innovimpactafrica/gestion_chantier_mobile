class TaskModel {
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;
  final int overdueTasks;
  final int inProgressTasks;

  TaskModel({
    required this.totalTasks,
    required this.pendingTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.inProgressTasks,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      totalTasks: json['totalTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      inProgressTasks: json['inProgressTasks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'pendingTasks': pendingTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
      'inProgressTasks': inProgressTasks,
    };
  }
}
