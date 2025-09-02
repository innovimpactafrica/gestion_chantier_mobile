import 'package:equatable/equatable.dart';

abstract class ConstructionIndicatorEvent extends Equatable {
  const ConstructionIndicatorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load indicators for a property
class LoadIndicatorsByProperty extends ConstructionIndicatorEvent {
  final int propertyId;

  const LoadIndicatorsByProperty(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Event to update an indicator
class UpdateIndicator extends ConstructionIndicatorEvent {
  final int indicatorId;
  final int progressPercentage;

  const UpdateIndicator({
    required this.indicatorId,
    required this.progressPercentage,
  });

  @override
  List<Object?> get props => [indicatorId, progressPercentage];
}

/// Event to refresh indicators
class RefreshIndicators extends ConstructionIndicatorEvent {
  final int propertyId;

  const RefreshIndicators(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
