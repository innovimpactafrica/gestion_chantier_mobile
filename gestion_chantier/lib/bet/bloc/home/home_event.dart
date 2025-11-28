import 'package:gestion_chantier/bet/models/UserModel.dart';

abstract class BetHomeEvent {}

class LoadCurrentUserEvent extends BetHomeEvent {}

class SetCurrentUserEvent extends BetHomeEvent {
  final BetUserModel user;

  SetCurrentUserEvent({required this.user});
}

class LoadBetKpisEvent extends BetHomeEvent {
  final int betId;

  LoadBetKpisEvent({required this.betId});
}

class LoadBetVolumetryEvent extends BetHomeEvent {
  final int betId;

  LoadBetVolumetryEvent({required this.betId});
}
