// bloc/materiels/material_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/models/material_kpi.dart';
import 'package:gestion_chantier/moa/repository/auth_repository.dart';
import 'package:gestion_chantier/moa/services/MaterialsService.dart';

import 'material_event.dart';
import 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final MaterialsService _materialsService;
  final InventoryRepository _inventoryRepository;

  final List<StockItem> _topUsedMaterials = [];
  List<StockItem> _criticalMaterials = [];

  MaterialBloc(this._materialsService, this._inventoryRepository)
    : super(MaterialInitial()) {
    on<LoadCriticalMaterials>(_onLoadCriticalMaterials);
    on<RefreshMaterials>(_onRefreshMaterials);
    on<LoadUnits>(_onLoadUnits);
    on<AddMaterialToInventory>(_onAddMaterialToInventory);
  }

  Future<void> _onLoadCriticalMaterials(
    LoadCriticalMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      emit(MaterialLoading());

      final materials = await _materialsService.getCriticalMaterials();
      _criticalMaterials = materials;

      emit(CriticalMaterialsLoaded(materials));
    } catch (e) {
      emit(
        MaterialError(
          'Erreur lors du chargement des matériaux critiques: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshMaterials(
    RefreshMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      emit(MaterialLoading());

      // Charger les deux types de matériaux en parallèle
      final results = await Future.wait([
        _materialsService.getCriticalMaterials(),
      ]);

      _criticalMaterials = results[0];

      emit(
        MaterialsLoaded(
          topUsedMaterials: _topUsedMaterials,
          criticalMaterials: _criticalMaterials,
        ),
      );
    } catch (e) {
      emit(
        MaterialError(
          'Erreur lors de l\'actualisation des matériaux: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadUnits(
    LoadUnits event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      emit(UnitsLoading());

      final units = await _inventoryRepository.getUnits();

      emit(UnitsLoaded(units));
    } catch (e) {
      emit(UnitsError('Erreur lors du chargement des unités: ${e.toString()}'));
    }
  }

  Future<void> _onAddMaterialToInventory(
    AddMaterialToInventory event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      emit(MaterialAdding());

      final material = await _inventoryRepository.addMaterialToInventory(
        label: event.label,
        quantity: event.quantity,
        criticalThreshold: event.criticalThreshold,
        unitId: event.unitId,
        propertyId: event.propertyId,
      );

      emit(MaterialAdded(material));
    } catch (e) {
      emit(
        MaterialAddError(
          'Erreur lors de l\'ajout du matériau: ${e.toString()}',
        ),
      );
    }
  }
}
