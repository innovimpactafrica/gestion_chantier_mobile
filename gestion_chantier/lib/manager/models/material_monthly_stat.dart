class MaterialMonthlyStat {
  final String date; // format MM-YYYY
  final int totalEntries;
  final int totalExits;

  MaterialMonthlyStat({
    required this.date,
    required this.totalEntries,
    required this.totalExits,
  });

  factory MaterialMonthlyStat.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      return int.tryParse(value.toString()) ?? 0;
    }

    return MaterialMonthlyStat(
      date: json['date'] as String,
      totalEntries: parseInt(json['totalEntries']),
      totalExits: parseInt(json['totalExits']),
    );
  }
}
