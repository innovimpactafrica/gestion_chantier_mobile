class BetVolumetryModel {
  final int totalStudyRequests;
  final int distinctPropertiesCount;
  final int totalReports;

  BetVolumetryModel({
    required this.totalStudyRequests,
    required this.distinctPropertiesCount,
    required this.totalReports,
  });

  factory BetVolumetryModel.fromJson(Map<String, dynamic> json) {
    return BetVolumetryModel(
      totalStudyRequests: json['totalStudyRequests'] ?? 0,
      distinctPropertiesCount: json['distinctPropertiesCount'] ?? 0,
      totalReports: json['totalReports'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudyRequests': totalStudyRequests,
      'distinctPropertiesCount': distinctPropertiesCount,
      'totalReports': totalReports,
    };
  }
}


