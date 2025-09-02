import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/moa/models/ConstructionPhaseIndicatorModel.dart';

abstract class ConstructionIndicatorState extends Equatable {
  const ConstructionIndicatorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConstructionIndicatorInitial extends ConstructionIndicatorState {}

/// Loading state
class ConstructionIndicatorLoading extends ConstructionIndicatorState {}

/// Refreshing state with existing data
class ConstructionIndicatorRefreshing extends ConstructionIndicatorState {
  final List<ConstructionPhaseIndicator> indicators;

  const ConstructionIndicatorRefreshing(this.indicators);

  @override
  List<Object?> get props => [indicators];
}

/// Loaded state with data
class ConstructionIndicatorLoaded extends ConstructionIndicatorState {
  final List<ConstructionPhaseIndicator> indicators;

  const ConstructionIndicatorLoaded(this.indicators);

  @override
  List<Object?> get props => [indicators];

  /// Helper methods to get progress by phase
  int getProgressByPhase(PhaseType phase) {
    try {
      return indicators
          .firstWhere((indicator) => indicator.phaseName == phase)
          .progressPercentage;
    } catch (e) {
      return 0; // Returns 0 if phase not found
    }
  }

  /// Gets all progress percentages in phase order
  List<int> getAllProgressPercentages() {
    return [
      getProgressByPhase(PhaseType.GROS_OEUVRE),
      getProgressByPhase(PhaseType.SECOND_OEUVRE),
      getProgressByPhase(PhaseType.FINITION),
    ];
  }
}

/// Updating state
class ConstructionIndicatorUpdating extends ConstructionIndicatorState {
  final List<ConstructionPhaseIndicator> indicators;
  final int updatingIndicatorId;

  const ConstructionIndicatorUpdating({
    required this.indicators,
    required this.updatingIndicatorId,
  });

  @override
  List<Object?> get props => [indicators, updatingIndicatorId];
}

/// Error state
class ConstructionIndicatorError extends ConstructionIndicatorState {
  final String message;
  final List<ConstructionPhaseIndicator>? previousIndicators;

  const ConstructionIndicatorError(this.message, {this.previousIndicators});

  @override
  List<Object?> get props => [message, previousIndicators];
}
