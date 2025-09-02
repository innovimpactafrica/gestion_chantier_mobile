// bloc/materiels/material_state.dart
import 'package:gestion_chantier/moa/models/material_kpi.dart';
import 'package:gestion_chantier/moa/models/MaterialModel.dart';

abstract class MaterialState {}

class MaterialInitial extends MaterialState {}

class MaterialLoading extends MaterialState {}

class MaterialError extends MaterialState {
  final String message;

  MaterialError(this.message);
}

class TopUsedMaterialsLoaded extends MaterialState {
  final List<StockItem> materials;

  TopUsedMaterialsLoaded(this.materials);
}

class CriticalMaterialsLoaded extends MaterialState {
  final List<StockItem> materials;

  CriticalMaterialsLoaded(this.materials);
}

class MaterialsLoaded extends MaterialState {
  final List<StockItem> topUsedMaterials;
  final List<StockItem> criticalMaterials;

  MaterialsLoaded({
    required this.topUsedMaterials,
    required this.criticalMaterials,
  });
}

class UnitsLoading extends MaterialState {}

class UnitsLoaded extends MaterialState {
  final List<Unit> units;

  UnitsLoaded(this.units);
}

class UnitsError extends MaterialState {
  final String message;

  UnitsError(this.message);
}

class MaterialAdding extends MaterialState {}

class MaterialAdded extends MaterialState {
  final MaterialModel material;

  MaterialAdded(this.material);
}

class MaterialAddError extends MaterialState {
  final String message;

  MaterialAddError(this.message);
}
