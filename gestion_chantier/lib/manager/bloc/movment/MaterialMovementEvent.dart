import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';

abstract class MaterialMovementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMaterialMovements extends MaterialMovementEvent {
  final int materialId;
  final bool reset;

  LoadMaterialMovements({required this.materialId, this.reset = false});

  @override
  List<Object?> get props => [materialId, reset];
}

class AddMaterialMovement extends MaterialMovementEvent {
  final int materialId;
  final double quantity;
  final MovementType type;
  final String? comment;

  AddMaterialMovement({
    required this.materialId,
    required this.quantity,
    required this.type,
    this.comment,
  });

  @override
  List<Object?> get props => [materialId, quantity, type, comment];
}

class DeleteMaterialMovement extends MaterialMovementEvent {
  final int movementId;
  final int materialId;


  DeleteMaterialMovement(this.movementId,this.materialId);

  @override
  List<Object?> get props => [movementId];
}


