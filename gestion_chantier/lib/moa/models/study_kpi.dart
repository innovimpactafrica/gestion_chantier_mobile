class StudyKpiModel {
  final int total;
  final Map<String, int> counts;
  final Map<String, double> percentages;

  const StudyKpiModel({
    required this.total,
    required this.counts,
    required this.percentages,
  });

  factory StudyKpiModel.fromJson(Map<String, dynamic> json) {
    final countsRaw = (json['counts'] as Map<String, dynamic>? ?? {});
    final percentagesRaw = (json['percentages'] as Map<String, dynamic>? ?? {});

    return StudyKpiModel(
      total:
          json['total'] is int
              ? json['total'] as int
              : (json['total'] ?? 0).toInt(),
      counts: countsRaw.map(
        (key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
      ),
      percentages: percentagesRaw.map(
        (key, value) =>
            MapEntry(key.toString(), (value as num?)?.toDouble() ?? 0.0),
      ),
    );
  }

  int get pendingCount => counts['PENDING'] ?? 0;
  int get inProgressCount => counts['IN_PROGRESS'] ?? 0;
  int get validatedCount => counts['VALIDATED'] ?? 0;
  int get rejectedCount => counts['REJECTED'] ?? 0;

  double get pendingPct => percentages['PENDING'] ?? 0.0;
  double get inProgressPct => percentages['IN_PROGRESS'] ?? 0.0;
  double get validatedPct => percentages['VALIDATED'] ?? 0.0;
  double get rejectedPct => percentages['REJECTED'] ?? 0.0;
}
