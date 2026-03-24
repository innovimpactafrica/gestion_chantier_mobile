import 'package:equatable/equatable.dart';

abstract class MaterialKpiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMaterialUnitDistribution extends MaterialKpiEvent {
  final int propertyId;
  final DateTime? startDate;
  final DateTime? endDate;
  FetchMaterialUnitDistribution(this.propertyId, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [propertyId, startDate, endDate];
}
