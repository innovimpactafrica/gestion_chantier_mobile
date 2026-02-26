import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';


abstract class MaterialMovementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MaterialMovementInitial extends MaterialMovementState {}

class MaterialMovementLoading extends MaterialMovementState {
  final bool isInitialLoad;
  final List<MaterialMovementModel>? previousMovements;

  MaterialMovementLoading({this.isInitialLoad = false, this.previousMovements});

  @override
  List<Object?> get props => [isInitialLoad, previousMovements ?? []];
}




class MaterialMovementLoaded extends MaterialMovementState {
  final List<MaterialMovementModel> movements;
  final bool hasReachedMax;

  MaterialMovementLoaded({required this.movements, this.hasReachedMax = false});

  @override
  List<Object?> get props => [movements, hasReachedMax];
}

class MaterialMovementError extends MaterialMovementState {
  final String message;

  MaterialMovementError(this.message);

  @override
  List<Object?> get props => [message];
}

class MaterialMovementActionSuccess extends MaterialMovementState {
  final String message;

  MaterialMovementActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}