class BetStudyModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final List<int> createdAt;
  final int propertyId;
  final String propertyName;
  final String propertyImg;
  final int moaId;
  final String moaName;
  final int betId;
  final String betName;
  final List<BetReportModel> reports;

  BetStudyModel({
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

  factory BetStudyModel.fromJson(Map<String, dynamic> json) {
    return BetStudyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: List<int>.from(json['createdAt'] ?? []),
      propertyId: json['propertyId'] ?? 0,
      propertyName: json['propertyName'] ?? '',
      propertyImg: json['propertyImg'] ?? '',
      moaId: json['moaId'] ?? 0,
      moaName: json['moaName'] ?? '',
      betId: json['betId'] ?? 0,
      betName: json['betName'] ?? '',
      reports:
          (json['reports'] as List<dynamic>?)
              ?.map((report) => BetReportModel.fromJson(report))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyImg': propertyImg,
      'moaId': moaId,
      'moaName': moaName,
      'betId': betId,
      'betName': betName,
      'reports': reports.map((report) => report.toJson()).toList(),
    };
  }

  // Getters pour faciliter l'accès aux données
  DateTime get createdDate {
    if (createdAt.length >= 6) {
      return DateTime(
        createdAt[0], // year
        createdAt[1], // month
        createdAt[2], // day
        createdAt[3], // hour
        createdAt[4], // minute
        createdAt[5], // second
      );
    }
    return DateTime.now();
  }

  String get formattedCreatedDate {
    final date = createdDate;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get statusDisplayName {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'IN_PROGRESS':
        return 'En cours';
      case 'DELIVERED':
        return 'Livrée';
      case 'VALIDATED':
        return 'Validée';
      case 'REJECTED':
        return 'Rejetée';
      default:
        return status;
    }
  }
}

class BetReportModel {
  final int id;
  final String title;
  final String fileUrl;
  final int versionNumber;
  final List<int> submittedAt;
  final int authorId;
  final String authorName;

  BetReportModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.versionNumber,
    required this.submittedAt,
    required this.authorId,
    required this.authorName,
  });

  factory BetReportModel.fromJson(Map<String, dynamic> json) {
    return BetReportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      versionNumber: json['versionNumber'] ?? 0,
      submittedAt: List<int>.from(json['submittedAt'] ?? []),
      authorId: json['authorId'] ?? 0,
      authorName: json['authorName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileUrl': fileUrl,
      'versionNumber': versionNumber,
      'submittedAt': submittedAt,
      'authorId': authorId,
      'authorName': authorName,
    };
  }

  DateTime get submittedDate {
    if (submittedAt.length >= 6) {
      return DateTime(
        submittedAt[0], // year
        submittedAt[1], // month
        submittedAt[2], // day
        submittedAt[3], // hour
        submittedAt[4], // minute
        submittedAt[5], // second
      );
    }
    return DateTime.now();
  }

  String get formattedSubmittedDate {
    final date = submittedDate;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get displayInfo {
    return 'Créé le $formattedSubmittedDate • ${_getFileSize()}';
  }

  String _getFileSize() {
    // Pour l'instant, on retourne une taille fictive
    // Dans une vraie app, on pourrait calculer la taille du fichier
    return '1,2 Mo';
  }
}

class BetStudiesResponseModel {
  final List<BetStudyModel> content;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int numberOfElements;
  final int size;
  final int number;
  final bool first;
  final bool empty;

  BetStudiesResponseModel({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.numberOfElements,
    required this.size,
    required this.number,
    required this.first,
    required this.empty,
  });

  factory BetStudiesResponseModel.fromJson(Map<String, dynamic> json) {
    return BetStudiesResponseModel(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((study) => BetStudyModel.fromJson(study))
              .toList() ??
          [],
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      last: json['last'] ?? false,
      numberOfElements: json['numberOfElements'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? false,
      empty: json['empty'] ?? true,
    );
  }
}
