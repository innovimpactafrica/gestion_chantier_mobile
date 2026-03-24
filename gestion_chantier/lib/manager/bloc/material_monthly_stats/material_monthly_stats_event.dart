import 'package:equatable/equatable.dart';

abstract class MaterialMonthlyStatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMaterialMonthlyStats extends MaterialMonthlyStatsEvent {
  final int propertyId;
  final DateTime? startDate;
  final DateTime? endDate;
  FetchMaterialMonthlyStats(this.propertyId, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [propertyId, startDate, endDate];
}
