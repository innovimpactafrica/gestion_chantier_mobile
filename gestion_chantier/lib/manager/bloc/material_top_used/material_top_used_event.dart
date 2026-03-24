import 'package:equatable/equatable.dart';

abstract class MaterialTopUsedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMaterialTopUsed extends MaterialTopUsedEvent {
  final int propertyId;
  final DateTime? startDate;
  final DateTime? endDate;
  FetchMaterialTopUsed(this.propertyId, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [propertyId, startDate, endDate];
}
