class IncidentModel {
  final int id;
  final String title;
  final String description;
  final List<int> createdAt;
  final String propertyName;
  final List<String> pictures;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.propertyName,
    required this.pictures,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: List<int>.from(json['createdAt'] ?? []),
      propertyName: json['propertyName'] ?? '',
      pictures: List<String>.from(json['pictures'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'propertyName': propertyName,
      'pictures': pictures,
    };
  }

  DateTime get createdAtDateTime {
    if (createdAt.length >= 7) {
      return DateTime(
        createdAt[0], // year
        createdAt[1], // month
        createdAt[2], // day
        createdAt[3], // hour
        createdAt[4], // minute
        createdAt[5], // second
        createdAt[6] ~/ 1000000, // nanoseconds to milliseconds
      );
    }
    return DateTime.now();
  }

  String get formattedDate {
    final date = createdAtDateTime;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedTime {
    final date = createdAtDateTime;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String? get firstImage {
    return pictures.isNotEmpty ? pictures.first : null;
  }
}

class IncidentResponse {
  final List<IncidentModel> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final bool first;
  final int size;
  final int number;

  IncidentResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.first,
    required this.size,
    required this.number,
  });

  factory IncidentResponse.fromJson(Map<String, dynamic> json) {
    return IncidentResponse(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((item) => IncidentModel.fromJson(item))
              .toList() ??
          [],
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      last: json['last'] ?? false,
      first: json['first'] ?? false,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
    );
  }
}
