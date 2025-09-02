// bloc/projet/projet_bloc.dart

abstract class ProjetsEvent {}

class LoadProjetsEvent extends ProjetsEvent {}

class RefreshProjetsEvent extends ProjetsEvent {}

class SearchProjetsEvent extends ProjetsEvent {
  final String query;
  SearchProjetsEvent(this.query);
}

class LoadProjetsByStatusEvent extends ProjetsEvent {
  final String status;
  LoadProjetsByStatusEvent(this.status);
}
