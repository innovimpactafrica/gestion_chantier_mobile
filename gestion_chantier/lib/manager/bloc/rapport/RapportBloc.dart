import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/rapport/RapportState.dart';
import 'package:gestion_chantier/manager/repository/RapportRepository.dart';
import '../../models/RapportModel.dart';
import 'RapportEvent.dart';
class RapportBloc extends Bloc<RapportEvent, RapportState> {
  final RapportRepository repository;

  int _page = 0;
  final int _size = 10;
  bool _hasReachedMax = false;
  bool _isFetching = false;

  final List<RapportModel> _rapports = [];

  RapportBloc({required this.repository}) : super(RapportInitial()) {
    on<LoadRapports>(_onLoadRapports);
    on<RefreshRapports>(_onRefresh);
    on<AddRapport>(_onAddRapport);
    on<DeleteRapport>(_onDeleteRapport);
  }

  // ================= LOAD / PAGINATION =================
  Future<void> _onLoadRapports(
      LoadRapports event, Emitter<RapportState> emit) async {
    if (_isFetching || _hasReachedMax) return;

    _isFetching = true;

    if (_page == 0) {
      emit(RapportLoading());
    }

    try {
      final newRapports = await repository.fetchRapports(
        event.userId,
        page: _page,
        size: _size,
      );

      if (newRapports.length < _size) {
        _hasReachedMax = true;
      }

      _rapports.addAll(newRapports);
      _page++;

      emit(
        RapportLoaded(
          rapports: List.from(_rapports),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      emit(RapportError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  // ================= REFRESH =================
  Future<void> _onRefresh(
      RefreshRapports event, Emitter<RapportState> emit) async {
    _page = 0;
    _hasReachedMax = false;
    _rapports.clear();

    add(LoadRapports(userId: event.userId));
  }

  // ================= ADD RAPPORT =================
  Future<void> _onAddRapport(
      AddRapport event, Emitter<RapportState> emit) async {
    try {
      await repository.createRapport(
        titre: event.titre,
        description: event.description,
        propertyId: event.propertyId,
        file: event.file,
      );

      /// 🔔 NOTIFICATION SUCCÈS (OBLIGATOIRE)
      emit(RapportAddedSuccess());

      /// 🔄 RELOAD SILENCIEUX
      _page = 0;
      _hasReachedMax = false;
      _rapports.clear();

      add(LoadRapports(userId: event.propertyId));
    } catch (e) {
      emit(RapportError(e.toString()));
    }
  }

  // ================= DELETE =================
  Future<void> _onDeleteRapport(
      DeleteRapport event, Emitter<RapportState> emit) async {
    try {
      await repository.removeRapport(event.rapportId);

      _rapports.removeWhere((r) => r.id == event.rapportId);

      emit(RapportActionSuccess("Rapport supprimé avec succès"));
      emit(
        RapportLoaded(
          rapports: List.from(_rapports),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      emit(RapportError(e.toString()));
    }
  }
}
