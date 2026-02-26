import 'package:equatable/equatable.dart';
import '../../models/RapportModel.dart';

abstract class RapportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RapportInitial extends RapportState {}

class RapportLoading extends RapportState {}

class RapportLoaded extends RapportState {
  final List<RapportModel> rapports;
  final bool hasReachedMax;

  RapportLoaded({
    required this.rapports,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [rapports, hasReachedMax];
}

class RapportError extends RapportState {
  final String message;

  RapportError(this.message);

  @override
  List<Object?> get props => [message];
}

class RapportActionSuccess extends RapportState {
  final String message;

  RapportActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// AJOUTER CET ÉTAT
class RapportAddedSuccess extends RapportState {
  final String message;

  RapportAddedSuccess({this.message = "Rapport ajouté avec succès"});

  @override
  List<Object?> get props => [message];
}