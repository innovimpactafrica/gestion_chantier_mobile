class BetStudyKpiModel {
  final int total;
  final Map<String, double> percentages;
  final Map<String, int> counts;

  BetStudyKpiModel({
    required this.total,
    required this.percentages,
    required this.counts,
  });

  factory BetStudyKpiModel.fromJson(Map<String, dynamic> json) {
    return BetStudyKpiModel(
      total: json['total'] ?? 0,
      percentages: Map<String, double>.from(
        (json['percentages'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      counts: Map<String, int>.from(
        (json['counts'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as int),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'percentages': percentages, 'counts': counts};
  }

  // Getters pour faciliter l'accès aux données
  double get pendingPercentage => percentages['PENDING'] ?? 0.0;
  double get inProgressPercentage => percentages['IN_PROGRESS'] ?? 0.0;
  double get deliveredPercentage => percentages['DELIVERED'] ?? 0.0;
  double get validatedPercentage => percentages['VALIDATED'] ?? 0.0;
  double get rejectedPercentage => percentages['REJECTED'] ?? 0.0;

  int get pendingCount => counts['PENDING'] ?? 0;
  int get inProgressCount => counts['IN_PROGRESS'] ?? 0;
  int get deliveredCount => counts['DELIVERED'] ?? 0;
  int get validatedCount => counts['VALIDATED'] ?? 0;
  int get rejectedCount => counts['REJECTED'] ?? 0;
}


