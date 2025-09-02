import 'package:gestion_chantier/manager/models/RealEstateModel.dart';

abstract class ProjetsState {}

class ProjetsInitialState extends ProjetsState {}

class ProjetsLoadingState extends ProjetsState {}

class ProjetsLoadedState extends ProjetsState {
  final List<RealEstateModel> projets;
  final List<RealEstateModel> filteredProjets;
  final String currentFilter;

  ProjetsLoadedState({
    required this.projets,
    required this.filteredProjets,
    this.currentFilter = '',
  });

  ProjetsLoadedState copyWith({
    List<RealEstateModel>? projets,
    List<RealEstateModel>? filteredProjets,
    String? currentFilter,
  }) {
    return ProjetsLoadedState(
      projets: projets ?? this.projets,
      filteredProjets: filteredProjets ?? this.filteredProjets,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class ProjetsErrorState extends ProjetsState {
  final String message;
  ProjetsErrorState(this.message);
}
