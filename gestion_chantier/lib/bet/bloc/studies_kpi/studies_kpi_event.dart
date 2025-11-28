abstract class BetStudiesKpiEvent {}

class LoadBetStudiesKpi extends BetStudiesKpiEvent {
  final int betId;

  LoadBetStudiesKpi({required this.betId});
}


