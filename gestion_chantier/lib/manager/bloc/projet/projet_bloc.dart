import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/projet/projet_event.dart';
import 'package:gestion_chantier/manager/bloc/projet/projet_state.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/services/ProjetService.dart';

class ProjetsBloc extends Bloc<ProjetsEvent, ProjetsState> {
  final RealEstateService _realEstateService;
  final int promoterId; // Ajout de l'ID du promoteur
  List<RealEstateModel> _allProjets = [];

  ProjetsBloc({
    required this.promoterId, // Requis maintenant
    RealEstateService? realEstateService,
  }) : _realEstateService = realEstateService ?? RealEstateService(),
       super(ProjetsInitialState()) {
    on<LoadProjetsEvent>(_onLoadProjets);
    on<RefreshProjetsEvent>(_onRefreshProjets);
    on<SearchProjetsEvent>(_onSearchProjets);
    on<LoadProjetsByStatusEvent>(_onLoadProjetsByStatus);
  }

  Future<void> _onLoadProjets(
    LoadProjetsEvent event,
    Emitter<ProjetsState> emit,
  ) async {
    emit(ProjetsLoadingState());
    try {
      final projets = await _realEstateService.getPromoterProjects(promoterId);
      _allProjets = projets;
      emit(ProjetsLoadedState(projets: projets, filteredProjets: projets));
    } catch (e) {
      emit(ProjetsErrorState(e.toString()));
    }
  }

  Future<void> _onRefreshProjets(
    RefreshProjetsEvent event,
    Emitter<ProjetsState> emit,
  ) async {
    try {
      final projets = await _realEstateService.getPromoterProjects(promoterId);
      _allProjets = projets;

      if (state is ProjetsLoadedState) {
        final currentState = state as ProjetsLoadedState;
        final filteredProjets = _filterProjets(
          projets,
          currentState.currentFilter,
        );
        emit(
          currentState.copyWith(
            projets: projets,
            filteredProjets: filteredProjets,
          ),
        );
      } else {
        emit(ProjetsLoadedState(projets: projets, filteredProjets: projets));
      }
    } catch (e) {
      emit(ProjetsErrorState(e.toString()));
    }
  }

  Future<void> _onSearchProjets(
    SearchProjetsEvent event,
    Emitter<ProjetsState> emit,
  ) async {
    if (state is ProjetsLoadedState) {
      final currentState = state as ProjetsLoadedState;

      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredProjets: _allProjets,
            currentFilter: '',
          ),
        );
      } else {
        try {
          // Option 1: Filtrage local
          final filteredProjets = _filterProjets(_allProjets, event.query);
          emit(
            currentState.copyWith(
              filteredProjets: filteredProjets,
              currentFilter: event.query,
            ),
          );

          // Option 2: Recherche côté serveur (décommenter si nécessaire)
          /*
          final filtered = await _realEstateService.searchProjects(
            event.query,
            promoterId,
          );
          emit(currentState.copyWith(
            filteredProjets: filtered,
            currentFilter: event.query,
          ));
          */
        } catch (e) {
          emit(ProjetsErrorState('Erreur de recherche: ${e.toString()}'));
        }
      }
    }
  }

  Future<void> _onLoadProjetsByStatus(
    LoadProjetsByStatusEvent event,
    Emitter<ProjetsState> emit,
  ) async {
    emit(ProjetsLoadingState());
    try {
      List<RealEstateModel> projets;
      if (event.status == 'all') {
        projets = await _realEstateService.getPromoterProjects(promoterId);
      } else {
        projets = await _realEstateService.getProjectsByStatus(
          event.status,
          promoterId, // Ajout de l'ID du promoteur
        );
      }
      _allProjets = projets;
      emit(ProjetsLoadedState(projets: projets, filteredProjets: projets));
    } catch (e) {
      emit(ProjetsErrorState(e.toString()));
    }
  }

  List<RealEstateModel> _filterProjets(
    List<RealEstateModel> projets,
    String query,
  ) {
    if (query.isEmpty) return projets;

    return projets.where((projet) {
      final name = projet.name.toLowerCase();
      final address = projet.address.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();
  }
}
