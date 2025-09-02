import 'package:gestion_chantier/manager/models/RealEstateModel.dart';

enum PhaseType { GROS_OEUVRE, SECOND_OEUVRE, FINITION }

class ConstructionPhaseIndicator {
  final int id;
  final RealEstateModel? realEstateProperty; // Made nullable
  final PhaseType phaseName;
  final int progressPercentage;
  final DateTime lastUpdated;

  ConstructionPhaseIndicator({
    required this.id,
    this.realEstateProperty, // Made nullable
    required this.phaseName,
    required this.progressPercentage,
    required this.lastUpdated,
  });

  factory ConstructionPhaseIndicator.fromJson(Map<String, dynamic> json) {
    return ConstructionPhaseIndicator(
      id: json['id'] as int,
      // Handle nullable realEstateProperty
      realEstateProperty:
          json['realEstateProperty'] != null
              ? RealEstateModel.fromJson(
                json['realEstateProperty'] as Map<String, dynamic>,
              )
              : null,
      phaseName: _parsePhaseType(json['phaseName'] as String),
      progressPercentage: json['progressPercentage'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realEstateProperty': realEstateProperty?.toJson(), // Handle nullable
      'phaseName': phaseName.name,
      'progressPercentage': progressPercentage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static PhaseType _parsePhaseType(String phase) {
    switch (phase) {
      case 'GROS_OEUVRE':
        return PhaseType.GROS_OEUVRE;
      case 'SECOND_OEUVRE':
        return PhaseType.SECOND_OEUVRE;
      case 'FINITION':
        return PhaseType.FINITION;
      default:
        throw ArgumentError('Phase type non supporté: $phase');
    }
  }

  // Méthode utilitaire pour obtenir le nom de la phase en français
  String get phaseDisplayName {
    switch (phaseName) {
      case PhaseType.GROS_OEUVRE:
        return 'Gros Œuvre';
      case PhaseType.SECOND_OEUVRE:
        return 'Second Œuvre';
      case PhaseType.FINITION:
        return 'Finition';
    }
  }

  @override
  String toString() {
    return 'ConstructionPhaseIndicator{id: $id, phaseName: $phaseName, progressPercentage: $progressPercentage, lastUpdated: $lastUpdated}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstructionPhaseIndicator &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
