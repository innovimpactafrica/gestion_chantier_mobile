// bloc/materiels/material_event.dart
import 'package:equatable/equatable.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopUsedMaterials extends MaterialEvent {}

class LoadCriticalMaterials extends MaterialEvent {}

class RefreshMaterials extends MaterialEvent {}

class LoadUnits extends MaterialEvent {}

class AddMaterialToInventory extends MaterialEvent {
  final String label;
  final int quantity;
  final int criticalThreshold;
  final int unitId;
  final int propertyId;

  const AddMaterialToInventory({
    required this.label,
    required this.quantity,
    required this.criticalThreshold,
    required this.unitId,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [
    label,
    quantity,
    criticalThreshold,
    unitId,
    propertyId,
  ];
}
