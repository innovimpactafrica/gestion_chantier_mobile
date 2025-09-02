import 'package:gestion_chantier/moa/models/PropertyType.dart';

class RapportModel {
  final int id;
  final String title;
  final String description;
  final String pdfUrl;
  final PropertyType propertyType;
  final DateTime lastUpdated;

  RapportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pdfUrl,
    required this.propertyType,
    required this.lastUpdated,
  });

  factory RapportModel.fromJson(Map<String, dynamic> json) {
    return RapportModel(
      id: _parseId(json['id']),
      title: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      pdfUrl: json['pdf']?.toString() ?? '',
      propertyType: PropertyType.fromJson(json['propertyType'] ?? {}),
      lastUpdated: _parseDateTime(json['lastUpdated']),
    );
  }

  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString is String) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': title,
      'description': description,
      'pdf': pdfUrl,
      'propertyType': propertyType.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
