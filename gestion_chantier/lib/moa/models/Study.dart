import 'dart:ui';
import 'package:flutter/material.dart';

/// Enum pour les différents statuts d'une étude
enum StudyStatus {
  all('all', 'Tous'),
  pending('pending', 'En attente'),
  inProgress('inProgress', 'En cours'),
  delivered('delivered', 'Livrée'),
  validated('validated', 'Validée'),
  rejected('rejected', 'Rejetée');

  const StudyStatus(this.value, this.label);
  final String value;
  final String label;

  /// Convertir depuis une string
  static StudyStatus fromString(String value) {
    return StudyStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => StudyStatus.pending,
    );
  }
}

/// Extension publique pour les méthodes UI du StudyStatus
extension StudyStatusUI on StudyStatus {
  /// Couleur de fond du badge de statut
  Color badgeBg(BuildContext context) => switch (this) {
        StudyStatus.pending => const Color(0xFFE8F0FE), // light blue
        StudyStatus.inProgress => const Color(0xFFFFF4D6), // light yellow
        StudyStatus.delivered => const Color(0xFFF0E6FF), // light purple
        StudyStatus.validated => const Color(0xFFE7F7ED), // light green
        StudyStatus.rejected => const Color(0xFFFDECEF), // light red
        StudyStatus.all => Colors.transparent,
      };

  /// Couleur du texte du badge de statut
  Color badgeFg(BuildContext context) => switch (this) {
        StudyStatus.pending => const Color(0xFF3366FF),
        StudyStatus.inProgress => const Color(0xFF9A6B00),
        StudyStatus.delivered => const Color(0xFF6E44FF),
        StudyStatus.validated => const Color(0xFF2E7D32),
        StudyStatus.rejected => const Color(0xFFB00020),
        StudyStatus.all => Theme.of(context).colorScheme.onSurface,
      };
}

/// Type d'étude BET
enum StudyType {
  structure('structure', 'Structure'),
  acoustic('acoustic', 'Acoustique'),
  hvac('hvac', 'CVC'),
  vrd('vrd', 'VRD'),
  electrical('electrical', 'Électricité'),
  plumbing('plumbing', 'Plomberie');

  const StudyType(this.value, this.label);
  final String value;
  final String label;

  static StudyType fromString(String value) {
    return StudyType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => StudyType.structure,
    );
  }
}

/// Modèle représentant une étude BET
class Study {
  final String id;
  final String title;
  final String description;
  final StudyType type;
  final StudyStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String assignedTo;
  final String? rejectionReason;
  final List<Report> reports;
  final String projectId;

  const Study({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.assignedTo,
    this.rejectionReason,
    this.reports = const [],
    required this.projectId,
  });

  /// Constructeur depuis JSON
  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: StudyType.fromString(json['type'] as String),
      status: StudyStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      assignedTo: json['assignedTo'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      reports: (json['reports'] as List<dynamic>? ?? [])
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      projectId: json['projectId'] as String,
    );
  }

  /// Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'rejectionReason': rejectionReason,
      'reports': reports.map((e) => e.toJson()).toList(),
      'projectId': projectId,
    };
  }

  /// Créer une copie avec des modifications
  Study copyWith({
    String? id,
    String? title,
    String? description,
    StudyType? type,
    StudyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    String? rejectionReason,
    List<Report>? reports,
    String? projectId,
  }) {
    return Study(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reports: reports ?? this.reports,
      projectId: projectId ?? this.projectId,
    );
  }

  /// Obtenir l'icône selon le type d'étude
  IconData get icon => switch (type) {
        StudyType.structure => Icons.apartment_rounded,
        StudyType.acoustic => Icons.layers_rounded,
        StudyType.hvac => Icons.ac_unit_rounded,
        StudyType.vrd => Icons.traffic_rounded,
        StudyType.electrical => Icons.electrical_services_rounded,
        StudyType.plumbing => Icons.plumbing_rounded,
      };

  /// Obtenir la couleur de fond de l'icône
  Color get iconBg => switch (type) {
        StudyType.structure => const Color(0xFFE8EEF8),
        StudyType.acoustic => const Color(0xFFF6EED9),
        StudyType.hvac => const Color(0xFFF0E6FF),
        StudyType.vrd => const Color(0xFFE7F7ED),
        StudyType.electrical => const Color(0xFFFFF4D6),
        StudyType.plumbing => const Color(0xFFFDECEF),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Study && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Study{id: $id, title: $title, status: $status}';
  }
}

/// Modèle représentant un rapport d'étude
class Report {
  final String id;
  final String title;
  final String version;
  final DateTime createdAt;
  final String fileSize;
  final String fileUrl;
  final String mimeType;
  final String studyId;

  const Report({
    required this.id,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.fileSize,
    required this.fileUrl,
    required this.mimeType,
    required this.studyId,
  });

  /// Constructeur depuis JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      title: json['title'] as String,
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileSize: json['fileSize'] as String,
      fileUrl: json['fileUrl'] as String,
      mimeType: json['mimeType'] as String,
      studyId: json['studyId'] as String,
    );
  }

  /// Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'fileSize': fileSize,
      'fileUrl': fileUrl,
      'mimeType': mimeType,
      'studyId': studyId,
    };
  }

  /// Créer une copie avec des modifications
  Report copyWith({
    String? id,
    String? title,
    String? version,
    DateTime? createdAt,
    String? fileSize,
    String? fileUrl,
    String? mimeType,
    String? studyId,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      mimeType: mimeType ?? this.mimeType,
      studyId: studyId ?? this.studyId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Report{id: $id, title: $title, version: $version}';
  }
}
