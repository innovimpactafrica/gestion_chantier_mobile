import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/models/IncidentModel.dart';
import 'package:gestion_chantier/moa/services/IncidentService.dart';

// Events
abstract class IncidentsEvent {}

class LoadIncidentsEvent extends IncidentsEvent {
  final int propertyId;
  final int page;
  final int size;

  LoadIncidentsEvent({required this.propertyId, this.page = 0, this.size = 10});
}

class RefreshIncidentsEvent extends IncidentsEvent {
  final int propertyId;

  RefreshIncidentsEvent({required this.propertyId});
}

// States
abstract class IncidentsState {}

class IncidentsInitial extends IncidentsState {}

class IncidentsLoading extends IncidentsState {}

class IncidentsLoaded extends IncidentsState {
  final List<IncidentModel> incidents;
  final int totalElements;
  final int totalPages;
  final bool hasMore;

  IncidentsLoaded({
    required this.incidents,
    required this.totalElements,
    required this.totalPages,
    required this.hasMore,
  });
}

class IncidentsError extends IncidentsState {
  final String message;

  IncidentsError({required this.message});
}

// Bloc
class IncidentsBloc extends Bloc<IncidentsEvent, IncidentsState> {
  final IncidentService _incidentService = IncidentService();

  IncidentsBloc() : super(IncidentsInitial()) {
    on<LoadIncidentsEvent>(_onLoadIncidents);
    on<RefreshIncidentsEvent>(_onRefreshIncidents);
  }

  Future<void> _onLoadIncidents(
    LoadIncidentsEvent event,
    Emitter<IncidentsState> emit,
  ) async {
    emit(IncidentsLoading());

    try {
      final response = await _incidentService.getIncidents(
        propertyId: event.propertyId,
        page: event.page,
        size: event.size,
      );

      emit(
        IncidentsLoaded(
          incidents: response.content,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          hasMore: !response.last,
        ),
      );
    } catch (e) {
      emit(IncidentsError(message: e.toString()));
    }
  }

  Future<void> _onRefreshIncidents(
    RefreshIncidentsEvent event,
    Emitter<IncidentsState> emit,
  ) async {
    emit(IncidentsLoading());

    try {
      final response = await _incidentService.getIncidents(
        propertyId: event.propertyId,
        page: 0,
        size: 10,
      );

      emit(
        IncidentsLoaded(
          incidents: response.content,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          hasMore: !response.last,
        ),
      );
    } catch (e) {
      emit(IncidentsError(message: e.toString()));
    }
  }
}
