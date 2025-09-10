class StudyRequest {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final int propertyId;
  final String propertyName;
  final String propertyImg;
  final int moaId;
  final String moaName;
  final int betId;
  final String betName;
  final List<Report> reports;

  StudyRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.propertyId,
    required this.propertyName,
    required this.propertyImg,
    required this.moaId,
    required this.moaName,
    required this.betId,
    required this.betName,
    required this.reports,
  });

  factory StudyRequest.fromJson(Map<String, dynamic> json) {
    return StudyRequest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime(
        json['createdAt'][0],
        json['createdAt'][1],
        json['createdAt'][2],
        json['createdAt'][3],
        json['createdAt'][4],
        json['createdAt'][5],
      ),
      propertyId: json['propertyId'],
      propertyName: json['propertyName'],
      propertyImg: json['propertyImg'],
      moaId: json['moaId'],
      moaName: json['moaName'],
      betId: json['betId'],
      betName: json['betName'],
      reports: (json['reports'] as List)
          .map((reportJson) => Report.fromJson(reportJson))
          .toList(),
    );
  }
}

class Report {
  final int id;
  final String title;
  final String fileUrl;
  final int versionNumber;
  final DateTime submittedAt;
  final int authorId;
  final String authorName;

  Report({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.versionNumber,
    required this.submittedAt,
    required this.authorId,
    required this.authorName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      fileUrl: json['fileUrl'],
      versionNumber: json['versionNumber'],
      submittedAt: DateTime(
        json['submittedAt'][0],
        json['submittedAt'][1],
        json['submittedAt'][2],
        json['submittedAt'][3],
        json['submittedAt'][4],
        json['submittedAt'][5],
      ),
      authorId: json['authorId'],
      authorName: json['authorName'],
    );
  }
}
