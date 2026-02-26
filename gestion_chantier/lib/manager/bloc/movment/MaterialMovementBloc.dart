import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementEvent.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementState.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';
import 'package:gestion_chantier/manager/repository/MaterialMovementRepository.dart';

class MaterialMovementBloc
    extends Bloc<MaterialMovementEvent, MaterialMovementState> {
  final MaterialMovementRepository repository;

  int _page = 0;
  final int _size = 10;
  bool _hasReachedMax = false;
  bool _isFetching = false;
  final List<MaterialMovementModel> _movements = [];

  MaterialMovementBloc({required this.repository})
      : super(MaterialMovementInitial()) {
    on<LoadMaterialMovements>(_onLoadMovements);
    on<AddMaterialMovement>(_onAddMovement);
    on<DeleteMaterialMovement>(_onDeleteMovement);
  }

  Future<void> _onLoadMovements(
      LoadMaterialMovements event, Emitter<MaterialMovementState> emit) async {
    if (_isFetching) return;

    _isFetching = true;

    // 🔹 Affichage du loader avec previousMovements
    if (event.reset) {
      _page = 0;
      _hasReachedMax = false;
      _movements.clear();
      emit(MaterialMovementLoading(isInitialLoad: true));
    } else {
      // pour le scroll infini ou reload partiel
      emit(MaterialMovementLoading(previousMovements: List.from(_movements)));
    }

    try {
      final newMovements = await repository.getMovementsByMaterial(
        event.materialId,
        _page,
        _size,
      );

      if (newMovements.length < _size) _hasReachedMax = true;

      _movements.addAll(newMovements);
      _page++;

      emit(MaterialMovementLoaded(
        movements: List.from(_movements),
        hasReachedMax: _hasReachedMax,
      ));
    } catch (e) {
      emit(MaterialMovementError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onAddMovement(
      AddMaterialMovement event, Emitter<MaterialMovementState> emit) async {
    try {
      await repository.addMovement(
        materialId: event.materialId,
        quantity: event.quantity,
        type: event.type,
        comment: event.comment,
      );

      emit(MaterialMovementActionSuccess("Mouvement ajouté !"));

      // 🔹 Recharge complète de la liste après ajout
      add(LoadMaterialMovements(materialId: event.materialId, reset: true));
    } catch (e) {
      emit(MaterialMovementError(e.toString()));
    }
  }

  Future<void> _onDeleteMovement(
      DeleteMaterialMovement event, Emitter<MaterialMovementState> emit) async {
    try {
      await repository.deleteMovement(event.movementId);

      emit(MaterialMovementActionSuccess("Mouvement supprimé !"));

      // 🔹 Recharge complète de la liste après suppression
      add(LoadMaterialMovements(materialId: event.materialId, reset: true));

    } catch (e) {
      emit(MaterialMovementError(e.toString()));
    }
  }
}
