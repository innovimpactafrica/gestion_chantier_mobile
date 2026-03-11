class PresenceLog {
  final int id;
  final List<int> checkInTime;
  final List<int> checkOutTime;

  PresenceLog({
    required this.id,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory PresenceLog.fromJson(Map<String, dynamic> json) {
    return PresenceLog(
      id: json['id'] ?? 0,
      checkInTime: _parseTime(json['checkInTime']),
      checkOutTime: _parseTime(json['checkOutTime']),
    );
  }

  /// Handles both array [h, m, s] and object {hour, minute, second, nano}
  static List<int> _parseTime(dynamic time) {
    if (time == null) return [];
    if (time is List) return List<int>.from(time);
    if (time is Map) {
      return [
        (time['hour'] as num?)?.toInt() ?? 0,
        (time['minute'] as num?)?.toInt() ?? 0,
        (time['second'] as num?)?.toInt() ?? 0,
      ];
    }
    return [];
  }

  String get formattedCheckIn => _formatTime(checkInTime);
  String get formattedCheckOut => _formatTime(checkOutTime);

  static String _formatTime(List<int> time) {
    if (time.length < 2) return '--:--';
    final h = time[0].toString().padLeft(2, '0');
    final m = time[1].toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class PresenceHistoryModel {
  final List<PresenceLog> logs;
  final String totalWorkedTime;

  PresenceHistoryModel({required this.logs, required this.totalWorkedTime});

  factory PresenceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PresenceHistoryModel(
      logs: (json['logs'] as List? ?? [])
          .map((e) => PresenceLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalWorkedTime: json['totalWorkedTime'] ?? '',
    );
  }
}
