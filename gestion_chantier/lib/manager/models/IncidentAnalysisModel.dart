class IncidentAnalysisModel {
  final int id;
  final int incidentId;
  final int propertyId;
  final String propertyName;
  final String incidentType;
  final String severity;
  final Map<String, String> explanation;
  final Map<String, String> recommendation;
  final List<int> createdAt;

  IncidentAnalysisModel({
    required this.id,
    required this.incidentId,
    required this.propertyId,
    required this.propertyName,
    required this.incidentType,
    required this.severity,
    required this.explanation,
    required this.recommendation,
    required this.createdAt,
  });

  factory IncidentAnalysisModel.fromJson(Map<String, dynamic> json) {
    return IncidentAnalysisModel(
      id: json['id'] ?? 0,
      incidentId: json['incidentId'] ?? 0,
      propertyId: json['propertyId'] ?? 0,
      propertyName: json['propertyName'] ?? '',
      incidentType: json['incidentType'] ?? '',
      severity: json['severity'] ?? '',
      explanation: Map<String, String>.from(json['explanation'] ?? {}),
      recommendation: Map<String, String>.from(json['recommendation'] ?? {}),
      createdAt: List<int>.from(json['createdAt'] ?? []),
    );
  }

  String get formattedDate {
    if (createdAt.length >= 3) {
      final y = createdAt[0], m = createdAt[1], d = createdAt[2];
      return '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/$y';
    }
    return '';
  }
}
