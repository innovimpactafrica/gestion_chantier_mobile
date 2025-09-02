import 'package:equatable/equatable.dart';

abstract class MaterialKpiState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MaterialKpiInitial extends MaterialKpiState {}

class MaterialKpiLoading extends MaterialKpiState {}

class MaterialKpiLoaded extends MaterialKpiState {
  final Map<String, double> distribution;
  MaterialKpiLoaded(this.distribution);

  @override
  List<Object?> get props => [distribution];
}

class MaterialKpiError extends MaterialKpiState {
  final String message;
  MaterialKpiError(this.message);

  @override
  List<Object?> get props => [message];
}
