abstract class BetStudiesEvent {}

class LoadBetStudies extends BetStudiesEvent {
  final int betId;
  final int page;
  final int size;

  LoadBetStudies({required this.betId, this.page = 0, this.size = 10});
}

class RefreshBetStudies extends BetStudiesEvent {
  final int betId;

  RefreshBetStudies({required this.betId});
}

class LoadMoreBetStudies extends BetStudiesEvent {
  final int betId;
  final int nextPage;

  LoadMoreBetStudies({required this.betId, required this.nextPage});
}


