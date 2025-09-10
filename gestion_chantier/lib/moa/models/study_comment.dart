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
      id: json['id'],
      content: json['content'],
      createdAt: DateTime(
        json['createdAt'][0],
        json['createdAt'][1],
        json['createdAt'][2],
        json['createdAt'][3],
        json['createdAt'][4],
        json['createdAt'][5],
      ),
      authorId: json['authorId'],
      authorName: json['authorName'],
    );
  }
}
