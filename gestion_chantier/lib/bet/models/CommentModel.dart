import 'package:intl/intl.dart';

class CommentModel {
  final int id;
  final String content;
  final DateTime createdAt;
  final int authorId;
  final String authorName;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      authorId: json['authorId'] ?? 0,
      authorName: json['authorName'] ?? '',
    );
  }

  static DateTime _parseDateTime(List<dynamic>? dateTimeList) {
    if (dateTimeList != null && dateTimeList.length >= 6) {
      return DateTime(
        dateTimeList[0],
        dateTimeList[1],
        dateTimeList[2],
        dateTimeList[3],
        dateTimeList[4],
        dateTimeList[5],
      );
    }
    return DateTime.now(); // Fallback to current time
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': [
        createdAt.year,
        createdAt.month,
        createdAt.day,
        createdAt.hour,
        createdAt.minute,
        createdAt.second,
        createdAt.millisecond * 1000,
      ],
      'authorId': authorId,
      'authorName': authorName,
    };
  }

  String get formattedDate {
    try {
      return DateFormat('dd MMM yyyy', 'fr').format(createdAt);
    } catch (e) {
      // Fallback to default locale if French is not available
      return DateFormat('dd MMM yyyy').format(createdAt);
    }
  }

  String get formattedTime {
    try {
      return DateFormat('HH:mm', 'fr').format(createdAt);
    } catch (e) {
      // Fallback to default locale if French is not available
      return DateFormat('HH:mm').format(createdAt);
    }
  }

  String get formattedDateTime {
    try {
      return DateFormat('dd MMM yyyy à HH:mm', 'fr').format(createdAt);
    } catch (e) {
      // Fallback to default locale if French is not available
      return DateFormat('dd MMM yyyy HH:mm').format(createdAt);
    }
  }

  String get chatTimestamp {
    try {
      return DateFormat('dd MMM, HH:mm', 'fr').format(createdAt);
    } catch (e) {
      // Fallback to default locale if French is not available
      return DateFormat('dd MMM, HH:mm').format(createdAt);
    }
  }
}
