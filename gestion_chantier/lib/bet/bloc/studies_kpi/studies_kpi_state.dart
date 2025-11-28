import 'package:gestion_chantier/bet/models/StudyKpiModel.dart';

abstract class BetStudiesKpiState {}

class BetStudiesKpiInitial extends BetStudiesKpiState {}

class BetStudiesKpiLoading extends BetStudiesKpiState {}

class BetStudiesKpiLoaded extends BetStudiesKpiState {
  final BetStudyKpiModel kpiData;

  BetStudiesKpiLoaded({required this.kpiData});
}

class BetStudiesKpiError extends BetStudiesKpiState {
  final String message;

  BetStudiesKpiError({required this.message});
}


