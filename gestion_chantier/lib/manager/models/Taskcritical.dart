// models/task.dart

import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/models/UserModel.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final RealEstateModel? realEstateProperty;
  final List<UserModel> executors;
  final List<String> pictures;
  final DateTime startDate;
  final DateTime endDate;
  final String? color;
  final String? statusLabel;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.realEstateProperty,
    required this.executors,
    required this.pictures,
    required this.startDate,
    required this.endDate,
    this.color,
    this.statusLabel,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: TaskPriority.fromString(json['priority'] ?? 'LOW'),
      status: TaskStatus.fromString(json['status'] ?? 'TODO'),
      realEstateProperty:
          json['realEstateProperty'] != null
              ? RealEstateModel.fromJson(json['realEstateProperty'])
              : null,
      executors:
          (json['executors'] as List?)
              ?.map((x) => UserModel.fromJson(x))
              .toList() ??
          [],
      pictures:
          (json['pictures'] as List?)?.map((x) => x.toString()).toList() ?? [],
      startDate:
          json['startDate'] != null
              ? _parseDateTime(json['startDate'])
              : DateTime.now(),
      endDate: _parseDateTime(json['endDate']),
      color: json['color'],
      statusLabel: json['statusLabel'],
    );
  }

  static DateTime _parseDateTime(dynamic dateData) {
    if (dateData is List && dateData.length >= 3) {
      return DateTime(
        dateData[0], // year
        dateData[1], // month
        dateData[2], // day
        dateData.length > 3 ? dateData[3] : 0, // hour
        dateData.length > 4 ? dateData[4] : 0, // minute
        dateData.length > 5 ? dateData[5] : 0, // second
      );
    } else if (dateData is String) {
      try {
        return DateTime.parse(dateData);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.value,
      'status': status.value,
      'realEstateProperty': realEstateProperty?.toJson(),
      'executors': executors.map((x) => x.toJson()).toList(),
      'pictures': pictures,
      'startDate': _dateTimeToList(startDate),
      'endDate': _dateTimeToList(endDate),
      'color': color,
      'statusLabel': statusLabel,
    };
  }

  static List<int> _dateTimeToList(DateTime dateTime) {
    return [
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond * 1000000,
    ];
  }

  // Méthodes utilitaires pour la compatibilité avec CriticalTask
  int? get daysRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference > 0 ? difference : null;
  }

  String get formattedDate {
    return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }

  TaskStatus get criticalStatus {
    // Si l'API fournit déjà un statusLabel, utilisons-le
    if (statusLabel != null) {
      switch (statusLabel!.toLowerCase()) {
        case 'en retard':
          return TaskStatus.delayed;
        case 'urgent':
          return TaskStatus.urgent;
        case 'à jour':
          return TaskStatus.upToDate;
        default:
          return _calculateCriticalStatus();
      }
    }
    return _calculateCriticalStatus();
  }

  TaskStatus _calculateCriticalStatus() {
    final now = DateTime.now();
    final daysLeft = endDate.difference(now).inDays;

    if (daysLeft < 0) {
      return TaskStatus.delayed;
    } else if (daysLeft <= 3) {
      return TaskStatus.urgent;
    } else {
      return TaskStatus.upToDate;
    }
  }
}

enum TaskPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const TaskPriority(this.value);
  final String value;

  static TaskPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'HIGH':
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }
}

enum TaskStatus {
  todo('TODO'),
  inProgress('IN_PROGRESS'),
  done('DONE'),
  delayed('DELAYED'),
  urgent('URGENT'),
  upToDate('UP_TO_DATE');

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TODO':
        return TaskStatus.todo;
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      case 'DELAYED':
        return TaskStatus.delayed;
      case 'URGENT':
        return TaskStatus.urgent;
      case 'UP_TO_DATE':
        return TaskStatus.upToDate;
      default:
        return TaskStatus.todo;
    }
  }
}
