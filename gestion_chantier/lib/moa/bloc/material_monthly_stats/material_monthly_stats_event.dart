import 'package:equatable/equatable.dart';

abstract class MaterialMonthlyStatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMaterialMonthlyStats extends MaterialMonthlyStatsEvent {
  final int propertyId;
  FetchMaterialMonthlyStats(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
