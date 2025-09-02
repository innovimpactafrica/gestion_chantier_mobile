import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/moa/models/material_monthly_stat.dart';

abstract class MaterialMonthlyStatsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MaterialMonthlyStatsInitial extends MaterialMonthlyStatsState {}

class MaterialMonthlyStatsLoading extends MaterialMonthlyStatsState {}

class MaterialMonthlyStatsLoaded extends MaterialMonthlyStatsState {
  final List<MaterialMonthlyStat> stats;
  MaterialMonthlyStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class MaterialMonthlyStatsError extends MaterialMonthlyStatsState {
  final String message;
  MaterialMonthlyStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
