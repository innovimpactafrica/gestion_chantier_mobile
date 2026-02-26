class TaskStatusDistribution {
  final String status;
  final double percentage;

  TaskStatusDistribution({
    required this.status,
    required this.percentage,
  });

  factory TaskStatusDistribution.fromJson(Map<String, dynamic> json) {
    return TaskStatusDistribution(
      status: json['status'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
