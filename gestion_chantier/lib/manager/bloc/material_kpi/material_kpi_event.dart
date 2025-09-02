import 'package:equatable/equatable.dart';

abstract class MaterialKpiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMaterialUnitDistribution extends MaterialKpiEvent {
  final int propertyId;
  FetchMaterialUnitDistribution(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
