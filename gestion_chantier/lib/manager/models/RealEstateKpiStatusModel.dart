class RealEstateKpiStatusModel {
  final int total;
  final int inProgress;
  final int delayed;
  final int pending;
  final int completed;

  RealEstateKpiStatusModel({
    required this.total,
    required this.inProgress,
    required this.delayed,
    required this.pending,
    required this.completed,
  });

  factory RealEstateKpiStatusModel.fromJson(Map<String, dynamic> json) {
    return RealEstateKpiStatusModel(
      total: json['total'] as int,
      inProgress: json['inProgress'] as int,
      delayed: json['delayed'] as int,
      pending: json['pending'] as int,
      completed: json['completed'] as int,
    );
  }
}
