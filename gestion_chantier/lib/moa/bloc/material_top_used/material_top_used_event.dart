import 'package:equatable/equatable.dart';

abstract class MaterialTopUsedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMaterialTopUsed extends MaterialTopUsedEvent {
  final int propertyId;
  FetchMaterialTopUsed(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
