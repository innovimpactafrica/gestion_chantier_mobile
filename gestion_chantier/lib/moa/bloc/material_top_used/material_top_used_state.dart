import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/moa/models/MaterialTopUsedModel.dart';

abstract class MaterialTopUsedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MaterialTopUsedInitial extends MaterialTopUsedState {}

class MaterialTopUsedLoading extends MaterialTopUsedState {}

class MaterialTopUsedLoaded extends MaterialTopUsedState {
  final List<MaterialTopUsedModel> materials;
  MaterialTopUsedLoaded(this.materials);
  @override
  List<Object?> get props => [materials];
}

class MaterialTopUsedError extends MaterialTopUsedState {
  final String message;
  MaterialTopUsedError(this.message);
  @override
  List<Object?> get props => [message];
}
