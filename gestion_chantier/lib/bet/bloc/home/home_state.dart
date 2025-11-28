import 'package:gestion_chantier/bet/models/UserModel.dart';
import 'package:gestion_chantier/bet/models/StudyKpiModel.dart';
import 'package:gestion_chantier/bet/models/VolumetryModel.dart';

abstract class BetHomeState {}

class BetHomeInitial extends BetHomeState {}

class BetHomeLoading extends BetHomeState {}

class BetHomeLoaded extends BetHomeState {
  final BetUserModel currentUser;
  final BetStudyKpiModel? kpiData;
  final BetVolumetryModel? volumetryData;

  BetHomeLoaded({required this.currentUser, this.kpiData, this.volumetryData});
}

class BetHomeError extends BetHomeState {
  final String message;

  BetHomeError({required this.message});
}
