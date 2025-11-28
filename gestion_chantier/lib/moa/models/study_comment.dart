class StudyComment {
  final int id;
  final String content;
  final DateTime createdAt;
  final int authorId;
  final String authorName;

  StudyComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
  });

  factory StudyComment.fromJson(Map<String, dynamic> json) {
    return StudyComment(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      authorId: json['authorId'] ?? 0,
      authorName: json['authorName'] ?? 'Utilisateur',
    );
  }

  static DateTime _parseDateTime(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    
    // Si c'est une liste [year, month, day, hour, minute, second]
    if (dateData is List && dateData.length >= 3) {
      try {
        return DateTime(
          dateData[0] ?? DateTime.now().year,
          dateData[1] ?? DateTime.now().month,
          dateData[2] ?? DateTime.now().day,
          dateData.length > 3 ? (dateData[3] ?? 0) : 0,
          dateData.length > 4 ? (dateData[4] ?? 0) : 0,
          dateData.length > 5 ? (dateData[5] ?? 0) : 0,
        );
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // Si c'est une chaîne ISO
    if (dateData is String) {
      try {
        return DateTime.parse(dateData);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }
}
